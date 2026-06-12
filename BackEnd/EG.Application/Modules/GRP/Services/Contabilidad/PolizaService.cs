using EG.Application.Interfaces.Contabilidad;
using EG.Application.Services.Adquisicion;
using EG.Business.Services;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.Contabilidad;
using EG.Domain.DTOs.Responses.Contabilidad;
using EG.Infraestructure.Models;
using Microsoft.EntityFrameworkCore;

namespace EG.ApiCoreBS.Services.Contabilidad
{
    public class PolizaService
        : AdquisicionCrudAppService<Poliza, VwPoliza, PolizaDto, PolizaResponse>,
            IPolizaService
    {
        private readonly EGestionContext _context;

        public PolizaService(
            GenericService<Poliza, PolizaDto, PolizaResponse> service,
            GenericService<VwPoliza, PolizaDto, PolizaResponse> serviceView,
            EGestionContext context)
            : base(
                service,
                serviceView,
                "PkidPoliza",
                "Poliza",
                (dto, id) => dto.PkidPoliza = id)
        {
            _context = context;
        }

        public override Task<PagedResult<PolizaResponse>> CreateAsync(PolizaResponse response, int usuarioActual)
        {
            response.FechaPoliza = response.FechaPoliza == default ? DateTime.Today : response.FechaPoliza;
            response.EstaBalanceado = false;
            response.PermitirModificar ??= true;
            response.Autorizado ??= false;

            return base.CreateAsync(response, usuarioActual);
        }

        public async Task<PagedResult<bool>> DeleteAsync(int id, int usuarioActual)
        {
            try
            {
                var poliza = await _context.Polizas
                    .Include(x => x.PolizaDetalles)
                    .FirstOrDefaultAsync(x => x.PkidPoliza == id && x.Activo);

                if (poliza == null)
                {
                    return NotFound(id);
                }

                var now = DateTime.Now;
                poliza.Activo = false;
                poliza.UsuarioModificacion = usuarioActual;
                poliza.FechaModificacion = now;

                foreach (var detalle in poliza.PolizaDetalles.Where(x => x.Activo))
                {
                    detalle.Activo = false;
                    detalle.UsuarioModificacion = usuarioActual;
                    detalle.FechaModificacion = now;
                }

                await _context.SaveChangesAsync();

                return new PagedResult<bool>
                {
                    Success = true,
                    Message = "Poliza eliminada correctamente",
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
                    Message = $"Error al eliminar Poliza: {ex.Message}",
                    Code = "ERROR",
                    Data = false,
                    TotalCount = 0
                };
            }
        }

        private static PagedResult<bool> NotFound(int id) => new()
        {
            Success = false,
            Message = $"Poliza con ID {id} no encontrada",
            Code = "NOT_FOUND",
            Data = false,
            TotalCount = 0
        };
    }
}
