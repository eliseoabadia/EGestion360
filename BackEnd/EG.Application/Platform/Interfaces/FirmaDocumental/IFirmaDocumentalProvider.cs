using EG.Application.Services.FirmaDocumental.Models;

namespace EG.Application.Interfaces.FirmaDocumental
{
    public interface IFirmaDocumentalProvider
    {
        string Codigo { get; }
        string Nombre { get; }
        bool Disponible { get; }
        bool RequiereCertificado { get; }
        bool RequierePassword { get; }
        string Descripcion { get; }

        Task<FirmaProviderResult> FirmarAsync(FirmaProviderRequest request, CancellationToken cancellationToken = default);
    }
}
