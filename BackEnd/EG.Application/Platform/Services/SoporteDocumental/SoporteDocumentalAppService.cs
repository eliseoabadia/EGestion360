using System.Data;
using System.Text.Json;
using EG.Application.Interfaces.SoporteDocumental;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.SoporteDocumental;
using EG.Domain.DTOs.Responses.SoporteDocumental;
using EG.Domain.Platform.Settings;
using EG.Infraestructure.Models;
using Microsoft.Data.SqlClient;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Options;

namespace EG.Application.Services.SoporteDocumental
{
    public class SoporteDocumentalAppService(
        EGestionContext context,
        IOptions<DocumentStorageSettings> storageOptions) : ISoporteDocumentalAppService
    {
        private readonly DocumentStorageSettings _settings = storageOptions.Value;
        private static readonly JsonSerializerOptions JsonOptions = new() { PropertyNameCaseInsensitive = true };

        public async Task<PagedResult<DocumentoResponse>> ObtenerPorEntidadAsync(DocumentoEntidadRequest request)
        {
            try
            {
                var items = new List<DocumentoResponse>();
                await using var command = await CreateCommandAsync("SIS.spDocumentoObtenerPorEntidad", CommandType.StoredProcedure);
                AddEntityParameters(command, request);
                command.Parameters.Add(new SqlParameter("@IncluirInactivos", request.IncluirInactivos));

                await using var reader = await command.ExecuteReaderAsync();
                while (await reader.ReadAsync())
                {
                    items.Add(MapDocumento(reader));
                }

                return new PagedResult<DocumentoResponse>
                {
                    Success = true,
                    Message = "Documentos obtenidos correctamente",
                    Code = "SUCCESS",
                    Items = items,
                    TotalCount = items.Count
                };
            }
            catch (SqlException ex) when (IsMissingDocumentSchema(ex))
            {
                return new PagedResult<DocumentoResponse>
                {
                    Success = true,
                    Message = "El esquema de soporte documental aun no esta instalado.",
                    Code = "DOCUMENT_SCHEMA_MISSING",
                    Items = [],
                    TotalCount = 0
                };
            }
        }

        public async Task<PagedResult<DocumentoResumenResponse>> ObtenerResumenAsync(DocumentoEntidadRequest request)
        {
            try
            {
                await using var command = await CreateCommandAsync("""
                    SELECT Modulo, SubModulo, Controlador, Servicio, EntidadId, FkidEmpresaSis,
                           TotalDocumentos, TotalBytes, UltimaFechaDocumento
                    FROM SIS.Vw_DocumentoResumenEntidad
                    WHERE Modulo = @Modulo
                      AND ISNULL(SubModulo, N'') = ISNULL(@SubModulo, N'')
                      AND ISNULL(Controlador, N'') = ISNULL(@Controlador, N'')
                      AND ISNULL(Servicio, N'') = ISNULL(@Servicio, N'')
                      AND EntidadId = @EntidadId
                      AND ISNULL(FkidEmpresaSis, 0) = ISNULL(@FkidEmpresaSis, 0)
                    """, CommandType.Text);
                AddEntityParameters(command, request);

                await using var reader = await command.ExecuteReaderAsync();
                DocumentoResumenResponse item;
                if (await reader.ReadAsync())
                {
                    item = new DocumentoResumenResponse
                    {
                        Modulo = GetString(reader, "Modulo"),
                        SubModulo = GetNullableString(reader, "SubModulo"),
                        Controlador = GetNullableString(reader, "Controlador"),
                        Servicio = GetNullableString(reader, "Servicio"),
                        EntidadId = GetInt64(reader, "EntidadId"),
                        FkidEmpresaSis = GetNullableInt(reader, "FkidEmpresaSis"),
                        TotalDocumentos = GetInt32(reader, "TotalDocumentos"),
                        TotalBytes = GetInt64(reader, "TotalBytes"),
                        UltimaFechaDocumento = GetNullableDateTime(reader, "UltimaFechaDocumento")
                    };
                }
                else
                {
                    item = EmptySummary(request);
                }

                return new PagedResult<DocumentoResumenResponse>
                {
                    Success = true,
                    Message = "Resumen documental obtenido correctamente",
                    Code = "SUCCESS",
                    Data = item,
                    Items = new List<DocumentoResumenResponse> { item },
                    TotalCount = 1
                };
            }
            catch (SqlException ex) when (IsMissingDocumentSchema(ex))
            {
                var item = EmptySummary(request);
                return new PagedResult<DocumentoResumenResponse>
                {
                    Success = true,
                    Message = "El esquema de soporte documental aun no esta instalado.",
                    Code = "DOCUMENT_SCHEMA_MISSING",
                    Data = item,
                    Items = [item],
                    TotalCount = 1
                };
            }
        }

        public async Task<PagedResult<DocumentoResponse>> GuardarAsync(DocumentoUploadRequest request, int usuarioActual)
        {
            ValidateUpload(request);

            var mode = NormalizeMode(_settings.Mode);
            var extension = NormalizeExtension(Path.GetExtension(request.NombreOriginal));
            var storedName = $"{Guid.NewGuid():N}{extension}";
            string? relativePath = null;
            byte[]? contentForDatabase = mode == "DATABASE" ? request.Contenido : null;
            string? physicalPath = null;

            if (mode == "FILESYSTEM")
            {
                relativePath = BuildRelativePath(request, storedName);
                physicalPath = GetSafePhysicalPath(relativePath);
                Directory.CreateDirectory(Path.GetDirectoryName(physicalPath)!);
                await File.WriteAllBytesAsync(physicalPath, request.Contenido);
            }

            try
            {
                var idParam = new SqlParameter("@PkidDocumento", SqlDbType.BigInt)
                {
                    Direction = ParameterDirection.InputOutput,
                    Value = DBNull.Value
                };

                var result = await ExecuteResultJsonAsync(
                    "SIS.spDocumentoGuardar",
                    idParam,
                    Param("@Modulo", request.Modulo),
                    Param("@SubModulo", request.SubModulo),
                    Param("@Controlador", request.Controlador),
                    Param("@Servicio", request.Servicio),
                    Param("@EntidadId", request.EntidadId),
                    Param("@FkidEmpresaSis", request.FkidEmpresaSis),
                    Param("@Titulo", request.Titulo),
                    Param("@Descripcion", request.Descripcion),
                    Param("@NombreOriginal", request.NombreOriginal),
                    Param("@NombreAlmacenado", storedName),
                    Param("@Extension", extension),
                    Param("@TipoMime", request.TipoMime),
                    Param("@TamanoBytes", request.TamanoBytes),
                    Param("@ModoAlmacenamiento", mode),
                    new SqlParameter("@ContenidoArchivo", SqlDbType.VarBinary, -1) { Value = (object?)contentForDatabase ?? DBNull.Value },
                    Param("@RutaRelativa", relativePath),
                    Param("@IdUser", usuarioActual));

                var documentoId = GetResultId(result, idParam);
                var response = await ObtenerDocumentoAsync(documentoId);

                return new PagedResult<DocumentoResponse>
                {
                    Success = true,
                    Message = GetResultMessage(result, "Documento guardado correctamente"),
                    Code = "SUCCESS",
                    Data = response,
                    Items = response == null ? [] : [response],
                    TotalCount = response == null ? 0 : 1
                };
            }
            catch
            {
                if (!string.IsNullOrWhiteSpace(physicalPath) && File.Exists(physicalPath))
                    File.Delete(physicalPath);
                throw;
            }
        }

        public async Task<DocumentoDownloadResponse?> ObtenerContenidoAsync(long documentoId)
        {
            await using var command = await CreateCommandAsync("SIS.spDocumentoObtenerContenido", CommandType.StoredProcedure);
            command.Parameters.Add(Param("@PkidDocumento", documentoId));

            await using var reader = await command.ExecuteReaderAsync();
            if (!await reader.ReadAsync())
                return null;

            var response = new DocumentoDownloadResponse
            {
                PkidDocumento = GetInt64(reader, "PkidDocumento"),
                NombreOriginal = GetString(reader, "NombreOriginal"),
                NombreAlmacenado = GetString(reader, "NombreAlmacenado"),
                Extension = GetString(reader, "Extension"),
                TipoMime = GetString(reader, "TipoMime"),
                TamanoBytes = GetInt64(reader, "TamanoBytes"),
                ModoAlmacenamiento = GetString(reader, "ModoAlmacenamiento"),
                RutaRelativa = GetNullableString(reader, "RutaRelativa"),
                Contenido = GetBytes(reader, "ContenidoArchivo")
            };

            if (response.ModoAlmacenamiento.Equals("FILESYSTEM", StringComparison.OrdinalIgnoreCase))
            {
                if (string.IsNullOrWhiteSpace(response.RutaRelativa))
                    throw new InvalidOperationException("El documento no tiene ruta relativa configurada.");

                var physicalPath = GetSafePhysicalPath(response.RutaRelativa);
                if (!File.Exists(physicalPath))
                    throw new FileNotFoundException("No se encontro el archivo fisico del documento.", physicalPath);

                response.Contenido = await File.ReadAllBytesAsync(physicalPath);
            }

            return response;
        }

        public async Task<PagedResult<bool>> EliminarAsync(long documentoId, int usuarioActual)
        {
            await ExecuteResultJsonAsync(
                "SIS.spDocumentoEliminar",
                Param("@PkidDocumento", documentoId),
                Param("@IdUser", usuarioActual));

            return new PagedResult<bool>
            {
                Success = true,
                Message = "Documento eliminado correctamente",
                Code = "SUCCESS",
                Data = true,
                Items = [true],
                TotalCount = 1
            };
        }

        public async Task<PagedResult<DocumentoAnotacionResponse>> ObtenerAnotacionesAsync(long documentoId, bool incluirInactivos = false)
        {
            var items = new List<DocumentoAnotacionResponse>();
            await using var command = await CreateCommandAsync("SIS.spDocumentoAnotacionObtener", CommandType.StoredProcedure);
            command.Parameters.Add(Param("@FkidDocumento", documentoId));
            command.Parameters.Add(Param("@IncluirInactivos", incluirInactivos));

            await using var reader = await command.ExecuteReaderAsync();
            while (await reader.ReadAsync())
                items.Add(MapAnotacion(reader));

            return new PagedResult<DocumentoAnotacionResponse>
            {
                Success = true,
                Message = "Anotaciones obtenidas correctamente",
                Code = "SUCCESS",
                Items = items,
                TotalCount = items.Count
            };
        }

        public async Task<PagedResult<DocumentoAnotacionResponse>> CrearAnotacionAsync(DocumentoAnotacionCrearRequest request, int usuarioActual)
        {
            var idParam = new SqlParameter("@PkidDocumentoAnotacion", SqlDbType.BigInt)
            {
                Direction = ParameterDirection.InputOutput,
                Value = DBNull.Value
            };

            var result = await ExecuteResultJsonAsync(
                "SIS.spDocumentoAnotacionCrear",
                Param("@FkidDocumento", request.FkidDocumento),
                Param("@TipoAnotacion", request.TipoAnotacion),
                Param("@Comentario", request.Comentario),
                Param("@TextoSeleccionado", request.TextoSeleccionado),
                Param("@Pagina", request.Pagina),
                Param("@PosicionX", request.PosicionX),
                Param("@PosicionY", request.PosicionY),
                Param("@Ancho", request.Ancho),
                Param("@Alto", request.Alto),
                Param("@Color", request.Color),
                Param("@IdUser", usuarioActual),
                idParam);

            var anotacionId = GetResultId(result, idParam);
            var annotations = await ObtenerAnotacionesAsync(request.FkidDocumento);
            var item = annotations.Items.FirstOrDefault(x => x.PkidDocumentoAnotacion == anotacionId);

            return new PagedResult<DocumentoAnotacionResponse>
            {
                Success = true,
                Message = GetResultMessage(result, "Anotacion creada correctamente"),
                Code = "SUCCESS",
                Data = item,
                Items = item == null ? [] : [item],
                TotalCount = item == null ? 0 : 1
            };
        }

        public async Task<PagedResult<bool>> EliminarAnotacionAsync(long anotacionId, int usuarioActual)
        {
            await ExecuteResultJsonAsync(
                "SIS.spDocumentoAnotacionEliminar",
                Param("@PkidDocumentoAnotacion", anotacionId),
                Param("@IdUser", usuarioActual));

            return new PagedResult<bool>
            {
                Success = true,
                Message = "Anotacion eliminada correctamente",
                Code = "SUCCESS",
                Data = true,
                Items = [true],
                TotalCount = 1
            };
        }

        private async Task<DocumentoResponse?> ObtenerDocumentoAsync(long documentoId)
        {
            await using var command = await CreateCommandAsync("""
                SELECT TOP 1 *
                FROM SIS.Vw_DocumentoEntidad
                WHERE PkidDocumento = @PkidDocumento
                """, CommandType.Text);
            command.Parameters.Add(Param("@PkidDocumento", documentoId));

            await using var reader = await command.ExecuteReaderAsync();
            return await reader.ReadAsync() ? MapDocumento(reader) : null;
        }

        private async Task<JsonElement> ExecuteResultJsonAsync(string storedProcedure, params SqlParameter[] parameters)
        {
            await using var command = await CreateCommandAsync(storedProcedure, CommandType.StoredProcedure);
            foreach (var parameter in parameters)
                command.Parameters.Add(parameter);

            await using var reader = await command.ExecuteReaderAsync();
            if (!await reader.ReadAsync())
                throw new InvalidOperationException($"El procedimiento {storedProcedure} no regreso ResultJson.");

            var json = reader["ResultJson"]?.ToString();
            if (string.IsNullOrWhiteSpace(json))
                throw new InvalidOperationException($"El procedimiento {storedProcedure} regreso ResultJson vacio.");

            using var document = JsonDocument.Parse(json);
            var root = document.RootElement.Clone();
            var tipo = root.TryGetProperty("tipo", out var tipoProperty) ? tipoProperty.GetString() : string.Empty;
            if (!string.Equals(tipo, "OK", StringComparison.OrdinalIgnoreCase) &&
                !string.Equals(tipo, "SUCCESS", StringComparison.OrdinalIgnoreCase) &&
                !string.Equals(tipo, "EXITO", StringComparison.OrdinalIgnoreCase))
            {
                throw new InvalidOperationException(GetResultMessage(root, "Error en soporte documental"));
            }

            return root;
        }

        private async Task<SqlCommand> CreateCommandAsync(string commandText, CommandType commandType)
        {
            var connection = (SqlConnection)context.Database.GetDbConnection();
            if (connection.State != ConnectionState.Open)
                await connection.OpenAsync();

            return new SqlCommand(commandText, connection)
            {
                CommandType = commandType
            };
        }

        private void AddEntityParameters(SqlCommand command, DocumentoEntidadRequest request)
        {
            command.Parameters.Add(Param("@Modulo", request.Modulo));
            command.Parameters.Add(Param("@SubModulo", request.SubModulo));
            command.Parameters.Add(Param("@Controlador", request.Controlador));
            command.Parameters.Add(Param("@Servicio", request.Servicio));
            command.Parameters.Add(Param("@EntidadId", request.EntidadId));
            command.Parameters.Add(Param("@FkidEmpresaSis", request.FkidEmpresaSis));
        }

        private static SqlParameter Param(string name, object? value) => new(name, value ?? DBNull.Value);

        private static bool IsMissingDocumentSchema(SqlException ex)
            => ex.Number is 208 or 2812;

        private static DocumentoResumenResponse EmptySummary(DocumentoEntidadRequest request) => new()
        {
            Modulo = request.Modulo,
            SubModulo = request.SubModulo,
            Controlador = request.Controlador,
            Servicio = request.Servicio,
            EntidadId = request.EntidadId,
            FkidEmpresaSis = request.FkidEmpresaSis
        };

        private void ValidateUpload(DocumentoUploadRequest request)
        {
            if (request.EntidadId <= 0)
                throw new InvalidOperationException("EntidadId invalido.");

            if (request.Contenido.Length == 0)
                throw new InvalidOperationException("El archivo esta vacio.");

            var maxBytes = Math.Max(1, _settings.MaxFileSizeMB) * 1024L * 1024L;
            if (request.Contenido.LongLength > maxBytes)
                throw new InvalidOperationException($"El archivo supera el limite de {_settings.MaxFileSizeMB} MB.");

            var extension = NormalizeExtension(Path.GetExtension(request.NombreOriginal));
            var allowed = _settings.AllowedExtensions.Select(NormalizeExtension).ToHashSet(StringComparer.OrdinalIgnoreCase);
            if (!allowed.Contains(extension))
                throw new InvalidOperationException($"La extension {extension} no esta permitida.");
        }

        private static string NormalizeMode(string? value)
        {
            var mode = (value ?? "DATABASE").Trim().ToUpperInvariant();
            return mode == "FILESYSTEM" ? "FILESYSTEM" : "DATABASE";
        }

        private static string NormalizeExtension(string? value)
        {
            var extension = (value ?? string.Empty).Trim().ToLowerInvariant();
            if (string.IsNullOrWhiteSpace(extension))
                throw new InvalidOperationException("El archivo no tiene extension.");
            return extension.StartsWith('.') ? extension : $".{extension}";
        }

        private string BuildRelativePath(DocumentoUploadRequest request, string storedName)
        {
            var module = SafeSegment(request.Modulo);
            var subModule = SafeSegment(request.SubModulo ?? "General");
            return Path.Combine(module, subModule, request.EntidadId.ToString(), DateTime.UtcNow.ToString("yyyyMM"), storedName);
        }

        private string GetSafePhysicalPath(string relativePath)
        {
            var basePath = _settings.BasePath;
            if (string.IsNullOrWhiteSpace(basePath))
                basePath = "Documentos";

            if (!Path.IsPathRooted(basePath))
                basePath = Path.Combine(AppContext.BaseDirectory, basePath);

            var root = Path.GetFullPath(basePath);
            var fullPath = Path.GetFullPath(Path.Combine(root, relativePath));
            if (!fullPath.StartsWith(root, StringComparison.OrdinalIgnoreCase))
                throw new InvalidOperationException("Ruta de documento fuera del repositorio permitido.");

            return fullPath;
        }

        private static string SafeSegment(string value)
        {
            var invalid = Path.GetInvalidFileNameChars();
            var cleaned = new string(value.Select(ch => invalid.Contains(ch) ? '_' : ch).ToArray());
            return string.IsNullOrWhiteSpace(cleaned) ? "General" : cleaned.Trim();
        }

        private static DocumentoResponse MapDocumento(IDataRecord reader) => new()
        {
            PkidDocumento = GetInt64(reader, "PkidDocumento"),
            Modulo = GetString(reader, "Modulo"),
            SubModulo = GetNullableString(reader, "SubModulo"),
            Controlador = GetNullableString(reader, "Controlador"),
            Servicio = GetNullableString(reader, "Servicio"),
            EntidadId = GetInt64(reader, "EntidadId"),
            FkidEmpresaSis = GetNullableInt(reader, "FkidEmpresaSis"),
            Titulo = GetNullableString(reader, "Titulo"),
            Descripcion = GetNullableString(reader, "Descripcion"),
            NombreOriginal = GetString(reader, "NombreOriginal"),
            NombreAlmacenado = GetString(reader, "NombreAlmacenado"),
            Extension = GetString(reader, "Extension"),
            TipoMime = GetString(reader, "TipoMime"),
            TamanoBytes = GetInt64(reader, "TamanoBytes"),
            ModoAlmacenamiento = GetString(reader, "ModoAlmacenamiento"),
            RutaRelativa = GetNullableString(reader, "RutaRelativa"),
            HashSha256Hex = GetNullableString(reader, "HashSha256Hex"),
            VersionDocumento = GetInt32(reader, "VersionDocumento"),
            EsImagen = GetBool(reader, "EsImagen"),
            EsPdf = GetBool(reader, "EsPdf"),
            Activo = GetBool(reader, "Activo"),
            CT_CreatedBy = GetInt32(reader, "CT_CreatedBy"),
            CT_CreatedDate = GetDateTime(reader, "CT_CreatedDate"),
            CT_ModifiedBy = GetNullableInt(reader, "CT_ModifiedBy"),
            CT_ModifiedDate = GetNullableDateTime(reader, "CT_ModifiedDate")
        };

        private static DocumentoAnotacionResponse MapAnotacion(IDataRecord reader) => new()
        {
            PkidDocumentoAnotacion = GetInt64(reader, "PkidDocumentoAnotacion"),
            FkidDocumento = GetInt64(reader, "FkidDocumento"),
            TipoAnotacion = GetString(reader, "TipoAnotacion"),
            TipoAnotacionDescripcion = GetString(reader, "TipoAnotacionDescripcion"),
            Comentario = GetNullableString(reader, "Comentario"),
            TextoSeleccionado = GetNullableString(reader, "TextoSeleccionado"),
            Pagina = GetNullableInt(reader, "Pagina"),
            PosicionX = GetNullableDecimal(reader, "PosicionX"),
            PosicionY = GetNullableDecimal(reader, "PosicionY"),
            Ancho = GetNullableDecimal(reader, "Ancho"),
            Alto = GetNullableDecimal(reader, "Alto"),
            Color = GetString(reader, "Color"),
            Activo = GetBool(reader, "Activo"),
            CT_CreatedBy = GetInt32(reader, "CT_CreatedBy"),
            CT_CreatedDate = GetDateTime(reader, "CT_CreatedDate")
        };

        private static string GetResultMessage(JsonElement result, string fallback)
            => result.TryGetProperty("mensaje", out var message) ? message.GetString() ?? fallback : fallback;

        private static long GetResultId(JsonElement result, SqlParameter idParam)
        {
            if (idParam.Value != DBNull.Value && idParam.Value != null)
                return Convert.ToInt64(idParam.Value);

            if (result.TryGetProperty("id", out var idProperty) && idProperty.TryGetInt64(out var id))
                return id;

            throw new InvalidOperationException("No se pudo obtener el id generado por el procedimiento.");
        }

        private static int Ordinal(IDataRecord reader, string name) => reader.GetOrdinal(name);
        private static bool IsNull(IDataRecord reader, string name) => reader.IsDBNull(Ordinal(reader, name));
        private static string GetString(IDataRecord reader, string name) => IsNull(reader, name) ? string.Empty : Convert.ToString(reader[name]) ?? string.Empty;
        private static string? GetNullableString(IDataRecord reader, string name) => IsNull(reader, name) ? null : Convert.ToString(reader[name]);
        private static int GetInt32(IDataRecord reader, string name) => IsNull(reader, name) ? 0 : Convert.ToInt32(reader[name]);
        private static int? GetNullableInt(IDataRecord reader, string name) => IsNull(reader, name) ? null : Convert.ToInt32(reader[name]);
        private static long GetInt64(IDataRecord reader, string name) => IsNull(reader, name) ? 0 : Convert.ToInt64(reader[name]);
        private static bool GetBool(IDataRecord reader, string name) => !IsNull(reader, name) && Convert.ToBoolean(reader[name]);
        private static DateTime GetDateTime(IDataRecord reader, string name) => IsNull(reader, name) ? DateTime.MinValue : Convert.ToDateTime(reader[name]);
        private static DateTime? GetNullableDateTime(IDataRecord reader, string name) => IsNull(reader, name) ? null : Convert.ToDateTime(reader[name]);
        private static decimal? GetNullableDecimal(IDataRecord reader, string name) => IsNull(reader, name) ? null : Convert.ToDecimal(reader[name]);
        private static byte[] GetBytes(IDataRecord reader, string name) => IsNull(reader, name) ? [] : (byte[])reader[name];
    }
}
