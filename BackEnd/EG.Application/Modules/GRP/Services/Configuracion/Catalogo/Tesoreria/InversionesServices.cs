using EG.Application.Services.Adquisicion;
using EG.Business.Services;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.Tesoreria;
using EG.Domain.DTOs.Responses.Tesoreria;
using EG.Infraestructure.Models;
using Mapster;
using Microsoft.EntityFrameworkCore;
using System.Text.Json;

namespace EG.ApiCoreBS.Services.Configuracion.Catalogo.Tesoreria
{
    public class BancoInversionService(
        GenericService<Banco, BancoDto, BancoResponse> service,
        GenericService<VwBanco, BancoDto, BancoResponse> serviceView)
        : AdquisicionCrudAppService<Banco, VwBanco, BancoDto, BancoResponse>(
            service,
            serviceView,
            "PkidBanco",
            "Banco",
            (dto, id) => dto.PkidBanco = id);

    public class CuentaBancariaInversionService(
        GenericService<CuentaBancarium, CuentaBancariaDto, CuentaBancariaResponse> service,
        GenericService<CuentaBancarium, CuentaBancariaDto, CuentaBancariaResponse> serviceView,
        EGestionContext context)
        : AdquisicionCrudAppService<CuentaBancarium, CuentaBancarium, CuentaBancariaDto, CuentaBancariaResponse>(
            service,
            serviceView,
            "PkidCuentaBancaria",
            "Cuenta bancaria",
            (dto, id) => dto.PkidCuentaBancaria = id)
    {
        public override async Task<PagedResult<CuentaBancariaResponse>> GetByIdAsync(int id)
        {
            var entity = await context.CuentaBancaria
                .Include(x => x.FkidBancoTesNavigation)
                .Include(x => x.FkidTipoMonedaTesNavigation)
                .Include(x => x.FkidCuentaContableSisNavigation)
                .FirstOrDefaultAsync(x => x.PkidCuentaBancaria == id && x.Activo);

            if (entity == null)
            {
                return new PagedResult<CuentaBancariaResponse>
                {
                    Success = false,
                    Message = $"Cuenta bancaria con ID {id} no encontrada",
                    Code = "NOT_FOUND",
                    TotalCount = 0
                };
            }

            var response = entity.Adapt<CuentaBancariaResponse>();
            return new PagedResult<CuentaBancariaResponse>
            {
                Success = true,
                Message = "Cuenta bancaria encontrada",
                Code = "SUCCESS",
                Data = response,
                Items = new List<CuentaBancariaResponse> { response },
                TotalCount = 1
            };
        }

        public override async Task<PagedResult<CuentaBancariaResponse>> GetAllPaginadoAsync(PagedRequest request)
        {
            var query = context.CuentaBancaria
                .AsNoTracking()
                .Include(x => x.FkidBancoTesNavigation)
                .Include(x => x.FkidTipoMonedaTesNavigation)
                .Include(x => x.FkidCuentaContableSisNavigation)
                .Where(x => x.Activo);

            if (!string.IsNullOrWhiteSpace(request.Filtro))
            {
                var f = request.Filtro.Trim();
                query = query.Where(x =>
                    x.NumeroCuenta.Contains(f) ||
                    x.Clabe.Contains(f) ||
                    x.Titular.Contains(f) ||
                    (x.FkidBancoTesNavigation != null && x.FkidBancoTesNavigation.Nombre.Contains(f)) ||
                    (x.FkidCuentaContableSisNavigation != null && (x.FkidCuentaContableSisNavigation.Cuenta.Contains(f) || x.FkidCuentaContableSisNavigation.Descripcion.Contains(f))));
            }

            var isDescending = !string.IsNullOrWhiteSpace(request.SortDirection)
                && request.SortDirection.StartsWith("desc", StringComparison.OrdinalIgnoreCase);

            query = request.SortLabel switch
            {
                "PkidCuentaBancaria" => isDescending ? query.OrderByDescending(x => x.PkidCuentaBancaria) : query.OrderBy(x => x.PkidCuentaBancaria),
                "NumeroCuenta" => isDescending ? query.OrderByDescending(x => x.NumeroCuenta) : query.OrderBy(x => x.NumeroCuenta),
                "Titular" => isDescending ? query.OrderByDescending(x => x.Titular) : query.OrderBy(x => x.Titular),
                "SaldoActual" => isDescending ? query.OrderByDescending(x => x.SaldoActual) : query.OrderBy(x => x.SaldoActual),
                "BancoNombre" => isDescending ? query.OrderByDescending(x => x.FkidBancoTesNavigation!.Nombre) : query.OrderBy(x => x.FkidBancoTesNavigation!.Nombre),
                "CuentaContable" => isDescending ? query.OrderByDescending(x => x.FkidCuentaContableSisNavigation!.Cuenta) : query.OrderBy(x => x.FkidCuentaContableSisNavigation!.Cuenta),
                _ => query.OrderBy(x => x.NumeroCuenta)
            };

            var total = await query.CountAsync();
            var items = await query
                .Skip((request.Page - 1) * request.PageSize)
                .Take(request.PageSize)
                .ToListAsync();

            return new PagedResult<CuentaBancariaResponse>
            {
                Success = true,
                Message = "Cuentas bancarias obtenidas correctamente",
                Code = "SUCCESS",
                Items = items.Adapt<List<CuentaBancariaResponse>>(),
                TotalCount = total
            };
        }
    }

