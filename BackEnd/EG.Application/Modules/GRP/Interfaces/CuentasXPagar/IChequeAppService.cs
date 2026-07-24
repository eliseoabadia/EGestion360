using EG.Application.Interfaces.Adquisicion;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Responses.CuentasXPagar;

namespace EG.Application.Interfaces.CuentasXPagar;

public interface IChequeAppService : IAdquisicionCrudAppService<ChequeResponse>
{
    Task<PagedResult<ChequeResponse>> RegresarASolicitudSuficienciaAsync(int id, string motivo);
}
