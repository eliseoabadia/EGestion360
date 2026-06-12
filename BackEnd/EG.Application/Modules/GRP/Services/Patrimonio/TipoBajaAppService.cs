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
    public class TipoBajaAppService : ITipoBajaAppService
    {
        private readonly GenericService<TipoBaja, TipoBajaDto, TipoBajaResponse> _service;
        private readonly EGestionContext _context;

        public TipoBajaAppService(GenericService<TipoBaja, TipoBajaDto, TipoBajaResponse> service, EGestionContext context)
        {
            _service = service;
            _context = context;
        }

        public async Task<PagedResult<TipoBajaResponse>> GetAllAsync()
        {
            var items = (await _service.GetAllAsync()).ToList();
            return Success(items, "Tipos de baja obtenidos correctamente", items.Count);
        }

        public async Task<PagedResult<TipoBajaResponse>> GetByIdAsync(int id)
        {
            var item = await _service.GetByIdAsync(id, idPropertyName: "PkidTipoBaja");
            if (item == null)
            {
                return Failure<TipoBajaResponse>($"Tipo de baja con ID {id} no encontrado.", "NOT_FOUND");
            }

            return new PagedResult<TipoBajaResponse>
            {
                Success = true,
                Message = "Tipo de baja encontrado",
                Code = "SUCCESS",
                Data = item,
                Items = new List<TipoBajaResponse> { item },
                TotalCount = 1
            };
        }

        public async Task<PagedResult<TipoBajaResponse>> CreateAsync(TipoBajaResponse response, int usuarioActual)
        {
            if (string.IsNullOrWhiteSpace(response.Clave) || string.IsNullOrWhiteSpace(response.Descripcion))
            {
                return Failure<TipoBajaResponse>("La clave y descripcion son requeridas.");
            }

            if (await _context.TipoBajas.AsNoTracking().AnyAsync(x => x.Clave == response.Clave && x.Activo))
            {
                return Failure<TipoBajaResponse>("Ya existe un tipo de baja activo con esa clave.", "DUPLICATE");
            }

            try
            {
                var dto = response.Adapt<TipoBajaDto>();
                dto.UsuarioCreacion = usuarioActual;
                dto.FechaCreacion = DateTime.Now;
                dto.Activo = true;

                await _service.AddAsync(dto);
                return Success(new List<TipoBajaResponse>(), "Tipo de baja creado correctamente", 1);
            }
            catch (Exception ex)
            {
                return Failure<TipoBajaResponse>($"Error al crear tipo de baja: {ex.Message}");
            }
        }

        public async Task<PagedResult<TipoBajaResponse>> UpdateAsync(int id, TipoBajaResponse response, int usuarioActual)
        {
            var current = await _context.TipoBajas.AsNoTracking().FirstOrDefaultAsync(x => x.PkidTipoBaja == id && x.Activo);
            if (current == null)
            {
                return Failure<TipoBajaResponse>($"Tipo de baja con ID {id} no encontrado.", "NOT_FOUND");
            }

            if (await _context.TipoBajas.AsNoTracking().AnyAsync(x => x.Clave == response.Clave && x.PkidTipoBaja != id && x.Activo))
            {
                return Failure<TipoBajaResponse>("Ya existe otro tipo de baja activo con esa clave.", "DUPLICATE");
            }

            try
            {
                var dto = response.Adapt<TipoBajaDto>();
                dto.PkidTipoBaja = id;
                dto.UsuarioCreacion = current.UsuarioCreacion;
                dto.FechaCreacion = current.FechaCreacion;
                dto.UsuarioModificacion = usuarioActual;
                dto.FechaModificacion = DateTime.Now;

                await _service.UpdateAsync(id, dto);
                return Success(new List<TipoBajaResponse>(), "Tipo de baja actualizado correctamente", 1);
            }
            catch (Exception ex)
            {
                return Failure<TipoBajaResponse>($"Error al actualizar tipo de baja: {ex.Message}");
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
                    Message = "Tipo de baja eliminado correctamente",
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
                    Message = $"Tipo de baja con ID {id} no encontrado.",
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
                    Message = $"Error al eliminar tipo de baja: {ex.Message}",
                    Code = "ERROR",
                    Data = false,
                    TotalCount = 0
                };
            }
        }

        public async Task<PagedResult<TipoBajaResponse>> GetAllPaginadoAsync(PagedRequest request)
        {
            var result = await _service.GetAllPaginadoAsync(request);
            return new PagedResult<TipoBajaResponse>
            {
                Success = result.Success,
                Message = "Tipos de baja obtenidos correctamente",
                Code = result.Success ? "SUCCESS" : "ERROR",
                Items = result.Items,
                TotalCount = result.TotalCount
            };
        }

        private static PagedResult<TipoBajaResponse> Success(List<TipoBajaResponse> items, string message, int total)
        {
            return new PagedResult<TipoBajaResponse>
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
