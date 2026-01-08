using EG.Common.Helper;
using EG.Web.Contracs.Configuration;
using EG.Web.Models.Configuration;
using Microsoft.JSInterop;

namespace EG.Web.Services
{
    public class EmpresaService : BaseService, IEmpresaService
    {
        public EmpresaService(HttpClient httpClient, IJSRuntime jsRuntime, ApplicationInstance application)
            : base(httpClient, jsRuntime, application)
        {
        }

        public async Task<List<EmpresaResponse>> GetEmpresa()
        {
            if (!IsClientSide())
                return new List<EmpresaResponse>();

            var token = await GetTokenAsync();
            if (string.IsNullOrEmpty(token))
                return new List<EmpresaResponse>();

            var result = await GetAsync<List<EmpresaResponse>>("api/Empresa/");
            return result ?? new List<EmpresaResponse>();
        }
    }
}