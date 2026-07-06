using Mapster;
using EG.Application.Interfaces.Adquisicion;
using EG.Business.Services;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.Adquisicion;
using EG.Domain.DTOs.Responses.Adquisicion;
using EG.Infraestructure.Models;
using Microsoft.EntityFrameworkCore;

namespace EG.Application.Services.Adquisicion
{
    public class EstatusRequisicionAppService : IEstatusRequisicionAppService
    {
        private readonly GenericService<EstatusRequisicion, EstatusRequisicionDto, EstatusRequisicionResponse> _service;
        private readonly EGestionContext _context;

        public EstatusRequisicionAppService(
            GenericService<EstatusRequisicion, EstatusRequisicionDto, EstatusRequisicionResponse> service,
            EGestionContext context)
        {
            _service = service;
            _context = context;
        }

        public async Task<PagedResult<EstatusRequisicionResponse>> GetAllAsync()
        {
            var entities = await _context.EstatusRequisicions
                .AsNoTracking()
                .Where(item => item.Activo)
                .OrderBy(item => item.Orden)
                .ThenBy(item => item.Descripcion)
                .ToListAsync();
            var items = entities.Select(ToResponse).ToList();

            return new PagedResult<EstatusRequisicionResponse>
            {
                Success = true,
                Message = "Estatus de Requisicion obtenidos correctamente",
                Code = "SUCCESS",
                Items = items,
                TotalCount = items.Count
            };
        }

        public async Task<PagedResult<EstatusRequisicionResponse>> GetByIdAsync(int id)
        {
            var entity = await _context.EstatusRequisicions
                .AsNoTracking()
                .Where(item => item.PkidEstatusRequisicion == id && item.Activo)
                .FirstOrDefaultAsync();

            if (entity == null)
            {
                return new PagedResult<EstatusRequisicionResponse>
                {
                    Success = false,
                    Message = "Estatus de Requisicion no encontrado",
                    Code = "NOT_FOUND",
                    TotalCount = 0
                };
            }

            var result = ToResponse(entity);
            return new PagedResult<EstatusRequisicionResponse>
            {
                Success = true,
                Message = "Estatus de Requisicion encontrado",
                Code = "SUCCESS",
                Data = result,
                Items = new List<EstatusRequisicionResponse> { result },
                TotalCount = 1
            };
        }

        public async Task<PagedResult<EstatusRequisicionResponse>> CreateAsync(EstatusRequisicionResponse response, int usuarioActual)
        {
            try
            {
                var dto = Normalize(response);
                var duplicate = await _context.EstatusRequisicions
                    .AsNoTracking()
                    .AnyAsync(item => item.Activo && item.Descripcion.ToLower() == dto.Descripcion.ToLower());

                if (duplicate)
                {
                    return new PagedResult<EstatusRequisicionResponse>
                    {
                        Success = false,
                        Message = "Ya existe un estatus de requisicion activo con esa descripcion",
                        Code = "DUPLICATE",
                        TotalCount = 0
                    };
                }

                var entity = dto.Adapt<EstatusRequisicion>();
                entity.UsuarioCreacion = usuarioActual;
                entity.FechaCreacion = DateTime.Now;
                entity.Activo = true;

                _context.EstatusRequisicions.Add(entity);
                await _context.SaveChangesAsync();

                var created = ToResponse(entity);
                return new PagedResult<EstatusRequisicionResponse>
                {
                    Success = true,
                    Message = "Estatus de Requisicion creado correctamente",
                    Code = "SUCCESS",
                    Data = created,
                    Items = new List<EstatusRequisicionResponse> { created },
                    TotalCount = 1
                };
            }
            catch (ArgumentException ex)
            {
                return ValidationError(ex.Message);
            }
            catch (Exception ex)
            {
                return new PagedResult<EstatusRequisicionResponse>
                {
                    Success = false,
                    Message = $"Error al crear estatus de requisicion: {ex.Message}",
                    Code = "ERROR",
                    TotalCount = 0
                };
            }
        }

        public async Task<PagedResult<EstatusRequisicionResponse>> UpdateAsync(int id, EstatusRequisicionResponse response, int usuarioActual)
        {
            try
            {
                var entity = await _context.EstatusRequisicions
                    .FirstOrDefaultAsync(item => item.PkidEstatusRequisicion == id && item.Activo);

                if (entity == null)
                {
                    return new PagedResult<EstatusRequisicionResponse>
                    {
                        Success = false,
                        Message = $"Estatus de Requisicion con ID {id} no encontrado",
                        Code = "NOT_FOUND",
                        TotalCount = 0
                    };
                }

                var dto = Normalize(response);
                var duplicate = await _context.EstatusRequisicions
                    .AsNoTracking()
                    .AnyAsync(item =>
                        item.Activo &&
                        item.PkidEstatusRequisicion != id &&
                        item.Descripcion.ToLower() == dto.Descripcion.ToLower());

                if (duplicate)
                {
                    return new PagedResult<EstatusRequisicionResponse>
                    {
                        Success = false,
                        Message = "Ya existe otro estatus de requisicion activo con esa descripcion",
                        Code = "DUPLICATE",
                        TotalCount = 0
                    };
                }

                entity.Descripcion = dto.Descripcion;
                entity.Color = dto.Color;
                entity.Orden = dto.Orden;
                entity.Icono = dto.Icono;
                entity.Activo = true;
                entity.UsuarioModificacion = usuarioActual;
                entity.FechaModificacion = DateTime.Now;
                await _context.SaveChangesAsync();

                var updated = ToResponse(entity);
                return new PagedResult<EstatusRequisicionResponse>
                {
                    Success = true,
                    Message = "Estatus de Requisicion actualizado correctamente",
                    Code = "SUCCESS",
                    Data = updated,
                    Items = new List<EstatusRequisicionResponse> { updated },
                    TotalCount = 1
                };
            }
            catch (ArgumentException ex)
            {
                return ValidationError(ex.Message);
            }
            catch (Exception ex)
            {
                return new PagedResult<EstatusRequisicionResponse>
                {
                    Success = false,
                    Message = $"Error al actualizar: {ex.Message}",
                    Code = "ERROR",
                    TotalCount = 0
                };
            }
        }

