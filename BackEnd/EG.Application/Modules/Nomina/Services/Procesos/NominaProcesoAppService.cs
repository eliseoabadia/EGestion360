using EG.Application.Interfaces.Nomina;
using EG.Common;
using EG.Common.Enums;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.Nomina;
using EG.Domain.DTOs.Responses.Nomina;

namespace EG.Application.Services.Nomina
{
    public class NominaProcesoAppService : INominaProcesoAppService
    {
        private readonly Logger.Log4NetLogger _logger = new(typeof(NominaProcesoAppService));

        public Task<PagedResult<NominaProcesoResponse>> CalcularNominaAsync(NominaProcesoRequest request, int usuarioActual)
            => MissingStoredProcedureAsync("Calcular nomina", "NOM_SP_Nomina", request, usuarioActual);

        public Task<PagedResult<NominaProcesoResponse>> CerrarPeriodoAsync(NominaProcesoRequest request, int usuarioActual)
            => MissingStoredProcedureAsync("Cerrar periodo", "NOM_SP_CierraPeriodo", request, usuarioActual);

        public Task<PagedResult<NominaProcesoResponse>> CalcularAguinaldoAsync(NominaProcesoRequest request, int usuarioActual)
            => MissingStoredProcedureAsync("Calcular aguinaldo", "NOM_SP_CalculaAguinaldo", request, usuarioActual);

        public Task<PagedResult<NominaProcesoResponse>> CalcularPrimaVacacionalIndividualAsync(NominaProcesoRequest request, int usuarioActual)
            => MissingStoredProcedureAsync("Calcular prima vacacional individual", "NOM_SP_PrimaVac_Ind", request, usuarioActual);

        public Task<PagedResult<NominaProcesoResponse>> CrearComprometidoNominaAsync(NominaProcesoRequest request, int usuarioActual)
            => MissingStoredProcedureAsync("Crear comprometido de nomina", "PRES_SP_CREATE_Comprometido_Nomina", request, usuarioActual);

        public Task<PagedResult<NominaProcesoResponse>> CrearDevengadoNominaAsync(NominaProcesoRequest request, int usuarioActual)
            => MissingStoredProcedureAsync("Crear devengado de nomina", "PRES_SP_CREATE_Devengado_Nomina", request, usuarioActual);

        public Task<PagedResult<NominaProcesoResponse>> CrearEjercidoNominaAsync(NominaProcesoRequest request, int usuarioActual)
            => MissingStoredProcedureAsync("Crear ejercido de nomina", "PRES_SP_CREATE_Ejercido_Nomina", request, usuarioActual);

        private Task<PagedResult<NominaProcesoResponse>> MissingStoredProcedureAsync(
            string processName,
            string storedProcedure,
            NominaProcesoRequest request,
            int usuarioActual)
        {
            request ??= new NominaProcesoRequest();
            var technicalMessage =
                $"Proceso de Nomina no habilitado. Falta migrar/configurar SP {storedProcedure}. " +
                $"Usuario={usuarioActual}, EmpresaId={request.EmpresaId}, PeriodoId={request.PeriodoId}, " +
                $"PersonaId={request.PersonaId}, Anio={request.Anio}, FechaProceso={request.FechaProceso:O}.";

            _logger.LogMessage(
                LogLevelGRP.Warn,
                technicalMessage,
                (byte)SystemLogTypes.Warning,
                nameof(NominaProcesoAppService),
                string.Empty,
                string.Empty);

            var response = new NominaProcesoResponse
            {
                Proceso = processName,
                Codigo = "SP_NOT_MIGRATED",
                Ejecutado = false,
                FechaIntento = DateTime.Now,
                Mensaje = UserFacingMessages.OperationFailed($"ejecutar {processName.ToLowerInvariant()}")
            };

            return Task.FromResult(new PagedResult<NominaProcesoResponse>
            {
                Success = false,
                Message = response.Mensaje,
                Code = response.Codigo,
                Data = response,
                Items = new List<NominaProcesoResponse> { response },
                TotalCount = 1
            });
        }
    }
}
