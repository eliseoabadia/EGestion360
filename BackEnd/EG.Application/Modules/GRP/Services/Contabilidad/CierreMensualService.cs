using EG.Application.Interfaces.Contabilidad;
using EG.Application.Services.Adquisicion;
using EG.Business.Services;
using EG.Common;
using EG.Common.Exceptions;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Responses.Contabilidad;
using EG.Domain.Interfaces;
using EG.Infraestructure.Models;
using Microsoft.EntityFrameworkCore;

namespace EG.ApiCoreBS.Services.Contabilidad
{
    public class CierreMensualService : ICierreMensualService
    {
        private const string StoredProcedureName = "CONTA.SP_SaldoMensual";
        private readonly GenericService<SaldoMensual, CierreMensualResponse, CierreMensualResponse> _saldoService;
        private readonly EGestionContext _context;
        private readonly IUserContextService _userContext;

        public CierreMensualService(
            GenericService<SaldoMensual, CierreMensualResponse, CierreMensualResponse> saldoService,
            EGestionContext context,
            IUserContextService userContext)
        {
            _saldoService = saldoService;
            _context = context;
            _userContext = userContext;

            _saldoService.AddInclude(x => x.FkidAnioSisNavigation)
                .AddInclude(x => x.FkidCuentaContableNavigation)
                .AddRelationFilter(nameof(SaldoMensual.FkidCuentaContableNavigation), ["ClaveOrd", "Descripcion"]);
        }

        public async Task<PagedResult<CierreMensualResponse>> GetAllAsync()
        {
            return await GetAllPaginadoAsync(new PagedRequest
            {
                Page = 1,
                PageSize = 500,
                SortLabel = nameof(SaldoMensual.FkidCuentaContable),
                SortDirection = "Ascending"
            });
        }

        public async Task<PagedResult<CierreMensualResponse>> GetByIdAsync(int id)
        {
            try
            {
                var item = await _saldoService.GetByIdAsync(id, idPropertyName: nameof(SaldoMensual.PkidSaldoMensual));
                if (item == null)
                {
                    return Failure("Saldo mensual no encontrado.", "NOT_FOUND");
                }

                EnrichPeriodo(item);
                return Success(item, "Saldo mensual encontrado.");
            }
            catch (Exception ex)
            {
                return Failure(UserFacingMessages.OperationFailed("obtener el saldo mensual"), "ERROR", ex);
            }
        }

        public async Task<PagedResult<CierreMensualResponse>> GetAllPaginadoAsync(PagedRequest request)
        {
            try
            {
                request = await NormalizeRequestAsync(request);
                var empresaId = _userContext.TryGetCurrentEmpresaId();

                var result = empresaId.HasValue && empresaId.Value > 0
                    ? await _saldoService.GetAllPaginadoAsync(
                        request,
                        x => x.FkidCuentaContableNavigation.FkidEmpresaSis == empresaId.Value)
                    : await _saldoService.GetAllPaginadoAsync(request);

                foreach (var item in result.Items)
                {
                    EnrichPeriodo(item);
                }

                result.Message = result.Success
                    ? "Saldos mensuales obtenidos correctamente"
                    : result.Message;

                return result;
            }
            catch (Exception ex)
            {
                return Failure(UserFacingMessages.OperationFailed("obtener los saldos mensuales"), "ERROR", ex);
            }
        }

        public async Task<PagedResult<CierreMensualResponse>> GetEstadoAsync()
        {
            try
            {
                var estado = await BuildEstadoAsync();
                return Success(estado, "Estado de cierre obtenido correctamente.");
            }
            catch (Exception ex)
            {
                return Failure(UserFacingMessages.OperationFailed("obtener el estado del cierre mensual"), "ERROR", ex);
            }
        }

        public async Task<PagedResult<CierreMensualResponse>> AplicarCierreMensualAsync(int usuarioActual)
        {
            try
            {
                var estado = await BuildEstadoAsync();
                if (!estado.PuedeRealizarCierre)
                {
                    return Failure(
                        string.IsNullOrWhiteSpace(estado.MotivoBloqueo)
                            ? "El periodo actual no esta listo para cierre."
                            : estado.MotivoBloqueo,
                        "PERIODO_NO_CERRABLE");
                }

                var result = await StoredProcedureExecutor.ExecuteResultAsync(_context, StoredProcedureName);
                var refreshed = await BuildEstadoAsync();
                refreshed.ResultTipo = result.Tipo;
                refreshed.ResultLiga = result.Liga;

                return new PagedResult<CierreMensualResponse>
                {
                    Success = true,
                    Message = result.Mensaje,
                    Code = string.IsNullOrWhiteSpace(result.Tipo) ? "SUCCESS" : result.Tipo,
                    Data = refreshed,
                    Items = [refreshed],
                    TotalCount = 1
                };
            }
            catch (UserVisibleException ex)
            {
                return Failure(ex.UserMessage, ex.Code);
            }
            catch (Exception ex)
            {
                return Failure(UserFacingMessages.OperationFailed("aplicar el cierre mensual"), "ERROR", ex);
            }
        }

