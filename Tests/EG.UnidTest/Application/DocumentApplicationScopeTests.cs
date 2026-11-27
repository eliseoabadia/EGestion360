using EG.Application.Services.SoporteDocumental;
using EG.Business.Interfaces;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.SoporteDocumental;
using EG.Domain.DTOs.Responses.SoporteDocumental;
using EG.UnidTest.Support;

namespace EG.UnidTest.Application;

public sealed class DocumentApplicationScopeTests
{
    [Fact]
    public async Task ApplicationReplacesClientIdentityAndCompanyBeforeCallingBusiness()
    {
        var business = new RecordingBusiness();
        var application = new SoporteDocumentalAppService(business, new FixedUserContext(42, 7));
        var request = new DocumentoUploadRequest { FkidEmpresaSis = 999 };

        await application.GuardarAsync(request, 999);
        Assert.Equal((42, 7), business.Scope);
        await application.EliminarAsync(10, 999, 999);
        Assert.Equal((42, 7), business.Scope);
        await application.ObtenerContenidoAsync(10, 999);
        Assert.Equal(7, business.Scope.Company);
    }

    private sealed class RecordingBusiness : ISoporteDocumentalService
    {
        public (int Actor, int? Company) Scope { get; private set; }
        public Task<PagedResult<DocumentoResponse>> GuardarAsync(DocumentoUploadRequest request, int usuarioActual)
        {
            Scope = (usuarioActual, request.FkidEmpresaSis);
            return Task.FromResult(new PagedResult<DocumentoResponse>());
        }
        public Task<PagedResult<bool>> EliminarAsync(long documentoId, int usuarioActual, int empresaId)
        {
            Scope = (usuarioActual, empresaId);
            return Task.FromResult(new PagedResult<bool>());
        }
        public Task<DocumentoDownloadResponse?> ObtenerContenidoAsync(long documentoId, int empresaId)
        {
            Scope = (Scope.Actor, empresaId);
            return Task.FromResult<DocumentoDownloadResponse?>(null);
        }
        public Task<PagedResult<DocumentoResponse>> ObtenerPorEntidadAsync(DocumentoEntidadRequest request) => throw new NotSupportedException();
        public Task<PagedResult<DocumentoResumenResponse>> ObtenerResumenAsync(DocumentoEntidadRequest request) => throw new NotSupportedException();
        public Task<PagedResult<DocumentoAnotacionResponse>> ObtenerAnotacionesAsync(long documentoId, int empresaId, bool incluirInactivos = false) => throw new NotSupportedException();
        public Task<PagedResult<DocumentoAnotacionResponse>> CrearAnotacionAsync(DocumentoAnotacionCrearRequest request, int usuarioActual, int empresaId) => throw new NotSupportedException();
        public Task<PagedResult<bool>> EliminarAnotacionAsync(long anotacionId, int usuarioActual, int empresaId) => throw new NotSupportedException();
    }
}
