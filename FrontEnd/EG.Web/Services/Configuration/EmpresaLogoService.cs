using EG.Common.Helper;
using EG.Domain.DTOs.Responses.General;
using EG.Web.Contracts.Configuration;
using EG.Web.Models;
using EG.Web.Services.Shared;
using Microsoft.AspNetCore.Components.Forms;
using Microsoft.JSInterop;

namespace EG.Web.Services.Configuration
{
    public class EmpresaLogoService(
        IConfiguration configuration,
        HttpClient httpClient,
        IJSRuntime jsRuntime,
        ApplicationInstance application)
        : BaseService(httpClient, jsRuntime, application, configuration), IEmpresaLogoService
    {
        private const long MaxLogoSize = 5 * 1024 * 1024;
        private const string Endpoint = "api/Empresa";

        public async Task<ApiResponse<EmpresaResponse>> UploadAsync(int empresaId, IBrowserFile file)
        {
            try
            {
                var request = await CreateAuthenticatedRequestAsync(HttpMethod.Post, $"{_baseUrl}{Endpoint}/{empresaId}/logo");
                using var form = new MultipartFormDataContent();
                MultipartApiHelper.AddFile(form, "File", file, MaxLogoSize);
                request.Content = form;

                return await MultipartApiHelper.SendAsync<EmpresaResponse>(_httpClient, request, _jsonOptions);
            }
            catch (Exception ex)
            {
                return MultipartApiHelper.Failure<EmpresaResponse>(ex);
            }
        }
    }
}