    public class IntermediarioFinancieroInversionService(
        GenericService<IntermediarioFinanciero, IntermediarioFinancieroDto, IntermediarioFinancieroResponse> service,
        GenericService<VwIntermediarioFinanciero, IntermediarioFinancieroDto, IntermediarioFinancieroResponse> serviceView)
        : AdquisicionCrudAppService<IntermediarioFinanciero, VwIntermediarioFinanciero, IntermediarioFinancieroDto, IntermediarioFinancieroResponse>(
            service,
            serviceView,
            "PkidIntermediarioFinanciero",
            "Intermediario financiero",
            (dto, id) => dto.PkidIntermediarioFinanciero = id);

    public class InstrumentoInversionService(
        GenericService<Instrumento, InstrumentoDto, InstrumentoResponse> service,
        GenericService<VwInstrumento, InstrumentoDto, InstrumentoResponse> serviceView)
        : AdquisicionCrudAppService<Instrumento, VwInstrumento, InstrumentoDto, InstrumentoResponse>(
            service,
            serviceView,
            "PkidInstrumento",
            "Instrumento de inversion",
            (dto, id) => dto.PkidInstrumento = id);

    public class InversionAppService(
        GenericService<Inversion, InversionDto, InversionResponse> service,
        GenericService<VwInversione, InversionDto, InversionResponse> serviceView,
        EGestionContext context)
        : AdquisicionCrudAppService<Inversion, VwInversione, InversionDto, InversionResponse>(
            service,
            serviceView,
            "PkidInversion",
            "Inversion",
            (dto, id) => dto.PkidInversion = id)
    {
        public override async Task<PagedResult<InversionResponse>> CreateAsync(InversionResponse response, int usuarioActual)
        {
            try
            {
                var dto = response.Adapt<InversionDto>();
                dto.UsuarioCreacion = usuarioActual;
                dto.FechaCreacion = DateTime.Now;
                dto.Activo = true;

                await _service.AddAsync(dto);
                await CalcularInteresesAsync(dto.PkidInversion, usuarioActual);

                var created = await GetByIdAsync(dto.PkidInversion);
                created.Message = "Inversion creada correctamente";
                return created;
            }
            catch (Exception ex)
            {
                return new PagedResult<InversionResponse>
                {
                    Success = false,
                    Message = $"Error al crear Inversion: {GetErrorMessage(ex)}",
                    Code = "ERROR",
                    TotalCount = 0
                };
            }
        }

        public override async Task<PagedResult<InversionResponse>> UpdateAsync(int id, InversionResponse response, int usuarioActual)
        {
            var result = await base.UpdateAsync(id, response, usuarioActual);
            if (!result.Success)
            {
                return result;
            }

            try
            {
                await CalcularInteresesAsync(id, usuarioActual);
                var updated = await GetByIdAsync(id);
                updated.Message = "Inversion actualizada correctamente";
                return updated;
            }
            catch (Exception ex)
            {
                return new PagedResult<InversionResponse>
                {
                    Success = false,
                    Message = $"La inversion se guardo, pero no fue posible calcular intereses: {GetErrorMessage(ex)}",
                    Code = "ERROR",
                    TotalCount = 0
                };
            }
        }

        private async Task CalcularInteresesAsync(int inversionId, int usuarioActual) =>
            await StoredProcedureExecutor.ExecuteResultAsync(
                context,
                "[TES].[SP_CalcularIntereses]",
                StoredProcedureExecutor.Param("@PKIdInversion", inversionId),
                StoredProcedureExecutor.Param("@IdUser", usuarioActual));

        private static string GetErrorMessage(Exception ex) => ex.InnerException?.Message ?? ex.Message;
    }

    public class InteresAppService(
        GenericService<Intere, InteresDto, InteresResponse> service,
        GenericService<Intere, InteresDto, InteresResponse> serviceView)
        : AdquisicionCrudAppService<Intere, Intere, InteresDto, InteresResponse>(
            service,
            serviceView,
            "PkidInteres",
            "Interes",
            (dto, id) => dto.PkidInteres = id);

