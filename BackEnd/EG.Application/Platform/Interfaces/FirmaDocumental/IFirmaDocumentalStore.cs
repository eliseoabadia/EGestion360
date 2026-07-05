using EG.Application.Services.FirmaDocumental.Models;

namespace EG.Application.Interfaces.FirmaDocumental
{
    public interface IFirmaDocumentalStore
    {
        Task SaveCertificateAsync(FirmaCertificateRecord record, CancellationToken cancellationToken = default);
        Task<IReadOnlyList<FirmaCertificateRecord>> GetCertificatesAsync(int usuarioId, int? empresaId, CancellationToken cancellationToken = default);
        Task<FirmaCertificateRecord?> GetCertificateAsync(Guid certificadoId, int usuarioId, CancellationToken cancellationToken = default);
        Task SaveSignatureAsync(FirmaDocumentRecord record, CancellationToken cancellationToken = default);
        Task<IReadOnlyList<FirmaDocumentRecord>> GetSignaturesAsync(long? documentoId, string? entidadOrigen, long? registroOrigenId, int? empresaId, CancellationToken cancellationToken = default);
        Task ProtectDocumentAsync(FirmaProtectedDocumentRecord record, CancellationToken cancellationToken = default);
        Task<FirmaProtectedDocumentRecord?> GetProtectedDocumentAsync(long documentoId, CancellationToken cancellationToken = default);
        Task<IReadOnlyDictionary<long, FirmaProtectedDocumentRecord>> GetProtectedDocumentsAsync(IEnumerable<long> documentoIds, CancellationToken cancellationToken = default);
    }
}
