using System.Security.Cryptography;
using System.Security.Cryptography.X509Certificates;
using System.Text.RegularExpressions;
using EG.Application.Interfaces.FirmaDocumental;
using EG.Application.Interfaces.SoporteDocumental;
using EG.Application.Services.FirmaDocumental.Models;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.FirmaDocumental;
using EG.Domain.DTOs.Responses.FirmaDocumental;
using EG.Domain.Platform.Settings;
using Microsoft.Extensions.Options;

namespace EG.Application.Services.FirmaDocumental
{
    public sealed class FirmaDocumentalAppService(
        IFirmaDocumentalStore store,
        IFirmaCertificateProtector protector,
        ISoporteDocumentalAppService soporteDocumental,
        IEnumerable<IFirmaDocumentalProvider> providers,
        IOptions<FirmaDocumentalSettings> options) : IFirmaDocumentalAppService
    {
        private readonly Dictionary<string, IFirmaDocumentalProvider> _providers = providers
            .GroupBy(x => x.Codigo, StringComparer.OrdinalIgnoreCase)
            .ToDictionary(x => x.Key, x => x.First(), StringComparer.OrdinalIgnoreCase);

        private readonly FirmaDocumentalSettings _settings = options.Value;

        public Task<PagedResult<FirmaProveedorResponse>> ObtenerProveedoresAsync()
        {
            var enabled = _settings.EnabledProviders
                .ToHashSet(StringComparer.OrdinalIgnoreCase);
            var items = _providers.Values
                .OrderByDescending(x => enabled.Contains(x.Codigo) && x.Disponible)
                .ThenBy(x => x.Nombre)
                .Select(x => new FirmaProveedorResponse
                {
                    Codigo = x.Codigo,
                    Nombre = x.Nombre,
                    Disponible = x.Disponible && enabled.Contains(x.Codigo),
                    RequiereCertificado = x.RequiereCertificado,
                    RequierePassword = x.RequierePassword,
                    Descripcion = x.Descripcion
                })
                .ToList();

            return Task.FromResult(SuccessList("Proveedores de firma obtenidos.", items));
        }

        public async Task<PagedResult<FirmaCertificadoUsuarioResponse>> RegistrarCertificadoAsync(FirmaCertificadoUsuarioUploadRequest request, int usuarioActual)
        {
            ValidateCertificateUpload(request);

            using var certificate = X509CertificateLoader.LoadPkcs12(
                request.Contenido,
                request.Password,
                X509KeyStorageFlags.EphemeralKeySet);

            if (!certificate.HasPrivateKey)
                throw new InvalidOperationException("El PFX no contiene llave privada.");

            var record = new FirmaCertificateRecord
            {
                CertificadoId = Guid.NewGuid(),
                UsuarioId = usuarioActual,
                FkidEmpresaSis = request.FkidEmpresaSis,
                Alias = string.IsNullOrWhiteSpace(request.Alias) ? request.NombreOriginal : request.Alias.Trim(),
                TipoCertificado = "SAT_PFX",
                Formato = "PFX",
                RFC = ExtractRfc(certificate.Subject),
                Titular = certificate.GetNameInfo(X509NameType.SimpleName, false),
                NumeroSerie = certificate.SerialNumber,
                HuellaSha256 = certificate.GetCertHashString(HashAlgorithmName.SHA256),
                VigenteDesde = certificate.NotBefore,
                VigenteHasta = certificate.NotAfter,
                Activo = true,
                FechaRegistro = DateTime.UtcNow,
                ProtectedPfxBase64 = protector.Protect(request.Contenido)
            };

            await store.SaveCertificateAsync(record);

            return Success("Certificado registrado y cifrado correctamente. La contrasena no fue almacenada.", ToCertificateResponse(record));
        }

        public async Task<PagedResult<FirmaCertificadoUsuarioResponse>> ObtenerCertificadosAsync(int usuarioActual, int? empresaId)
        {
            var records = await store.GetCertificatesAsync(usuarioActual, empresaId);
            var items = records.Select(ToCertificateResponse).ToList();
            return SuccessList("Certificados del usuario obtenidos.", items);
        }

        public async Task<PagedResult<FirmaDocumentoResponse>> FirmarDocumentoAsync(FirmaDocumentoCrearRequest request, int usuarioActual)
        {
            if (request.DocumentoId <= 0)
                throw new InvalidOperationException("El documento es requerido para firmar.");

            var providerKey = string.IsNullOrWhiteSpace(request.Proveedor)
                ? "INTERNA"
                : request.Proveedor.Trim();

            if (!_providers.TryGetValue(providerKey, out var provider))
                throw new InvalidOperationException($"Proveedor de firma no soportado: {providerKey}.");

            var enabled = _settings.EnabledProviders.Contains(provider.Codigo, StringComparer.OrdinalIgnoreCase);
            if (!provider.Disponible || !enabled)
                throw new InvalidOperationException($"Proveedor de firma no disponible: {provider.Codigo}.");

            var empresaId = request.FkidEmpresaSis
                ?? throw new InvalidOperationException("La empresa activa es requerida para firmar.");
            var document = await soporteDocumental.ObtenerContenidoAsync(request.DocumentoId, empresaId)
                ?? throw new InvalidOperationException("El documento no existe en soporte documental.");

            var hashHex = Convert.ToHexString(SHA256.HashData(document.Contenido));
            FirmaCertificateRecord? certificate = null;
            byte[]? pfxBytes = null;

            if (provider.RequiereCertificado)
            {
                if (!request.CertificadoId.HasValue)
                    throw new InvalidOperationException("El certificado del usuario es requerido para este proveedor.");

                certificate = await store.GetCertificateAsync(request.CertificadoId.Value, usuarioActual)
                    ?? throw new InvalidOperationException("El certificado no existe o no pertenece al usuario autenticado.");
                pfxBytes = protector.Unprotect(certificate.ProtectedPfxBase64);
            }

            var providerResult = await provider.FirmarAsync(new FirmaProviderRequest
            {
                DocumentoContenido = document.Contenido,
                HashDocumentoSha256 = hashHex,
                UsuarioFirmanteId = usuarioActual,
                Password = request.Password,
                Motivo = request.Motivo,
                Certificado = certificate,
                CertificadoPfx = pfxBytes
            });

            CryptographicOperations.ZeroMemory(pfxBytes ?? []);

            var record = new FirmaDocumentRecord
            {
                FirmaId = Guid.NewGuid(),
                DocumentoId = request.DocumentoId,
                Proveedor = provider.Codigo,
                Estado = providerResult.Estado,
                EntidadOrigen = request.EntidadOrigen,
                RegistroOrigenId = request.RegistroOrigenId,
                FkidEmpresaSis = request.FkidEmpresaSis,
                UsuarioFirmanteId = usuarioActual,
                CertificadoId = certificate?.CertificadoId,
                CertificadoSerie = certificate?.NumeroSerie,
                CertificadoTitular = certificate?.Titular,
                CertificadoRFC = certificate?.RFC,
                HashDocumentoSha256 = hashHex,
                FirmaBase64 = providerResult.FirmaBase64,
                AlgoritmoFirma = providerResult.AlgoritmoFirma,
                Motivo = request.Motivo,
                EvidenciaJson = providerResult.EvidenciaJson,
                FechaFirmaUtc = DateTime.UtcNow
            };

            await store.SaveSignatureAsync(record);
            return Success("Documento firmado y evidencia guardada.", ToSignatureResponse(record));
        }

        public async Task<PagedResult<FirmaDocumentoResponse>> ObtenerFirmasAsync(FirmaDocumentoEntidadRequest request, int usuarioActual)
        {
            var records = await store.GetSignaturesAsync(
                request.DocumentoId,
                request.EntidadOrigen,
                request.RegistroOrigenId,
                request.FkidEmpresaSis);
            var items = records.Select(ToSignatureResponse).ToList();
            return SuccessList("Firmas documentales obtenidas.", items);
        }

        private void ValidateCertificateUpload(FirmaCertificadoUsuarioUploadRequest request)
        {
            if (request.Contenido.Length == 0 || request.TamanoBytes <= 0)
                throw new InvalidOperationException("El certificado esta vacio.");

            if (string.IsNullOrWhiteSpace(request.Password))
                throw new InvalidOperationException("La contrasena del PFX es requerida.");

            var maxBytes = Math.Max(1, _settings.MaxCertificateSizeMB) * 1024L * 1024L;
            if (request.TamanoBytes > maxBytes || request.Contenido.LongLength > maxBytes)
                throw new InvalidOperationException($"El certificado supera el limite de {_settings.MaxCertificateSizeMB} MB.");

            var extension = NormalizeExtension(request.Extension);
            var allowed = _settings.AllowedCertificateExtensions
                .Select(NormalizeExtension)
                .ToHashSet(StringComparer.OrdinalIgnoreCase);
            if (!allowed.Contains(extension))
                throw new InvalidOperationException($"La extension {extension} no esta permitida para certificados.");
        }

        private static FirmaCertificadoUsuarioResponse ToCertificateResponse(FirmaCertificateRecord record) => new()
        {
            CertificadoId = record.CertificadoId,
            UsuarioId = record.UsuarioId,
            FkidEmpresaSis = record.FkidEmpresaSis,
            Alias = record.Alias,
            TipoCertificado = record.TipoCertificado,
            Formato = record.Formato,
            RFC = record.RFC,
            Titular = record.Titular,
            NumeroSerie = record.NumeroSerie,
            HuellaSha256 = record.HuellaSha256,
            VigenteDesde = record.VigenteDesde,
            VigenteHasta = record.VigenteHasta,
            Activo = record.Activo,
            Vencido = record.VigenteHasta < DateTime.Now,
            FechaRegistro = record.FechaRegistro
        };

        private static FirmaDocumentoResponse ToSignatureResponse(FirmaDocumentRecord record) => new()
        {
            FirmaId = record.FirmaId,
            DocumentoId = record.DocumentoId,
            Proveedor = record.Proveedor,
            Estado = record.Estado,
            EntidadOrigen = record.EntidadOrigen,
            RegistroOrigenId = record.RegistroOrigenId,
            FkidEmpresaSis = record.FkidEmpresaSis,
            UsuarioFirmanteId = record.UsuarioFirmanteId,
            CertificadoId = record.CertificadoId,
            CertificadoSerie = record.CertificadoSerie,
            CertificadoTitular = record.CertificadoTitular,
            CertificadoRFC = record.CertificadoRFC,
            HashDocumentoSha256 = record.HashDocumentoSha256,
            FirmaBase64 = record.FirmaBase64,
            AlgoritmoFirma = record.AlgoritmoFirma,
            Motivo = record.Motivo,
            EvidenciaJson = record.EvidenciaJson,
            FechaFirmaUtc = record.FechaFirmaUtc
        };

        private static string NormalizeExtension(string? extension)
        {
            if (string.IsNullOrWhiteSpace(extension))
                return string.Empty;

            extension = extension.Trim().ToLowerInvariant();
            return extension.StartsWith('.') ? extension : $".{extension}";
        }

        private static string ExtractRfc(string subject)
        {
            var match = Regex.Match(subject, @"[A-Z&]{3,4}\d{6}[A-Z0-9]{3}", RegexOptions.IgnoreCase);
            return match.Success ? match.Value.ToUpperInvariant() : string.Empty;
        }

        private static PagedResult<T> Success<T>(string message, T item)
            where T : class
        {
            return new PagedResult<T>
            {
                Success = true,
                Code = "SUCCESS",
                Message = message,
                Data = item,
                Items = [item],
                TotalCount = 1
            };
        }

        private static PagedResult<T> SuccessList<T>(string message, IList<T> items)
        {
            return new PagedResult<T>
            {
                Success = true,
                Code = "SUCCESS",
                Message = message,
                Items = items,
                TotalCount = items.Count
            };
        }
    }
}
