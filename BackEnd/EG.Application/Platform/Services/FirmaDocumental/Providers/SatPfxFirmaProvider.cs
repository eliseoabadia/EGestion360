using System.Security.Cryptography;
using System.Security.Cryptography.X509Certificates;
using System.Text.Json;
using EG.Application.Interfaces.FirmaDocumental;
using EG.Application.Services.FirmaDocumental.Models;

namespace EG.Application.Services.FirmaDocumental.Providers
{
    public sealed class SatPfxFirmaProvider : IFirmaDocumentalProvider
    {
        public string Codigo => "SAT_PFX";
        public string Nombre => "SAT / e.firma PFX";
        public bool Disponible => true;
        public bool RequiereCertificado => true;
        public bool RequierePassword => true;
        public string Descripcion => "Firma tecnica del hash documental con certificado PFX del usuario. La contrasena se pide al momento y no se almacena.";

        public Task<FirmaProviderResult> FirmarAsync(FirmaProviderRequest request, CancellationToken cancellationToken = default)
        {
            if (request.CertificadoPfx == null || request.CertificadoPfx.Length == 0)
                throw new InvalidOperationException("El certificado PFX es requerido para firma SAT.");

            if (string.IsNullOrWhiteSpace(request.Password))
                throw new InvalidOperationException("La contrasena del certificado es requerida para firmar.");

            using var certificate = X509CertificateLoader.LoadPkcs12(
                request.CertificadoPfx,
                request.Password,
                X509KeyStorageFlags.EphemeralKeySet);

            using var rsa = certificate.GetRSAPrivateKey();
            if (rsa == null)
                throw new InvalidOperationException("El certificado no contiene llave privada RSA.");

            var documentHash = Convert.FromHexString(request.HashDocumentoSha256);
            var signature = rsa.SignHash(documentHash, HashAlgorithmName.SHA256, RSASignaturePadding.Pkcs1);
            var evidence = new
            {
                Provider = Codigo,
                certificate.Subject,
                certificate.SerialNumber,
                Thumbprint = certificate.GetCertHashString(HashAlgorithmName.SHA256),
                certificate.NotBefore,
                certificate.NotAfter,
                request.HashDocumentoSha256,
                SignatureAlgorithm = "RSA-SHA256-PKCS1",
                SignedAtUtc = DateTime.UtcNow
            };

            return Task.FromResult(new FirmaProviderResult
            {
                Estado = "FIRMADO",
                FirmaBase64 = Convert.ToBase64String(signature),
                AlgoritmoFirma = "RSA-SHA256-PKCS1",
                EvidenciaJson = JsonSerializer.Serialize(evidence)
            });
        }
    }
}
