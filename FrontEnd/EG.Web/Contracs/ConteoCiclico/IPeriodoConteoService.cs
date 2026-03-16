using EG.Web.Models.ConteoCiclico;
using EG.Web.Models;
using MudBlazor;

namespace EG.Web.Contracs.ConteoCiclico
{
    public interface IPeriodoConteoService : IGenericCrudService<PeriodoConteoResponse>
    {
        Task<ApiResponse<bool>> CambiarEstatusAsync(int id, int estatusId);
        Task<ApiResponse<bool>> CerrarPeriodoAsync(int id);
        Task<ApiResponse<List<PeriodoConteoResponse>>> GetMisPeriodosAsync(int usuarioId);
    }
}