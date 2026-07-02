using System.Collections.Concurrent;
using System.Globalization;
using System.Text;
using System.Text.RegularExpressions;
using EG.Application.Interfaces.DocumentRag;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.DocumentRag;
using EG.Domain.DTOs.Responses.DocumentRag;
using EG.Domain.Platform.Settings;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;

namespace EG.Application.Services.DocumentRag
{
    public sealed partial class DocumentRagAppService(
        IOptions<DocumentRagSettings> settings,
        ILogger<DocumentRagAppService> logger) : IDocumentRagAppService
    {
        private readonly ConcurrentDictionary<Guid, RagSession> _sessions = new();
        private readonly DocumentRagSettings _settings = settings.Value;

        public Task<PagedResult<DocumentRagSessionResponse>> CreateSessionAsync(DocumentRagSessionRequest request, int usuarioActual)
        {
            CleanupExpiredSessions();

            var now = DateTime.UtcNow;
            var ttl = TimeSpan.FromMinutes(Math.Max(5, _settings.SessionTtlMinutes));
            var session = new RagSession
            {
                SessionId = Guid.NewGuid(),
                Modulo = string.IsNullOrWhiteSpace(request.Modulo) ? "RAG" : request.Modulo.Trim(),
                SubModulo = request.SubModulo,
                Controlador = request.Controlador,
                Servicio = request.Servicio,
                EntidadId = request.EntidadId,
                FkidEmpresaSis = request.FkidEmpresaSis,
                Titulo = request.Titulo,
                Descripcion = request.Descripcion,
                UsuarioId = usuarioActual,
                CreatedAtUtc = now,
                LastAccessAtUtc = now,
                ExpiresAtUtc = now.Add(ttl)
            };

            _sessions[session.SessionId] = session;
            logger.LogInformation(
                "RAG sesion creada. Usuario={Usuario}; SessionId={SessionId}; Modulo={Modulo}; EntidadId={EntidadId}",
                usuarioActual,
                session.SessionId,
                session.Modulo,
                session.EntidadId);

            return Task.FromResult(Success(
                "Sesion documental creada. Puedes cargar documentos.",
                ToSessionResponse(session)));
        }

        public Task<PagedResult<DocumentRagSessionResponse>> GetSessionAsync(Guid sessionId, int usuarioActual)
        {
            CleanupExpiredSessions();
            var session = RequireSession(sessionId, usuarioActual);
            Touch(session);
            return Task.FromResult(Success("Sesion documental obtenida.", ToSessionResponse(session)));
        }

        public async Task<PagedResult<DocumentRagDocumentResponse>> UploadAsync(DocumentRagUploadRequest request, int usuarioActual)
        {
            CleanupExpiredSessions();
            var session = RequireSession(request.SessionId, usuarioActual);
            ValidateUpload(request, session);

            var extraction = await DocumentTextExtractor.ExtractAsync(request, _settings, logger);
            var document = new RagDocument
            {
                DocumentId = Guid.NewGuid(),
                NombreOriginal = request.NombreOriginal,
                Extension = NormalizeExtension(Path.GetExtension(request.NombreOriginal)),
                TipoMime = request.TipoMime,
                TamanoBytes = request.TamanoBytes,
                UploadedAtUtc = DateTime.UtcNow,
                Text = extraction.Text,
                Status = extraction.Status,
                Message = extraction.Message
            };

            document.Chunks.AddRange(CreateChunks(document));

            lock (session.SyncRoot)
            {
                ValidateUpload(request, session);
                session.Documents.Add(document);
                session.TotalBytes += request.TamanoBytes;
                Touch(session);
            }

            logger.LogInformation(
                "RAG documento recibido. Usuario={Usuario}; SessionId={SessionId}; DocumentId={DocumentId}; Archivo={Archivo}; Bytes={Bytes}; Status={Status}; Chunks={Chunks}",
                usuarioActual,
                session.SessionId,
                document.DocumentId,
                document.NombreOriginal,
                document.TamanoBytes,
                document.Status,
                document.Chunks.Count);

            return Success(document.Message, ToDocumentResponse(document));
        }

        public Task<PagedResult<DocumentRagAskResponse>> AskAsync(DocumentRagAskRequest request, int usuarioActual)
        {
            CleanupExpiredSessions();
            if (string.IsNullOrWhiteSpace(request.Question))
                throw new InvalidOperationException("La pregunta es requerida.");

            var session = RequireSession(request.SessionId, usuarioActual);
            var now = DateTime.UtcNow;
            var question = request.Question.Trim();
            var topK = Math.Clamp(request.TopK ?? _settings.TopK, 1, 12);
            var questionId = Guid.NewGuid();
            List<RagChunk> chunks;

            lock (session.SyncRoot)
            {
                Touch(session);
                chunks = session.Documents.SelectMany(x => x.Chunks).ToList();
            }

            var queryTerms = Tokenize(question)
                .Where(term => !StopWords.Contains(term))
                .Distinct(StringComparer.Ordinal)
                .ToList();
            var queryTermSet = queryTerms.ToHashSet(StringComparer.Ordinal);

            var ranked = queryTerms.Count == 0 || chunks.Count == 0
                ? []
                : RankChunks(chunks, queryTerms, topK);

            var hasEvidence = ranked.Any(x => x.Score >= _settings.MinScore);
            var answer = hasEvidence
                ? BuildExtractiveAnswer(ranked, queryTermSet)
                : "La informacion no esta en los documentos cargados. No encontre evidencia suficiente en el texto indexado para responder esa pregunta.";

            var citations = hasEvidence
                ? ranked.Select(item => ToCitation(item, queryTermSet)).ToList()
                : [];

            var response = new DocumentRagAskResponse
            {
                SessionId = session.SessionId,
                QuestionId = questionId,
                Question = question,
                Answer = answer,
                AnsweredFromDocuments = hasEvidence,
                AskedAtUtc = now,
                Citations = citations
            };

            var history = new DocumentRagHistoryItemResponse
            {
                QuestionId = questionId,
                Question = question,
                Answer = answer,
                AnsweredFromDocuments = hasEvidence,
                AskedAtUtc = now,
                Citations = citations
            };

            lock (session.SyncRoot)
            {
                session.History.Add(history);
                Touch(session);
            }

            logger.LogInformation(
                "RAG pregunta procesada. Usuario={Usuario}; SessionId={SessionId}; QuestionId={QuestionId}; Answered={Answered}; Question={Question}; Answer={Answer}",
                usuarioActual,
                session.SessionId,
                questionId,
                hasEvidence,
                TruncateForLog(question, 300),
                TruncateForLog(answer, 600));

            return Task.FromResult(Success("Pregunta procesada.", response));
        }

        public Task<PagedResult<DocumentRagHistoryItemResponse>> GetHistoryAsync(Guid sessionId, int usuarioActual)
        {
            CleanupExpiredSessions();
            var session = RequireSession(sessionId, usuarioActual);
            List<DocumentRagHistoryItemResponse> history;
            lock (session.SyncRoot)
            {
                Touch(session);
                history = session.History.OrderBy(x => x.AskedAtUtc).ToList();
            }

            return Task.FromResult(new PagedResult<DocumentRagHistoryItemResponse>
            {
                Success = true,
                Code = "SUCCESS",
                Message = "Historial obtenido.",
                Items = history,
                TotalCount = history.Count
            });
        }

        public Task<PagedResult<bool>> ReleaseSessionAsync(Guid sessionId, int usuarioActual)
        {
            var removed = false;
            if (_sessions.TryGetValue(sessionId, out var session) && session.UsuarioId == usuarioActual)
                removed = _sessions.TryRemove(sessionId, out _);

            logger.LogInformation(
                "RAG sesion liberada. Usuario={Usuario}; SessionId={SessionId}; Liberada={Liberada}",
                usuarioActual,
                sessionId,
                removed);

            return Task.FromResult(new PagedResult<bool>
            {
                Success = true,
                Code = "SUCCESS",
                Message = removed ? "Memoria de la sesion documental liberada." : "La sesion documental ya no estaba activa.",
                Data = true,
                Items = [true],
                TotalCount = 1
            });
        }

        private void ValidateUpload(DocumentRagUploadRequest request, RagSession session)
        {
            if (request.Contenido.Length == 0 || request.TamanoBytes <= 0)
                throw new InvalidOperationException("El archivo esta vacio.");

            var extension = NormalizeExtension(Path.GetExtension(request.NombreOriginal));
            var allowed = _settings.AllowedExtensions
                .Select(NormalizeExtension)
                .ToHashSet(StringComparer.OrdinalIgnoreCase);

            if (!allowed.Contains(extension))
                throw new InvalidOperationException($"La extension {extension} no esta permitida para RAG documental.");

            var maxFileBytes = Math.Max(1, _settings.MaxFileSizeMB) * 1024L * 1024L;
            if (request.TamanoBytes > maxFileBytes || request.Contenido.LongLength > maxFileBytes)
                throw new InvalidOperationException($"El archivo supera el limite de {_settings.MaxFileSizeMB} MB.");

            lock (session.SyncRoot)
            {
                if (session.Documents.Count >= Math.Max(1, _settings.MaxSessionDocuments))
                    throw new InvalidOperationException($"La sesion ya tiene el maximo de {_settings.MaxSessionDocuments} documentos.");

                var maxSessionBytes = Math.Max(_settings.MaxFileSizeMB, _settings.MaxSessionTotalMB) * 1024L * 1024L;
                if (session.TotalBytes + request.TamanoBytes > maxSessionBytes)
                    throw new InvalidOperationException($"La sesion supera el limite total de {_settings.MaxSessionTotalMB} MB.");
            }
        }

        private List<RagChunk> CreateChunks(RagDocument document)
        {
            if (string.IsNullOrWhiteSpace(document.Text))
                return [];

            var chunkSize = Math.Max(500, _settings.ChunkSize);
            var overlap = Math.Clamp(_settings.ChunkOverlap, 0, chunkSize / 2);
            var chunks = new List<RagChunk>();
            var index = 0;
            var start = 0;

            while (start < document.Text.Length)
            {
                var length = Math.Min(chunkSize, document.Text.Length - start);
                var end = start + length;

                if (end < document.Text.Length)
                {
                    var boundary = document.Text.LastIndexOfAny(['.', '\n', ';', ' '], end - 1, Math.Max(1, length / 3));
                    if (boundary > start + chunkSize / 2)
                        end = boundary + 1;
                }

                var text = document.Text[start..end].Trim();
                if (!string.IsNullOrWhiteSpace(text))
                    chunks.Add(CreateChunk(document, index++, text));

                if (end >= document.Text.Length)
                    break;

                start = Math.Max(end - overlap, start + 1);
            }

            return chunks;
        }

        private static RagChunk CreateChunk(RagDocument document, int index, string text)
        {
            var tokens = Tokenize(text).Where(term => !StopWords.Contains(term)).ToList();
            return new RagChunk
            {
                DocumentId = document.DocumentId,
                DocumentName = document.NombreOriginal,
                ChunkIndex = index,
                Text = text,
                SearchText = NormalizeForSearch(text),
                TokenCount = tokens.Count,
                Terms = tokens.ToHashSet(StringComparer.Ordinal),
                TermFrequency = tokens
                    .GroupBy(x => x, StringComparer.Ordinal)
                    .ToDictionary(x => x.Key, x => x.Count(), StringComparer.Ordinal)
            };
        }

        private List<ScoredChunk> RankChunks(List<RagChunk> chunks, IReadOnlyList<string> queryTerms, int topK)
        {
            var documentFrequency = queryTerms.ToDictionary(
                term => term,
                term => chunks.Count(chunk => chunk.Terms.Contains(term)),
                StringComparer.Ordinal);

            return chunks.Select(chunk =>
                {
                    var score = 0d;
                    foreach (var term in queryTerms)
                    {
                        if (!chunk.TermFrequency.TryGetValue(term, out var frequency))
                            continue;

                        var idf = Math.Log(1d + (chunks.Count + 1d) / (documentFrequency[term] + 1d));
                        score += (1d + Math.Log(frequency)) * idf;
                    }

                    if (score > 0)
                        score /= Math.Sqrt(Math.Max(1, chunk.TokenCount));

                    var phrase = string.Join(' ', queryTerms);
                    if (phrase.Length > 4 && chunk.SearchText.Contains(phrase, StringComparison.Ordinal))
                        score += 0.25d;

                    return new ScoredChunk(chunk, score);
                })
                .Where(x => x.Score > 0)
                .OrderByDescending(x => x.Score)
                .Take(topK)
                .ToList();
        }

        private static string BuildExtractiveAnswer(IEnumerable<ScoredChunk> rankedChunks, IReadOnlySet<string> queryTerms)
        {
            var selectedSentences = new List<string>();
            var seen = new HashSet<string>(StringComparer.OrdinalIgnoreCase);

            foreach (var ranked in rankedChunks)
            {
                foreach (var sentence in ExtractRelevantSentences(ranked.Chunk.Text, queryTerms).Take(2))
                {
                    var normalized = NormalizeForSearch(sentence);
                    if (normalized.Length < 8 || !seen.Add(normalized))
                        continue;

                    selectedSentences.Add(sentence);
                    if (selectedSentences.Count >= 6)
                        break;
                }

                if (selectedSentences.Count >= 6)
                    break;
            }

            if (selectedSentences.Count == 0)
            {
                selectedSentences.AddRange(rankedChunks
                    .Select(x => TrimSnippet(x.Chunk.Text, 420))
                    .Where(x => !string.IsNullOrWhiteSpace(x))
                    .Take(3));
            }

            var builder = new StringBuilder();
            builder.AppendLine("Con base unicamente en los documentos cargados:");
            foreach (var sentence in selectedSentences)
                builder.AppendLine($"- {sentence}");

            return builder.ToString().Trim();
        }

        private static IEnumerable<string> ExtractRelevantSentences(string text, IReadOnlySet<string> queryTerms)
        {
            return SentenceSplitRegex().Split(text)
                .Select(sentence => sentence.Trim())
                .Where(sentence => sentence.Length > 20)
                .Select(sentence => new
                {
                    Text = sentence,
                    Score = Tokenize(sentence).Count(queryTerms.Contains)
                })
                .Where(x => x.Score > 0)
                .OrderByDescending(x => x.Score)
                .ThenBy(x => x.Text.Length)
                .Select(x => TrimSnippet(x.Text, 520));
        }

        private static DocumentRagCitationResponse ToCitation(ScoredChunk item, IReadOnlySet<string> queryTerms)
        {
            var snippet = ExtractRelevantSentences(item.Chunk.Text, queryTerms).FirstOrDefault();
            if (string.IsNullOrWhiteSpace(snippet))
                snippet = TrimSnippet(item.Chunk.Text, 520);

            return new DocumentRagCitationResponse
            {
                DocumentId = item.Chunk.DocumentId,
                DocumentName = item.Chunk.DocumentName,
                ChunkIndex = item.Chunk.ChunkIndex,
                Page = null,
                Score = Math.Round(item.Score, 4),
                Snippet = snippet
            };
        }

        private RagSession RequireSession(Guid sessionId, int usuarioActual)
        {
            if (sessionId == Guid.Empty || !_sessions.TryGetValue(sessionId, out var session))
                throw new InvalidOperationException("La sesion documental no existe o ya fue liberada.");

            if (session.UsuarioId != usuarioActual)
                throw new InvalidOperationException("No tienes acceso a esta sesion documental.");

            if (DateTime.UtcNow > session.ExpiresAtUtc)
            {
                _sessions.TryRemove(sessionId, out _);
                throw new InvalidOperationException("La sesion documental expiro. Crea una nueva sesion y vuelve a cargar los documentos.");
            }

            return session;
        }

        private void CleanupExpiredSessions()
        {
            var now = DateTime.UtcNow;
            foreach (var pair in _sessions.Where(pair => pair.Value.ExpiresAtUtc < now).ToList())
            {
                if (_sessions.TryRemove(pair.Key, out var removed))
                {
                    logger.LogInformation(
                        "RAG sesion expirada liberada. Usuario={Usuario}; SessionId={SessionId}; Documentos={Documentos}; Chunks={Chunks}",
                        removed.UsuarioId,
                        removed.SessionId,
                        removed.Documents.Count,
                        removed.Documents.Sum(x => x.Chunks.Count));
                }
            }
        }

        private void Touch(RagSession session)
        {
            var now = DateTime.UtcNow;
            session.LastAccessAtUtc = now;
            session.ExpiresAtUtc = now.AddMinutes(Math.Max(5, _settings.SessionTtlMinutes));
        }

        private static DocumentRagSessionResponse ToSessionResponse(RagSession session)
        {
            lock (session.SyncRoot)
            {
                return new DocumentRagSessionResponse
                {
                    SessionId = session.SessionId,
                    Modulo = session.Modulo,
                    SubModulo = session.SubModulo,
                    Controlador = session.Controlador,
                    Servicio = session.Servicio,
                    EntidadId = session.EntidadId,
                    FkidEmpresaSis = session.FkidEmpresaSis,
                    Titulo = session.Titulo,
                    Descripcion = session.Descripcion,
                    UsuarioId = session.UsuarioId,
                    CreatedAtUtc = session.CreatedAtUtc,
                    LastAccessAtUtc = session.LastAccessAtUtc,
                    ExpiresAtUtc = session.ExpiresAtUtc,
                    DocumentCount = session.Documents.Count,
                    IndexedChunkCount = session.Documents.Sum(x => x.Chunks.Count),
                    TotalBytes = session.TotalBytes,
                    Documents = session.Documents.Select(ToDocumentResponse).ToList(),
                    History = session.History.OrderBy(x => x.AskedAtUtc).ToList()
                };
            }
        }

        private static DocumentRagDocumentResponse ToDocumentResponse(RagDocument document) => new()
        {
            DocumentId = document.DocumentId,
            NombreOriginal = document.NombreOriginal,
            Extension = document.Extension,
            TipoMime = document.TipoMime,
            TamanoBytes = document.TamanoBytes,
            CharacterCount = document.Text.Length,
            ChunkCount = document.Chunks.Count,
            Status = document.Status,
            Message = document.Message,
            UploadedAtUtc = document.UploadedAtUtc
        };

        private static PagedResult<T> Success<T>(string message, T data) => new()
        {
            Success = true,
            Code = "SUCCESS",
            Message = message,
            Data = data,
            Items = [data],
            TotalCount = 1
        };

        private static List<string> Tokenize(string text)
        {
            var normalized = NormalizeForSearch(text);
            return TokenRegex().Matches(normalized)
                .Select(match => match.Value)
                .Where(term => term.Length > 1)
                .ToList();
        }

        private static string NormalizeForSearch(string text)
        {
            if (string.IsNullOrWhiteSpace(text))
                return string.Empty;

            var normalized = text.Normalize(NormalizationForm.FormD);
            var builder = new StringBuilder(normalized.Length);
            foreach (var ch in normalized)
            {
                if (CharUnicodeInfo.GetUnicodeCategory(ch) != UnicodeCategory.NonSpacingMark)
                    builder.Append(char.ToLowerInvariant(ch));
            }

            return builder.ToString().Normalize(NormalizationForm.FormC);
        }

        private static string NormalizeExtension(string? value)
        {
            var extension = (value ?? string.Empty).Trim().ToLowerInvariant();
            if (string.IsNullOrWhiteSpace(extension))
                throw new InvalidOperationException("El archivo no tiene extension.");

            return extension.StartsWith('.') ? extension : $".{extension}";
        }

        private static string TrimSnippet(string value, int maxLength)
        {
            var clean = WhitespaceRegex().Replace(value.Trim(), " ");
            if (clean.Length <= maxLength)
                return clean;

            return $"{clean[..Math.Max(0, maxLength - 3)].Trim()}...";
        }

        private static string TruncateForLog(string value, int maxLength)
            => value.Length <= maxLength ? value : $"{value[..maxLength]}...";

        private static readonly HashSet<string> StopWords = new(StringComparer.Ordinal)
        {
            "a", "al", "algo", "ante", "antes", "aqui", "asi", "como", "con", "contra", "cual", "cuales",
            "cuando", "de", "del", "desde", "donde", "dos", "el", "ella", "ellas", "ellos", "en", "entre",
            "era", "eres", "es", "esa", "esas", "ese", "eso", "esos", "esta", "estan", "estar", "estas",
            "este", "esto", "estos", "fue", "ha", "hay", "la", "las", "le", "les", "lo", "los", "mas",
            "me", "mi", "mis", "no", "nos", "o", "para", "pero", "por", "que", "quien", "se", "segun",
            "si", "sin", "sobre", "son", "su", "sus", "te", "tiene", "un", "una", "uno", "unos", "y",
            "the", "is", "are", "and", "or", "of", "to", "in", "on", "for", "with", "what", "which"
        };

        private sealed class RagSession
        {
            public object SyncRoot { get; } = new();
            public Guid SessionId { get; init; }
            public string Modulo { get; init; } = "RAG";
            public string? SubModulo { get; init; }
            public string? Controlador { get; init; }
            public string? Servicio { get; init; }
            public long? EntidadId { get; init; }
            public int? FkidEmpresaSis { get; init; }
            public string? Titulo { get; init; }
            public string? Descripcion { get; init; }
            public int UsuarioId { get; init; }
            public DateTime CreatedAtUtc { get; init; }
            public DateTime LastAccessAtUtc { get; set; }
            public DateTime ExpiresAtUtc { get; set; }
            public long TotalBytes { get; set; }
            public List<RagDocument> Documents { get; } = [];
            public List<DocumentRagHistoryItemResponse> History { get; } = [];
        }

        private sealed class RagDocument
        {
            public Guid DocumentId { get; init; }
            public string NombreOriginal { get; init; } = string.Empty;
            public string Extension { get; init; } = string.Empty;
            public string TipoMime { get; init; } = string.Empty;
            public long TamanoBytes { get; init; }
            public DateTime UploadedAtUtc { get; init; }
            public string Text { get; init; } = string.Empty;
            public string Status { get; init; } = string.Empty;
            public string Message { get; init; } = string.Empty;
            public List<RagChunk> Chunks { get; } = [];
        }

        private sealed class RagChunk
        {
            public Guid DocumentId { get; init; }
            public string DocumentName { get; init; } = string.Empty;
            public int ChunkIndex { get; init; }
            public string Text { get; init; } = string.Empty;
            public string SearchText { get; init; } = string.Empty;
            public int TokenCount { get; init; }
            public HashSet<string> Terms { get; init; } = [];
            public Dictionary<string, int> TermFrequency { get; init; } = [];
        }

        private sealed record ScoredChunk(RagChunk Chunk, double Score);

        [GeneratedRegex(@"[\p{L}\p{N}]{2,}")]
        private static partial Regex TokenRegex();

        [GeneratedRegex(@"(?<=[\.\?\!;:])\s+|\n+")]
        private static partial Regex SentenceSplitRegex();

        [GeneratedRegex(@"\s+")]
        private static partial Regex WhitespaceRegex();
    }
}
