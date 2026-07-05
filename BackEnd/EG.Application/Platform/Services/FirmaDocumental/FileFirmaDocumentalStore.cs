using System.Text.Json;
using EG.Application.Interfaces.FirmaDocumental;
using EG.Application.Services.FirmaDocumental.Models;
using EG.Domain.Platform.Settings;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;

namespace EG.Application.Services.FirmaDocumental
{
    public sealed class FileFirmaDocumentalStore(
        IOptions<DocumentStorageSettings> storageOptions,
        IOptions<FirmaDocumentalSettings> firmaOptions,
        ILogger<FileFirmaDocumentalStore> logger) : IFirmaDocumentalStore
    {
        private readonly SemaphoreSlim _sync = new(1, 1);
        private readonly JsonSerializerOptions _jsonOptions = new(JsonSerializerDefaults.Web)
        {
            WriteIndented = true
        };

        public async Task SaveCertificateAsync(FirmaCertificateRecord record, CancellationToken cancellationToken = default)
        {
            await _sync.WaitAsync(cancellationToken);
            try
            {
                var records = await ReadListAsync<FirmaCertificateRecord>(CertificatesPath, cancellationToken);
                records.RemoveAll(x => x.CertificadoId == record.CertificadoId);
                records.Add(record);
                await WriteListAsync(CertificatesPath, records, cancellationToken);
            }
            finally
            {
                _sync.Release();
            }
        }

        public async Task<IReadOnlyList<FirmaCertificateRecord>> GetCertificatesAsync(int usuarioId, int? empresaId, CancellationToken cancellationToken = default)
        {
            await _sync.WaitAsync(cancellationToken);
            try
            {
                var records = await ReadListAsync<FirmaCertificateRecord>(CertificatesPath, cancellationToken);
                return records
                    .Where(x => x.UsuarioId == usuarioId
                        && x.Activo
                        && (!empresaId.HasValue || !x.FkidEmpresaSis.HasValue || x.FkidEmpresaSis == empresaId))
                    .OrderByDescending(x => x.FechaRegistro)
                    .ToList();
            }
            finally
            {
                _sync.Release();
            }
        }

        public async Task<FirmaCertificateRecord?> GetCertificateAsync(Guid certificadoId, int usuarioId, CancellationToken cancellationToken = default)
        {
            await _sync.WaitAsync(cancellationToken);
            try
            {
                var records = await ReadListAsync<FirmaCertificateRecord>(CertificatesPath, cancellationToken);
                return records.FirstOrDefault(x => x.CertificadoId == certificadoId && x.UsuarioId == usuarioId && x.Activo);
            }
            finally
            {
                _sync.Release();
            }
        }

        public async Task SaveSignatureAsync(FirmaDocumentRecord record, CancellationToken cancellationToken = default)
        {
            await _sync.WaitAsync(cancellationToken);
            try
            {
                var records = await ReadListAsync<FirmaDocumentRecord>(SignaturesPath, cancellationToken);
                records.RemoveAll(x => x.FirmaId == record.FirmaId);
                records.Add(record);
                await WriteListAsync(SignaturesPath, records, cancellationToken);
            }
            finally
            {
                _sync.Release();
            }
        }

        public async Task<IReadOnlyList<FirmaDocumentRecord>> GetSignaturesAsync(
            long? documentoId,
            string? entidadOrigen,
            long? registroOrigenId,
            int? empresaId,
            CancellationToken cancellationToken = default)
        {
            await _sync.WaitAsync(cancellationToken);
            try
            {
                var records = await ReadListAsync<FirmaDocumentRecord>(SignaturesPath, cancellationToken);
                return records
                    .Where(x => !documentoId.HasValue || x.DocumentoId == documentoId)
                    .Where(x => string.IsNullOrWhiteSpace(entidadOrigen) || string.Equals(x.EntidadOrigen, entidadOrigen, StringComparison.OrdinalIgnoreCase))
                    .Where(x => !registroOrigenId.HasValue || x.RegistroOrigenId == registroOrigenId)
                    .Where(x => !empresaId.HasValue || !x.FkidEmpresaSis.HasValue || x.FkidEmpresaSis == empresaId)
                    .OrderByDescending(x => x.FechaFirmaUtc)
                    .ToList();
            }
            finally
            {
                _sync.Release();
            }
        }

        public async Task ProtectDocumentAsync(FirmaProtectedDocumentRecord record, CancellationToken cancellationToken = default)
        {
            await _sync.WaitAsync(cancellationToken);
            try
            {
                var records = await ReadListAsync<FirmaProtectedDocumentRecord>(ProtectedDocumentsPath, cancellationToken);
                records.RemoveAll(x => x.DocumentoId == record.DocumentoId);
                records.Add(record);
                await WriteListAsync(ProtectedDocumentsPath, records, cancellationToken);
            }
            finally
            {
                _sync.Release();
            }
        }

        public async Task<FirmaProtectedDocumentRecord?> GetProtectedDocumentAsync(long documentoId, CancellationToken cancellationToken = default)
        {
            await _sync.WaitAsync(cancellationToken);
            try
            {
                var records = await ReadListAsync<FirmaProtectedDocumentRecord>(ProtectedDocumentsPath, cancellationToken);
                return records.FirstOrDefault(x => x.DocumentoId == documentoId);
            }
            finally
            {
                _sync.Release();
            }
        }

        public async Task<IReadOnlyDictionary<long, FirmaProtectedDocumentRecord>> GetProtectedDocumentsAsync(IEnumerable<long> documentoIds, CancellationToken cancellationToken = default)
        {
            var idSet = documentoIds.ToHashSet();
            if (idSet.Count == 0)
                return new Dictionary<long, FirmaProtectedDocumentRecord>();

            await _sync.WaitAsync(cancellationToken);
            try
            {
                var records = await ReadListAsync<FirmaProtectedDocumentRecord>(ProtectedDocumentsPath, cancellationToken);
                return records
                    .Where(x => idSet.Contains(x.DocumentoId))
                    .GroupBy(x => x.DocumentoId)
                    .ToDictionary(x => x.Key, x => x.OrderByDescending(item => item.FechaProteccionUtc).First());
            }
            finally
            {
                _sync.Release();
            }
        }

        private string RootPath
        {
            get
            {
                var basePath = string.IsNullOrWhiteSpace(storageOptions.Value.BasePath)
                    ? "Documentos"
                    : storageOptions.Value.BasePath;
                var vaultPath = string.IsNullOrWhiteSpace(firmaOptions.Value.VaultPath)
                    ? "FirmaDocumental"
                    : firmaOptions.Value.VaultPath;
                return Path.GetFullPath(Path.Combine(basePath, vaultPath));
            }
        }

        private string CertificatesPath => Path.Combine(RootPath, "certificados.json");
        private string SignaturesPath => Path.Combine(RootPath, "firmas.json");
        private string ProtectedDocumentsPath => Path.Combine(RootPath, "documentos-protegidos.json");

        private async Task<List<T>> ReadListAsync<T>(string path, CancellationToken cancellationToken)
        {
            EnsureDirectory(path);
            if (!File.Exists(path))
                return [];

            await using var stream = File.OpenRead(path);
            return await JsonSerializer.DeserializeAsync<List<T>>(stream, _jsonOptions, cancellationToken) ?? [];
        }

        private async Task WriteListAsync<T>(string path, List<T> items, CancellationToken cancellationToken)
        {
            EnsureDirectory(path);
            var tempPath = $"{path}.{Guid.NewGuid():N}.tmp";
            await using (var stream = File.Create(tempPath))
            {
                await JsonSerializer.SerializeAsync(stream, items, _jsonOptions, cancellationToken);
            }

            File.Move(tempPath, path, overwrite: true);
            logger.LogDebug("FirmaDocumental store actualizado: {Path}", path);
        }

        private static void EnsureDirectory(string path)
        {
            var directory = Path.GetDirectoryName(path);
            if (!string.IsNullOrWhiteSpace(directory))
                Directory.CreateDirectory(directory);
        }
    }
}