        private async Task<PagedRequest> NormalizeRequestAsync(PagedRequest request)
        {
            request ??= new PagedRequest();
            request.Page = request.Page <= 0 ? 1 : request.Page;
            request.PageSize = request.PageSize <= 0 ? 10 : request.PageSize;
            request.SortLabel = string.IsNullOrWhiteSpace(request.SortLabel)
                ? nameof(SaldoMensual.FkidCuentaContable)
                : request.SortLabel;
            request.SortDirection = string.IsNullOrWhiteSpace(request.SortDirection)
                ? "Ascending"
                : request.SortDirection;
            request.AdditionalFilters ??= new Dictionary<string, object>();

            if (!request.AdditionalFilters.ContainsKey(nameof(SaldoMensual.FkidAnioSis)) ||
                !request.AdditionalFilters.ContainsKey(nameof(SaldoMensual.FkidMesSis)))
            {
                var periodo = await GetCurrentPeriodoAsync();
                if (periodo != null)
                {
                    request.AdditionalFilters[nameof(SaldoMensual.FkidAnioSis)] = periodo.FkidAnioSis;
                    request.AdditionalFilters[nameof(SaldoMensual.FkidMesSis)] = periodo.FkidMesSis;
                }
            }

            return request;
        }

        private async Task<CierreMensualResponse> BuildEstadoAsync()
        {
            var currentRows = await _context.MesActuals
                .AsNoTracking()
                .Where(x => x.Actual == 1 && x.Activo)
                .ToListAsync();

            if (currentRows.Count != 1)
            {
                return new CierreMensualResponse
                {
                    PuedeRealizarCierre = false,
                    MotivoBloqueo = "Verifique que exista un unico mes actual activo en CONTA.MesActual."
                };
            }

            var periodo = currentRows[0];
            var empresaId = _userContext.TryGetCurrentEmpresaId();
            var anio = await ResolveAnioAsync(periodo.FkidAnioSis);
            var mes = MonthName(periodo.FkidMesSis);
            var puedeCerrar = PuedeCerrarMes(periodo.FkidMesSis, DateTime.Today);

            var polizaQuery = _context.Polizas
                .AsNoTracking()
                .Where(x => x.Activo &&
                            x.FkidAnioSis == periodo.FkidAnioSis &&
                            x.FkidMesSis == periodo.FkidMesSis);

            var detalleQuery = _context.PolizaDetalles
                .AsNoTracking()
                .Where(x => x.Activo &&
                            x.FkidPolizaContaNavigation.Activo &&
                            x.FkidPolizaContaNavigation.FkidAnioSis == periodo.FkidAnioSis &&
                            x.FkidPolizaContaNavigation.FkidMesSis == periodo.FkidMesSis);

            var saldoQuery = _context.SaldoMensuales
                .AsNoTracking()
                .Where(x => x.Activo &&
                            x.FkidAnioSis == periodo.FkidAnioSis &&
                            x.FkidMesSis == periodo.FkidMesSis);

            var saldoHistoricoQuery = _context.SaldoMensuales.AsNoTracking().Where(x => x.Activo);

            if (empresaId.HasValue && empresaId.Value > 0)
            {
                polizaQuery = polizaQuery.Where(x => x.PolizaDetalles.Any(d =>
                    d.Activo && d.FkidCuentaContableContaNavigation.FkidEmpresaSis == empresaId.Value));

                detalleQuery = detalleQuery.Where(x =>
                    x.FkidCuentaContableContaNavigation.FkidEmpresaSis == empresaId.Value);

                saldoQuery = saldoQuery.Where(x =>
                    x.FkidCuentaContableNavigation.FkidEmpresaSis == empresaId.Value);

                saldoHistoricoQuery = saldoHistoricoQuery.Where(x =>
                    x.FkidCuentaContableNavigation.FkidEmpresaSis == empresaId.Value);
            }

            var totalPolizas = await polizaQuery.CountAsync();
            var polizasBalanceadas = await polizaQuery.CountAsync(x => x.EstaBalanceado);
            var movimientos = await detalleQuery.CountAsync();
            var totalDebe = await detalleQuery.Select(x => x.ImporteDebe ?? 0m).DefaultIfEmpty().SumAsync();
            var totalHaber = await detalleQuery.Select(x => x.ImporteHaber ?? 0m).DefaultIfEmpty().SumAsync();

            var totalSaldoInicial = await saldoQuery.Select(x => x.SaldoInicial ?? 0m).DefaultIfEmpty().SumAsync();
            var totalCargos = await saldoQuery.Select(x => x.Cargos ?? 0m).DefaultIfEmpty().SumAsync();
            var totalAbonos = await saldoQuery.Select(x => x.Abonos ?? 0m).DefaultIfEmpty().SumAsync();
            var totalSaldoFinal = await saldoQuery.Select(x => x.SaldoFinal ?? 0m).DefaultIfEmpty().SumAsync();
            var cuentasConSaldo = await saldoQuery.Select(x => x.FkidCuentaContable).Distinct().CountAsync();
            var saldosGenerados = await saldoQuery.CountAsync();
            var ultimoCierre = await saldoHistoricoQuery.MaxAsync(x => (DateTime?)x.FechaCreacion);

            return new CierreMensualResponse
            {
                PkidMesActual = periodo.PkidMesActual,
                FkidAnioSis = periodo.FkidAnioSis,
                Anio = anio,
                FkidMesSis = periodo.FkidMesSis,
                Mes = mes.Name,
                MesAbreviatura = mes.Abbreviation,
                PeriodoNombre = $"{mes.Name} {anio}",
                FkidEmpresaSis = empresaId ?? 0,
                TotalPolizas = totalPolizas,
                PolizasBalanceadas = polizasBalanceadas,
                PolizasPendientes = Math.Max(0, totalPolizas - polizasBalanceadas),
                Movimientos = movimientos,
                TotalDebe = totalDebe,
                TotalHaber = totalHaber,
                Diferencia = totalDebe - totalHaber,
                TotalSaldoInicial = totalSaldoInicial,
                TotalCargos = totalCargos,
                TotalAbonos = totalAbonos,
                TotalSaldoFinal = totalSaldoFinal,
                CuentasConSaldo = cuentasConSaldo,
                SaldosGenerados = saldosGenerados,
                FechaUltimoCierre = ultimoCierre,
                PuedeRealizarCierre = puedeCerrar,
                MotivoBloqueo = puedeCerrar
                    ? string.Empty
                    : "Solo puede cerrarse el mes calendario actual durante el ultimo dia del mes."
            };
        }

