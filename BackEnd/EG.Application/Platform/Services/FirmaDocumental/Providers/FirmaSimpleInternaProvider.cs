using System.Text.Json;
using EG.Application.Interfaces.FirmaDocumental;
using EG.Application.Services.FirmaDocumental.Models;

namespace EG.Application.Services.FirmaDocumental.Providers
{
    public sealed class FirmaSimpleInternaProvider : IFirmaDocumentalProvider
    {
        public string Codigo => "INTERNA";
        public string Nombre => "Firma interna";
        public bool Disponible => true;
        public bool RequiereCertificado => false;
        public bool RequierePassword => false;
        public string Descripcion => "Aprobacion interna con usuario autenticado, fecha, hash del documento y evidencia de operacion.";

        public Task<FirmaProviderResult> FirmarAsync(FirmaProviderRequest request, CancellationToken cancellationToken = default)
        {
            var evidence = new
            {
                Provider = Codigo,
                request.UsuarioFirmanteId,
                request.HashDocumentoSha256,
                request.Motivo,
                SignedAtUtc = DateTime.UtcNow
            };

            return Task.FromResult(new FirmaProviderResult
            {
                Estado = "FIRMADO",
                AlgoritmoFirma = "INTERNAL-AUDIT-HASH",
                EvidenciaJson = JsonSerializer.Serialize(evidence)
            });
        }
    }
}
