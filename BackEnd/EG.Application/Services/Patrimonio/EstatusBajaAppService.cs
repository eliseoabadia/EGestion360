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
    public class EstatusBajaAppService : IEstatusBajaAppService
    {
        private readonly GenericService<EstatusBaja, EstatusBajaDto, EstatusBajaResponse> _service;
        private readonly EGestionContext _context;

        public EstatusBajaAppService(GenericService<EstatusBaja, EstatusBajaDto, EstatusBajaResponse> service, EGestionContext context)
        {
            _service = service;
            _context = context;
        }

        public async Task<PagedResult<EstatusBajaResponse>> GetAllAsync()
        {
            var items = (await _service.GetAllAsync()).OrderBy(x => x.Orden).ToList();
            return Success(items, "Estatus de baja obtenidos correctamente", items.Count);
        }

        public async Task<PagedResult<EstatusBajaResponse>> GetByIdAsync(int id)
        {
            var item = await _service.GetByIdAsync(id, idPropertyName: "PkidEstatusBaja");
            if (item == null)
            {
                return Failure<EstatusBajaResponse>($"Estatus de baja con ID {id} no encontrado.", "NOT_FOUND");
            }

            return new PagedResult<EstatusBajaResponse>
            {
                Success = true,
                Message = "Estatus de baja encontrado",
                Code = "SUCCESS",
                Data = item,
                Items = new List<EstatusBajaResponse> { item },
                TotalCount = 1
            };
        }

        public async Task<PagedResult<EstatusBajaResponse>> CreateAsync(EstatusBajaResponse response, int usuarioActual)
        {
            if (string.IsNullOrWhiteSpace(response.Descripcion))
            {
                return Failure<EstatusBajaResponse>("La descripcion es requerida.");
            }

            if (await _context.EstatusBajas.AsNoTracking().AnyAsync(x => x.Descripcion == response.Descripcion && x.Activo))
            {
                return Failure<EstatusBajaResponse>("Ya existe un estatus de baja activo con esa descripcion.", "DUPLICATE");
            }

            try
            {
                var dto = response.Adapt<EstatusBajaDto>();
                dto.UsuarioCreacion = usuarioActual;
                dto.FechaCreacion = DateTime.Now;
                dto.Activo = true;

                await _service.AddAsync(dto);
                return Success(new List<EstatusBajaResponse>(), "Estatus de baja creado correctamente", 1);
            }
            catch (Exception ex)
            {
                return Failure<EstatusBajaResponse>($"Error al crear estatus de baja: {ex.Message}");
            }
        }

        public async Task<PagedResult<EstatusBajaResponse>> UpdateAsync(int id, EstatusBajaResponse response, int usuarioActual)
        {
            var current = await _context.EstatusBajas.AsNoTracking().FirstOrDefaultAsync(x => x.PkidEstatusBaja == id && x.Activo);
            if (current == null)
            {
                return Failure<EstatusBajaResponse>($"Estatus de baja con ID {id} no encontrado.", "NOT_FOUND");
            }

            if (await _context.EstatusBajas.AsNoTracking().AnyAsync(x => x.Descripcion == response.Descripcion && x.PkidEstatusBaja != id && x.Activo))
            {
                return Failure<EstatusBajaResponse>("Ya existe otro estatus de baja activo con esa descripcion.", "DUPLICATE");
            }

            try
            {
                var dto = response.Adapt<EstatusBajaDto>();
                dto.PkidEstatusBaja = id;
                dto.UsuarioCreacion = current.UsuarioCreacion;
                dto.FechaCreacion = current.FechaCreacion;
                dto.UsuarioModificacion = usuarioActual;
                dto.FechaModificacion = DateTime.Now;

                await _service.UpdateAsync(id, dto);
                return Success(new List<EstatusBajaResponse>(), "Estatus de baja actualizado correctamente", 1);
            }
            catch (Exception ex)
            {
                return Failure<EstatusBajaResponse>($"Error al actualizar estatus de baja: {ex.Message}");
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
                    Message = "Estatus de baja eliminado correctamente",
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
                    Message = $"Estatus de baja con ID {id} no encontrado.",
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
                    Message = $"Error al eliminar estatus de baja: {ex.Message}",
                    Code = "ERROR",
                    Data = false,
                    TotalCount = 0
                };
            }
        }

        public async Task<PagedResult<EstatusBajaResponse>> GetAllPaginadoAsync(PagedRequest request)
        {
            var result = await _service.GetAllPaginadoAsync(request);
            return new PagedResult<EstatusBajaResponse>
            {
                Success = result.Success,
                Message = "Estatus de baja obtenidos correctamente",
                Code = result.Success ? "SUCCESS" : "ERROR",
                Items = result.Items?.OrderBy(x => x.Orden).ToList(),
                TotalCount = result.TotalCount
            };
        }

        private static PagedResult<EstatusBajaResponse> Success(List<EstatusBajaResponse> items, string message, int total)
        {
            return new PagedResult<EstatusBajaResponse>
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