        private async Task<MesActual?> GetCurrentPeriodoAsync()
        {
            return await _context.MesActuals
                .AsNoTracking()
                .Where(x => x.Actual == 1 && x.Activo)
                .OrderByDescending(x => x.FechaCreacion)
                .FirstOrDefaultAsync();
        }

        private async Task<int> ResolveAnioAsync(int fkidAnioSis)
        {
            var anio = await _context.Anios
                .AsNoTracking()
                .Where(x => x.PkidAnio == fkidAnioSis)
                .Select(x => (int?)x.Clave)
                .FirstOrDefaultAsync();

            return anio ?? fkidAnioSis;
        }

        private static bool PuedeCerrarMes(int mesACerrar, DateTime today)
        {
            if (mesACerrar < 1 || mesACerrar > 13)
            {
                return false;
            }

            if (mesACerrar == 13 || mesACerrar != today.Month)
            {
                return true;
            }

            var ultimoDiaDelMes = new DateTime(today.Year, today.Month, DateTime.DaysInMonth(today.Year, today.Month));
            return today.Date == ultimoDiaDelMes.Date;
        }

        private static void EnrichPeriodo(CierreMensualResponse item)
        {
            var mes = MonthName(item.FkidMesSis);
            item.Mes = mes.Name;
            item.MesAbreviatura = mes.Abbreviation;
            item.PeriodoNombre = $"{mes.Name} {item.Anio}";
        }

        private static (string Name, string Abbreviation) MonthName(int month)
        {
            return month switch
            {
                1 => ("Enero", "ENE"),
                2 => ("Febrero", "FEB"),
                3 => ("Marzo", "MAR"),
                4 => ("Abril", "ABR"),
                5 => ("Mayo", "MAY"),
                6 => ("Junio", "JUN"),
                7 => ("Julio", "JUL"),
                8 => ("Agosto", "AGO"),
                9 => ("Septiembre", "SEP"),
                10 => ("Octubre", "OCT"),
                11 => ("Noviembre", "NOV"),
                12 => ("Diciembre", "DIC"),
                13 => ("Mes trece", "M13"),
                _ => ("Sin periodo", "--")
            };
        }

        private static PagedResult<CierreMensualResponse> Success(CierreMensualResponse item, string message)
        {
            return new PagedResult<CierreMensualResponse>
            {
                Success = true,
                Message = message,
                Code = "SUCCESS",
                Data = item,
                Items = [item],
                TotalCount = 1
            };
        }

        private static PagedResult<CierreMensualResponse> Failure(
            string message,
            string code,
            Exception? exception = null)
        {
            return new PagedResult<CierreMensualResponse>
            {
                Success = false,
                Message = exception == null ? message : UserFacingMessages.UnexpectedError,
                Code = code,
                Items = [],
                TotalCount = 0
            };
        }
    }
}
