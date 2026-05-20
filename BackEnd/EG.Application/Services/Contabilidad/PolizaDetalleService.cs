using EG.Application.Interfaces.Contabilidad;
using EG.Application.Services.Adquisicion;
using EG.Business.Services;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.Contabilidad;
using EG.Domain.DTOs.Responses.Contabilidad;
using EG.Infraestructure.Models;
using Mapster;
using Microsoft.EntityFrameworkCore;

namespace EG.ApiCoreBS.Services.Contabilidad
{
    public class PolizaDetalleService
        : AdquisicionCrudAppService<PolizaDetalle, VwPolizaDetalle, PolizaDetalleDto, PolizaDetalleResponse>,
            IPolizaDetalleService
    {
        private readonly EGestionContext _context;

        public PolizaDetalleService(
            GenericService<PolizaDetalle, PolizaDetalleDto, PolizaDetalleResponse> service,
            GenericService<VwPolizaDetalle, PolizaDetalleDto, PolizaDetalleResponse> serviceView,
            EGestionContext context)
            : base(
                service,
                serviceView,
                "PkidPolizaDetalle",
                "Detalle de poliza",
                (dto, id) => dto.PkidPolizaDetalle = id)
        {
            _context = context;
        }

        public override async Task<PagedResult<PolizaDetalleResponse>> CreateAsync(PolizaDetalleResponse response, int usuarioActual)
        {
            var validation = ValidateMovement(response);
            if (validation != null)
            {
                return validation;
            }

            NormalizeOptionalReferences(response);
            validation = await ValidateReferencesAsync(response);
            if (validation != null)
            {
                return validation;
            }

            try
            {
                NormalizeMovement(response);

                var entity = new PolizaDetalle
                {
                    FkidPolizaConta = response.FkidPolizaConta,
                    FkidCuentaContableConta = response.FkidCuentaContableConta,
                    FkidTipoDetallePolizaSis = response.FkidTipoDetallePolizaSis,
                    Descripcion = response.Descripcion,
                    ImporteDebe = response.ImporteDebe,
                    ImporteHaber = response.ImporteHaber,
                    FkidReferencia = response.FkidReferencia,
                    Activo = true,
                    FechaCreacion = DateTime.Now,
                    UsuarioCreacion = usuarioActual
                };

                _context.PolizaDetalles.Add(entity);
                await _context.SaveChangesAsync();
                await RecalcularBalanceAsync(entity.FkidPolizaConta, usuarioActual);

                var created = await GetDetalleResponseAsync(entity);
                return new PagedResult<PolizaDetalleResponse>
                {
                    Success = true,
                    Message = "Detalle de poliza creado correctamente",
                    Code = "SUCCESS",
                    Data = created,
                    Items = new List<PolizaDetalleResponse> { created },
                    TotalCount = 1
                };
            }
            catch (Exception ex)
            {
                return Error($"Error al crear detalle de poliza: {GetErrorMessage(ex)}");
            }
        }

        public override async Task<PagedResult<PolizaDetalleResponse>> UpdateAsync(int id, PolizaDetalleResponse response, int usuarioActual)
        {
            var validation = ValidateMovement(response);
            if (validation != null)
            {
                return validation;
            }

            NormalizeOptionalReferences(response);
            validation = await ValidateReferencesAsync(response);
            if (validation != null)
            {
                return validation;
            }

            try
            {
                NormalizeMovement(response);

                var entity = await _context.PolizaDetalles
                    .FirstOrDefaultAsync(x => x.PkidPolizaDetalle == id);

                if (entity == null)
                {
                    return NotFound(id);
                }

                var previousPolizaId = entity.FkidPolizaConta;
                entity.FkidPolizaConta = response.FkidPolizaConta;
                entity.FkidCuentaContableConta = response.FkidCuentaContableConta;
                entity.FkidTipoDetallePolizaSis = response.FkidTipoDetallePolizaSis;
                entity.Descripcion = response.Descripcion;
                entity.ImporteDebe = response.ImporteDebe;
                entity.ImporteHaber = response.ImporteHaber;
                entity.FkidReferencia = response.FkidReferencia;
                entity.Activo = response.Activo;
                entity.UsuarioModificacion = usuarioActual;
                entity.FechaModificacion = DateTime.Now;

                await _context.SaveChangesAsync();
                await RecalcularBalanceAsync(previousPolizaId, usuarioActual);

                if (previousPolizaId != entity.FkidPolizaConta)
                {
                    await RecalcularBalanceAsync(entity.FkidPolizaConta, usuarioActual);
                }

                var updated = await GetDetalleResponseAsync(entity);
                return new PagedResult<PolizaDetalleResponse>
                {
                    Success = true,
                    Message = "Detalle de poliza actualizado correctamente",
                    Code = "SUCCESS",
                    Data = updated,
                    Items = new List<PolizaDetalleResponse> { updated },
                    TotalCount = 1
                };
            }
            catch (Exception ex)
            {
                return Error($"Error al actualizar detalle de poliza: {GetErrorMessage(ex)}");
            }
        }

        public async Task<PagedResult<bool>> DeleteAsync(int id, int usuarioActual)
        {
            try
            {
                var detalle = await _context.PolizaDetalles
                    .FirstOrDefaultAsync(x => x.PkidPolizaDetalle == id && x.Activo);

                if (detalle == null)
                {
                    return new PagedResult<bool>
                    {
                        Success = false,
                        Message = $"Detalle de poliza con ID {id} no encontrado",
                        Code = "NOT_FOUND",
                        Data = false,
                        TotalCount = 0
                    };
                }

                var polizaId = detalle.FkidPolizaConta;
                detalle.Activo = false;
                detalle.UsuarioModificacion = usuarioActual;
                detalle.FechaModificacion = DateTime.Now;

                await _context.SaveChangesAsync();
                await RecalcularBalanceAsync(polizaId, usuarioActual);

                return new PagedResult<bool>
                {
                    Success = true,
                    Message = "Detalle de poliza eliminado correctamente",
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
                    Message = $"Error al eliminar detalle de poliza: {ex.Message}",
                    Code = "ERROR",
                    Data = false,
                    TotalCount = 0
                };
            }
        }

        private static PagedResult<PolizaDetalleResponse>? ValidateMovement(PolizaDetalleResponse response)
        {
            var debe = response.ImporteDebe ?? 0m;
            var haber = response.ImporteHaber ?? 0m;

            if (debe < 0 || haber < 0)
            {
                return ValidationFailure("Los importes de debe y haber no pueden ser negativos.");
            }

            if (debe == 0m && haber == 0m)
            {
                return ValidationFailure("Captura un importe en debe o en haber.");
            }

            if (debe > 0m && haber > 0m)
            {
                return ValidationFailure("Un detalle no puede tener importe en debe y haber al mismo tiempo.");
            }

            return null;
        }

        private static PolizaDetalleResponse NormalizeMovement(PolizaDetalleResponse response)
        {
            response.ImporteDebe = response.ImporteDebe.GetValueOrDefault() == 0m ? null : response.ImporteDebe;
            response.ImporteHaber = response.ImporteHaber.GetValueOrDefault() == 0m ? null : response.ImporteHaber;
            return response;
        }

        private static void NormalizeOptionalReferences(PolizaDetalleResponse response)
        {
            if (response.FkidTipoDetallePolizaSis.GetValueOrDefault() <= 0)
            {
                response.FkidTipoDetallePolizaSis = null;
            }
        }

        private static PagedResult<PolizaDetalleResponse> ValidationFailure(string message) => new()
        {
            Success = false,
            Message = message,
            Code = "VALIDATION",
            TotalCount = 0
        };

        private async Task<PagedResult<PolizaDetalleResponse>?> ValidateReferencesAsync(PolizaDetalleResponse response)
        {
            if (response.FkidPolizaConta <= 0)
            {
                return ValidationFailure("Debe existir una poliza seleccionada.");
            }

            if (response.FkidCuentaContableConta <= 0)
            {
                return ValidationFailure("Debe seleccionar una cuenta contable.");
            }

            var polizaExists = await _context.Polizas
                .AnyAsync(x => x.PkidPoliza == response.FkidPolizaConta && x.Activo);

            if (!polizaExists)
            {
                return ValidationFailure($"No se encontro la poliza {response.FkidPolizaConta} o esta inactiva.");
            }

            var cuentaExists = await _context.CuentaContables
                .AnyAsync(x => x.PkidCuentaContable == response.FkidCuentaContableConta && x.Activo);

            if (!cuentaExists)
            {
                return ValidationFailure($"No se encontro la cuenta contable {response.FkidCuentaContableConta} o esta inactiva.");
            }

            if (response.FkidTipoDetallePolizaSis.HasValue)
            {
                var tipoExists = await _context.TipoDetallePolizas
                    .AnyAsync(x => x.PkIdTipoDetallePoliza == response.FkidTipoDetallePolizaSis.Value && x.Activo);

                if (!tipoExists)
                {
                    return ValidationFailure($"No se encontro el tipo de detalle de poliza {response.FkidTipoDetallePolizaSis.Value} o esta inactivo.");
                }
            }

            return null;
        }

        private static PagedResult<PolizaDetalleResponse> NotFound(int id) => new()
        {
            Success = false,
            Message = $"Detalle de poliza con ID {id} no encontrado",
            Code = "NOT_FOUND",
            TotalCount = 0
        };

        private static PagedResult<PolizaDetalleResponse> Error(string message) => new()
        {
            Success = false,
            Message = message,
            Code = "ERROR",
            TotalCount = 0
        };

        private static string GetErrorMessage(Exception ex) =>
            ex.InnerException?.Message ?? ex.Message;

        private async Task<PolizaDetalleResponse> GetDetalleResponseAsync(PolizaDetalle entity)
        {
            var view = await _context.VwPolizaDetalles
                .AsNoTracking()
                .FirstOrDefaultAsync(x => x.PkidPolizaDetalle == entity.PkidPolizaDetalle && x.Activo);

            return view?.Adapt<PolizaDetalleResponse>() ?? entity.Adapt<PolizaDetalleResponse>();
        }

        private async Task RecalcularBalanceAsync(int polizaId, int usuarioActual)
        {
            var poliza = await _context.Polizas
                .FirstOrDefaultAsync(x => x.PkidPoliza == polizaId && x.Activo);

            if (poliza == null)
            {
                return;
            }

            var detalles = await _context.PolizaDetalles
                .Where(x => x.FkidPolizaConta == polizaId && x.Activo)
                .GroupBy(_ => 1)
                .Select(g => new
                {
                    TotalDebe = g.Sum(x => x.ImporteDebe ?? 0m),
                    TotalHaber = g.Sum(x => x.ImporteHaber ?? 0m),
                    TotalDetalles = g.Count()
                })
                .FirstOrDefaultAsync();

            var estaBalanceado = detalles != null
                && detalles.TotalDetalles > 0
                && decimal.Round(detalles.TotalDebe - detalles.TotalHaber, 2) == 0m;

            poliza.EstaBalanceado = estaBalanceado;
            poliza.UsuarioModificacion = usuarioActual;
            poliza.FechaModificacion = DateTime.Now;

            await _context.SaveChangesAsync();
        }
    }
}
