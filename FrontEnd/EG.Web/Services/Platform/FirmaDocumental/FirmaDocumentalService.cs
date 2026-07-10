using EG.Common.Helper;
using EG.Web.Contracts.Platform.FirmaDocumental;
using EG.Web.Models;
using EG.Web.Models.Platform.FirmaDocumental;
using EG.Web.Services.Shared;
using Microsoft.AspNetCore.Components.Forms;
using Microsoft.Extensions.Logging;
using Microsoft.JSInterop;

namespace EG.Web.Services.Platform.FirmaDocumental
{
    public class FirmaDocumentalService(
        IConfiguration configuration,
        HttpClient httpClient,
        IJSRuntime jsRuntime,
        ApplicationInstance application,
        ILogger<FirmaDocumentalService> logger)
        : BaseService(httpClient, jsRuntime, application, configuration, logger), IFirmaDocumentalService
    {
        private const long MaxCertificateFileSize = 5 * 1024 * 1024;
        private const string Endpoint = "api/FirmaDocumental";

        public async Task<ApiResponse<FirmaProveedorResponse>> GetProvidersAsync()
            => await GetAsync<ApiResponse<FirmaProveedorResponse>>($"{Endpoint}/proveedores", useBaseUrl: false)
                ?? new ApiResponse<FirmaProveedorResponse>();

        public async Task<ApiResponse<FirmaCertificadoUsuarioResponse>> GetCertificatesAsync(int? empresaId = null)
        {
            var query = empresaId.HasValue ? $"?empresaId={empresaId.Value}" : string.Empty;
            return await GetAsync<ApiResponse<FirmaCertificadoUsuarioResponse>>($"{Endpoint}/certificados{query}", useBaseUrl: false)
                ?? new ApiResponse<FirmaCertificadoUsuarioResponse>();
        }

        public async Task<ApiResponse<FirmaCertificadoUsuarioResponse>> UploadCertificateAsync(string alias, string password, int? empresaId, IBrowserFile file)
        {
            try
            {
                var request = await CreateAuthenticatedRequestAsync(HttpMethod.Post, $"{_baseUrl}{Endpoint}/certificados");
                using var form = new MultipartFormDataContent();
                MultipartApiHelper.AddString(form, "Alias", alias);
                MultipartApiHelper.AddString(form, "Password", password);
                MultipartApiHelper.AddString(form, "FkidEmpresaSis", empresaId?.ToString());
                MultipartApiHelper.AddFile(form, "File", file, MaxCertificateFileSize);
                request.Content = form;

                return await MultipartApiHelper.SendAsync<FirmaCertificadoUsuarioResponse>(_httpClient, request, _jsonOptions, _logger);
            }
            catch (Exception ex)
            {
                return MultipartApiHelper.Failure<FirmaCertificadoUsuarioResponse>(ex, _logger);
            }
        }
    }
}
