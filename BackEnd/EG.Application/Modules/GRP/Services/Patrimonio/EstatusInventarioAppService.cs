using EG.Application.Interfaces.Patrimonio;
using EG.Business.Services;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.Patrimonio;
using EG.Domain.DTOs.Responses.Patrimonio;
using EG.Infraestructure.Models;
using Mapster;
using Microsoft.EntityFrameworkCore;

namespace EG.Application.Services.Patrimonio
{
    public class EstatusInventarioAppService : IEstatusInventarioAppService
    {
        private readonly GenericService<EstatusInventario, EstatusInventarioDto, EstatusInventarioResponse> _service;
        private readonly EGestionContext _context;

        public EstatusInventarioAppService(GenericService<EstatusInventario, EstatusInventarioDto, EstatusInventarioResponse> service, EGestionContext context)
        {
            _service = service;
            _context = context;
        }

        public async Task<PagedResult<EstatusInventarioResponse>> GetAllAsync()
        {
            var items = (await _service.GetAllAsync()).OrderBy(x => x.Orden).ToList();
            return Success(items, "Estatus de inventario obtenidos correctamente", items.Count);
        }

        public async Task<PagedResult<EstatusInventarioResponse>> GetByIdAsync(int id)
        {
            var item = await _service.GetByIdAsync(id, idPropertyName: "PkidEstatusInventario");
            if (item == null)
            {
                return Failure<EstatusInventarioResponse>($"Estatus de inventario con ID {id} no encontrado.", "NOT_FOUND");
            }

            return new PagedResult<EstatusInventarioResponse>
            {
                Success = true,
                Message = "Estatus de inventario encontrado",
                Code = "SUCCESS",
                Data = item,
                Items = new List<EstatusInventarioResponse> { item },
                TotalCount = 1
            };
        }

        public async Task<PagedResult<EstatusInventarioResponse>> CreateAsync(EstatusInventarioResponse response, int usuarioActual)
        {
            if (string.IsNullOrWhiteSpace(response.Descripcion))
            {
                return Failure<EstatusInventarioResponse>("La descripcion es requerida.");
            }

            if (await _context.EstatusInventarios.AsNoTracking().AnyAsync(x => x.Descripcion == response.Descripcion && x.Activo))
            {
                return Failure<EstatusInventarioResponse>("Ya existe un estatus de inventario activo con esa descripcion.", "DUPLICATE");
            }

            try
            {
                var dto = response.Adapt<EstatusInventarioDto>();
                dto.UsuarioCreacion = usuarioActual;
                dto.FechaCreacion = DateTime.Now;
                dto.Activo = true;

                await _service.AddAsync(dto);
                return Success(new List<EstatusInventarioResponse>(), "Estatus de inventario creado correctamente", 1);
            }
            catch (Exception ex)
            {
                return Failure<EstatusInventarioResponse>($"Error al crear estatus de inventario: {ex.Message}");
            }
        }

        public async Task<PagedResult<EstatusInventarioResponse>> UpdateAsync(int id, EstatusInventarioResponse response, int usuarioActual)
        {
            var current = await _context.EstatusInventarios.AsNoTracking().FirstOrDefaultAsync(x => x.PkidEstatusInventario == id && x.Activo);
            if (current == null)
            {
                return Failure<EstatusInventarioResponse>($"Estatus de inventario con ID {id} no encontrado.", "NOT_FOUND");
            }

            if (await _context.EstatusInventarios.AsNoTracking().AnyAsync(x => x.Descripcion == response.Descripcion && x.PkidEstatusInventario != id && x.Activo))
            {
                return Failure<EstatusInventarioResponse>("Ya existe otro estatus de inventario activo con esa descripcion.", "DUPLICATE");
            }

            try
            {
                var dto = response.Adapt<EstatusInventarioDto>();
                dto.PkidEstatusInventario = id;
                dto.UsuarioCreacion = current.UsuarioCreacion;
                dto.FechaCreacion = current.FechaCreacion;
                dto.UsuarioModificacion = usuarioActual;
                dto.FechaModificacion = DateTime.Now;

                await _service.UpdateAsync(id, dto);
                return Success(new List<EstatusInventarioResponse>(), "Estatus de inventario actualizado correctamente", 1);
            }
            catch (Exception ex)
            {
                return Failure<EstatusInventarioResponse>($"Error al actualizar estatus de inventario: {ex.Message}");
            }
        }

        public async Task<PagedResult<bool>> DeleteAsync(int id)
        {
            try
            {
                await _service.DeleteAsync(id);
                return new PagedResult<bool>
                {
                    Success = true,
                    Message = "Estatus de inventario eliminado correctamente",
                    Code = "SUCCESS",
                    Data = true,
                    Items = new List<bool> { true },
                    TotalCount = 1
                };
            }
            catch (KeyNotFoundException)
            {
                return new PagedResult<bool>
                {
                    Success = false,
                    Message = $"Estatus de inventario con ID {id} no encontrado.",
                    Code = "NOT_FOUND",
                    Data = false,
                    TotalCount = 0
                };
            }
            catch (Exception ex)
            {
                return new PagedResult<bool>
                {
                    Success = false,
                    Message = $"Error al eliminar estatus de inventario: {ex.Message}",
                    Code = "ERROR",
                    Data = false,
                    TotalCount = 0
                };
            }
        }

        public async Task<PagedResult<EstatusInventarioResponse>> GetAllPaginadoAsync(PagedRequest request)
        {
            var result = await _service.GetAllPaginadoAsync(request);
            return new PagedResult<EstatusInventarioResponse>
            {
                Success = result.Success,
                Message = "Estatus de inventario obtenidos correctamente",
                Code = result.Success ? "SUCCESS" : "ERROR",
                Items = result.Items?.OrderBy(x => x.Orden).ToList(),
                TotalCount = result.TotalCount
            };
        }

        private static PagedResult<EstatusInventarioResponse> Success(List<EstatusInventarioResponse> items, string message, int total)
        {
            return new PagedResult<EstatusInventarioResponse>
            {
                Success = true,
                Message = message,
                Code = "SUCCESS",
                Items = items,
                TotalCount = total
            };
        }

        private static PagedResult<T> Failure<T>(string message, string code = "ERROR")
            where T : class
        {
            return new PagedResult<T>
            {
                Success = false,
                Message = message,
                Code = code,
                TotalCount = 0
            };
        }
    }
}