        public async Task<PagedResult<bool>> DeleteAsync(int id)
        {
            try
            {
                var entity = await _context.EstatusRequisicions
                    .FirstOrDefaultAsync(item => item.PkidEstatusRequisicion == id);

                if (entity == null)
                {
                    return new PagedResult<bool>
                    {
                        Success = false,
                        Message = $"Estatus de Requisicion con ID {id} no encontrado",
                        Code = "NOT_FOUND",
                        TotalCount = 0
                    };
                }

                if (!entity.Activo)
                {
                    return new PagedResult<bool>
                    {
                        Success = true,
                        Message = "Estatus de Requisicion ya se encuentra inactivo",
                        Code = "SUCCESS",
                        Data = true,
                        Items = new List<bool> { true },
                        TotalCount = 1
                    };
                }

                entity.Activo = false;
                entity.FechaModificacion = DateTime.Now;
                await _context.SaveChangesAsync();

                var stillActive = await _context.EstatusRequisicions
                    .AsNoTracking()
                    .AnyAsync(item => item.PkidEstatusRequisicion == id && item.Activo);

                if (stillActive)
                {
                    return new PagedResult<bool>
                    {
                        Success = false,
                        Message = $"No fue posible dar de baja EstatusRequisicion con ID {id}; el registro sigue activo en la base de datos.",
                        Code = "ERROR",
                        TotalCount = 0
                    };
                }

                return new PagedResult<bool>
                {
                    Success = true,
                    Message = "Estatus de Requisicion eliminado correctamente",
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
                    Message = $"Error al eliminar: {ex.Message}",
                    Code = "ERROR",
                    TotalCount = 0
                };
            }
        }

        public async Task<PagedResult<EstatusRequisicionResponse>> GetAllPaginadoAsync(PagedRequest request)
        {
            var result = await _service.GetAllPaginadoAsync(request);
            return new PagedResult<EstatusRequisicionResponse>
            {
                Success = true,
                Message = "Estatus de Requisicion obtenidos correctamente",
                Code = "SUCCESS",
                Items = result.Items,
                TotalCount = result.TotalCount
            };
        }

        private static EstatusRequisicionDto Normalize(EstatusRequisicionResponse response)
        {
            if (response == null)
                throw new ArgumentException("Los datos del estatus son requeridos.");

            var descripcion = Trim(response.Descripcion, 50);
            if (string.IsNullOrWhiteSpace(descripcion))
                throw new ArgumentException("Descripcion es requerida.");

            return new EstatusRequisicionDto
            {
                PkidEstatusRequisicion = response.PkidEstatusRequisicion,
                Descripcion = descripcion,
                Color = NormalizeColor(response.Color),
                Orden = response.Orden,
                Icono = Trim(response.Icono, 50),
                Activo = true
            };
        }

        private static PagedResult<EstatusRequisicionResponse> ValidationError(string message)
        {
            return new PagedResult<EstatusRequisicionResponse>
            {
                Success = false,
                Message = message,
                Code = "VALIDATION",
                TotalCount = 0
            };
        }

        private static EstatusRequisicionResponse ToResponse(EstatusRequisicion item)
        {
            return new EstatusRequisicionResponse
            {
                PkidEstatusRequisicion = item.PkidEstatusRequisicion,
                Descripcion = item.Descripcion ?? string.Empty,
                Color = string.IsNullOrWhiteSpace(item.Color) ? "#1A73E8" : item.Color,
                Orden = item.Orden,
                Icono = item.Icono ?? string.Empty,
                Activo = item.Activo,
                FechaCreacion = item.FechaCreacion
            };
        }

        private static string NormalizeColor(string? value)
        {
            var color = Trim(value, 8);
            if (string.IsNullOrWhiteSpace(color))
                return "#1A73E8";

            if (!color.StartsWith("#"))
                color = "#" + color;

            if (color.Length != 7 || !color.Skip(1).All(IsHex))
                throw new ArgumentException("Color debe tener formato hexadecimal #RRGGBB.");

            return color.ToUpperInvariant();
        }

        private static bool IsHex(char value)
            => (value >= '0' && value <= '9') ||
               (value >= 'A' && value <= 'F') ||
               (value >= 'a' && value <= 'f');

        private static string Trim(string? value, int maxLength)
        {
            var trimmed = (value ?? string.Empty).Trim();
            return trimmed.Length <= maxLength ? trimmed : trimmed.Substring(0, maxLength);
        }
    }
}