    public class RetiroAppService(
        GenericService<Retiro, RetiroDto, RetiroResponse> service,
        GenericService<Retiro, RetiroDto, RetiroResponse> serviceView,
        EGestionContext context)
        : AdquisicionCrudAppService<Retiro, Retiro, RetiroDto, RetiroResponse>(
            service,
            serviceView,
            "PkidRetiro",
            "Retiro",
            (dto, id) => dto.PkidRetiro = id)
    {
        public override async Task<PagedResult<RetiroResponse>> GetByIdAsync(int id)
        {
            var entity = await context.Retiros
                .AsNoTracking()
                .Include(x => x.FkidTipoRetiroTesNavigation)
                .FirstOrDefaultAsync(x => x.PkidRetiro == id && x.Activo);

            if (entity == null)
            {
                return new PagedResult<RetiroResponse>
                {
                    Success = false,
                    Message = $"Retiro con ID {id} no encontrado",
                    Code = "NOT_FOUND",
                    TotalCount = 0
                };
            }

            var response = entity.Adapt<RetiroResponse>();
            return new PagedResult<RetiroResponse>
            {
                Success = true,
                Message = "Retiro encontrado",
                Code = "SUCCESS",
                Data = response,
                Items = new List<RetiroResponse> { response },
                TotalCount = 1
            };
        }

        public override async Task<PagedResult<RetiroResponse>> GetAllPaginadoAsync(PagedRequest request)
        {
            var query = context.Retiros
                .AsNoTracking()
                .Include(x => x.FkidTipoRetiroTesNavigation)
                .Where(x => x.Activo);

            if (TryGetIntFilter(request, "FkidInversion", out var inversionId))
            {
                query = query.Where(x => x.FkidInversion == inversionId);
            }

            if (!string.IsNullOrWhiteSpace(request.Filtro))
            {
                var f = request.Filtro.Trim();
                query = query.Where(x =>
                    (x.FkidTipoRetiroTesNavigation != null && x.FkidTipoRetiroTesNavigation.Descripcion.Contains(f)));
            }

            var isDescending = !string.IsNullOrWhiteSpace(request.SortDirection)
                && request.SortDirection.StartsWith("desc", StringComparison.OrdinalIgnoreCase);

            query = request.SortLabel switch
            {
                "PkidRetiro" => isDescending ? query.OrderByDescending(x => x.PkidRetiro) : query.OrderBy(x => x.PkidRetiro),
                "Monto" => isDescending ? query.OrderByDescending(x => x.Monto) : query.OrderBy(x => x.Monto),
                "FechaRetiro" => isDescending ? query.OrderByDescending(x => x.FechaRetiro) : query.OrderBy(x => x.FechaRetiro),
                "TipoRetiroDescripcion" => isDescending ? query.OrderByDescending(x => x.FkidTipoRetiroTesNavigation!.Descripcion) : query.OrderBy(x => x.FkidTipoRetiroTesNavigation!.Descripcion),
                _ => query.OrderByDescending(x => x.FechaRetiro)
            };

            var total = await query.CountAsync();
            var items = await query
                .Skip((request.Page - 1) * request.PageSize)
                .Take(request.PageSize)
                .ToListAsync();

            return new PagedResult<RetiroResponse>
            {
                Success = true,
                Message = "Retiros obtenidos correctamente",
                Code = "SUCCESS",
                Items = items.Adapt<List<RetiroResponse>>(),
                TotalCount = total
            };
        }

        private static bool TryGetIntFilter(PagedRequest request, string key, out int value)
        {
            value = 0;
            if (request.AdditionalFilters == null || !request.AdditionalFilters.TryGetValue(key, out var raw) || raw == null)
            {
                return false;
            }

            if (raw is JsonElement json)
            {
                if (json.ValueKind == JsonValueKind.Number && json.TryGetInt32(out value))
                {
                    return true;
                }

                if (json.ValueKind == JsonValueKind.String && int.TryParse(json.GetString(), out value))
                {
                    return true;
                }
            }

            return int.TryParse(raw.ToString(), out value);
        }
    }

    public class TipoPlazoInversionService(
        GenericService<TipoPlazo, TipoPlazoDto, TipoPlazoResponse> service,
        GenericService<TipoPlazo, TipoPlazoDto, TipoPlazoResponse> serviceView)
        : AdquisicionCrudAppService<TipoPlazo, TipoPlazo, TipoPlazoDto, TipoPlazoResponse>(
            service,
            serviceView,
            "PkidTipoPlazo",
            "Tipo de plazo",
            (dto, id) => dto.PkidTipoPlazo = id);

    public class TipoRetiroInversionService(
        GenericService<TipoRetiro, TipoRetiroDto, TipoRetiroResponse> service,
        GenericService<VwTipoRetiro, TipoRetiroDto, TipoRetiroResponse> serviceView)
        : AdquisicionCrudAppService<TipoRetiro, VwTipoRetiro, TipoRetiroDto, TipoRetiroResponse>(
            service,
            serviceView,
            "PkidTipoRetiro",
            "Tipo de retiro",
            (dto, id) => dto.PkidTipoRetiro = id);
}
