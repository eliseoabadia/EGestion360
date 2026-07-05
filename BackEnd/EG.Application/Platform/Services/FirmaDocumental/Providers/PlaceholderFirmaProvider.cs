using EG.Application.Interfaces.FirmaDocumental;
using EG.Application.Services.FirmaDocumental.Models;

namespace EG.Application.Services.FirmaDocumental.Providers
{
    public sealed class PlaceholderFirmaProvider(
        string codigo,
        string nombre,
        string descripcion,
        bool requiereCertificado) : IFirmaDocumentalProvider
    {
        public string Codigo => codigo;
        public string Nombre => nombre;
        public bool Disponible => false;
        public bool RequiereCertificado => requiereCertificado;
        public bool RequierePassword => requiereCertificado;
        public string Descripcion => descripcion;

        public Task<FirmaProviderResult> FirmarAsync(FirmaProviderRequest request, CancellationToken cancellationToken = default)
        {
            throw new InvalidOperationException($"El proveedor {Codigo} todavia no esta configurado.");
        }
    }
}
