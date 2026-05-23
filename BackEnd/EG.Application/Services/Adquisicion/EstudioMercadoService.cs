using EG.Application.Interfaces.Adquisicion;
using EG.Business.Services;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.Adquisicion;
using EG.Domain.DTOs.Responses.Adquisicion;
using EG.Infraestructure.Models;
using Microsoft.EntityFrameworkCore;

namespace EG.Application.Services.Adquisicion
{
    public class EstudioMercadoService
        : AdquisicionCrudAppService<EstudioMercado, VwEstudioMercado, EstudioMercadoDto, EstudioMercadoResponse>,
            IEstudioMercadoService
    {
        private readonly EGestionContext _context;

        public EstudioMercadoService(
            GenericService<EstudioMercado, EstudioMercadoDto, EstudioMercadoResponse> service,
            GenericService<VwEstudioMercado, EstudioMercadoDto, EstudioMercadoResponse> serviceView,
            EGestionContext context)
            : base(
                service,
                serviceView,
                "PkidEstudioMercado",
                "Estudio de mercado",
                (dto, id) => dto.PkidEstudioMercado = id)
        {
            _context = context;
        }

        public override Task<PagedResult<EstudioMercadoResponse>> CreateAsync(EstudioMercadoResponse response, int usuarioActual)
        {
            Normalize(response);
            var validation = Validate(response);
            return validation ?? SaveWithStoredProcedureAsync(1, null, response, usuarioActual);
        }

        public override Task<PagedResult<EstudioMercadoResponse>> UpdateAsync(int id, EstudioMercadoResponse response, int usuarioActual)
        {
            Normalize(response);
            var validation = Validate(response);
            return validation ?? SaveWithStoredProcedureAsync(2, id, response, usuarioActual);
        }

        public async Task<PagedResult<bool>> DeleteAsync(int id, int usuarioActual)
        {
            try
            {
                var spResult = await StoredProcedureExecutor.ExecuteResultAsync(
                    _context,
                    "[ORCO].[SP_MantenimientoEstudioMercado]",
                    StoredProcedureExecutor.Param("@Action", 3),
                    StoredProcedureExecutor.Param("@PKIdEstudioMercado", id),
                    StoredProcedureExecutor.Param("@IdUser", usuarioActual));

                return new PagedResult<bool>
                {
                    Success = true,
                    Message = spResult.Mensaje,
                    Code = "SUCCESS",
                    Data = true,
                    Items = new List<bool> { true },
                    TotalCount = 1
                };
            }
            catch (Exception ex)
            {
                return new PagedResult<bool>
                {
                    Success = false,
                    Message = $"Error al eliminar estudio de mercado: {ex.Message}",
                    Code = "ERROR",
                    Data = false,
                    TotalCount = 0
                };
            }
        }

        private static void Normalize(EstudioMercadoResponse response)
        {
            response.Nombre = response.Nombre?.Trim() ?? string.Empty;
            response.Descripcion = string.IsNullOrWhiteSpace(response.Descripcion)
                ? null
                : response.Descripcion.Trim();
            response.FechaSolicitud = response.FechaSolicitud == default ? DateTime.Today : response.FechaSolicitud;
            response.Estatus = response.Estatus <= 0 ? 1 : response.Estatus;
        }

        private static Task<PagedResult<EstudioMercadoResponse>>? Validate(EstudioMercadoResponse response)
        {
            if (response.FkidEmpresaSis <= 0)
            {
                return Task.FromResult(ValidationFailure("Debe existir una empresa seleccionada."));
            }

            if (response.FkidAnioSis <= 0)
            {
                return Task.FromResult(ValidationFailure("Debe seleccionar un anio presupuestal."));
            }

            if (response.FkidResponsableNom <= 0)
            {
                return Task.FromResult(ValidationFailure("Debe seleccionar un responsable."));
            }

            if (string.IsNullOrWhiteSpace(response.Nombre))
            {
                return Task.FromResult(ValidationFailure("El nombre del estudio es requerido."));
            }

            if (response.FechaCierre.HasValue && response.FechaCierre.Value.Date < response.FechaSolicitud.Date)
            {
                return Task.FromResult(ValidationFailure("La fecha de cierre no puede ser anterior a la solicitud."));
            }

            return null;
        }

        private static PagedResult<EstudioMercadoResponse> ValidationFailure(string message) => new()
        {
            Success = false,
            Message = message,
            Code = "VALIDATION",
            TotalCount = 0
        };

        private async Task<PagedResult<EstudioMercadoResponse>> SaveWithStoredProcedureAsync(
            int action,
            int? id,
            EstudioMercadoResponse response,
            int usuarioActual)
        {
            try
            {
                var spResult = await StoredProcedureExecutor.ExecuteResultAsync(
                    _context,
                    "[ORCO].[SP_MantenimientoEstudioMercado]",
                    StoredProcedureExecutor.Param("@Action", action),
                    StoredProcedureExecutor.Param("@PKIdEstudioMercado", id),
                    StoredProcedureExecutor.Param("@FKIdEmpresa_SIS", response.FkidEmpresaSis),
                    StoredProcedureExecutor.Param("@FKIdAnio_SIS", response.FkidAnioSis),
                    StoredProcedureExecutor.Param("@Nombre", response.Nombre),
                    StoredProcedureExecutor.Param("@Descripcion", response.Descripcion),
                    StoredProcedureExecutor.Param("@FechaSolicitud", response.FechaSolicitud),
                    StoredProcedureExecutor.Param("@FechaCierre", response.FechaCierre),
                    StoredProcedureExecutor.Param("@FKIdResponsable_NOM", response.FkidResponsableNom),
                    StoredProcedureExecutor.Param("@Estatus", response.Estatus),
                    StoredProcedureExecutor.Param("@IdUser", usuarioActual));

                var savedId = id ?? spResult.GetId() ?? 0;
                response.PkidEstudioMercado = savedId;
                var result = await GetByIdAsync(savedId);
                result.Message = spResult.Mensaje;
                return result;
            }
            catch (Exception ex)
            {
                return new PagedResult<EstudioMercadoResponse>
                {
                    Success = false,
                    Message = $"Error al guardar estudio de mercado: {ex.Message}",
                    Code = "ERROR",
                    TotalCount = 0
                };
            }
        }
    }
}
