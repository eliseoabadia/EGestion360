using EG.Domain.DTOs.Responses.Contabilidad;

namespace EG.Application.Interfaces.Contabilidad;

public interface IMatrizConversionValidationService
{
    Task<string?> ValidateAsync(MatrizConversionResponse request);
}
