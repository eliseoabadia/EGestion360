

using EG.Web.Models.Configuration;

namespace EG.Web.Contracs.Configuration
{
    public interface IEmpresaService
    {
        Task<List<EmpresaResponse>> GetEmpresa();
    }
}
