using EG.Application.Interfaces.ConteoCiclico;
using EG.Business.Services;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.ConteoCiclico;
using EG.Domain.DTOs.Responses.ConteoCiclico;
using EG.Domain.Interfaces;
using EG.Infraestructure.Models;
using Microsoft.EntityFrameworkCore;

namespace EG.Application.Services.ConteoCiclico
{
    public class ConteoDetalleAppService : IConteoDetalleAppService
    {
        private readonly GenericService<ConteoDetalle, ConteoDetalleDto, ConteoDetalleResponse> _service;
        private readonly GenericService<VwBien, BienResponse, BienResponse> _bienService;
        private readonly EGestionContext _context;
        private readonly IUserContextService _userContext;

        public ConteoDetalleAppService(
            GenericService<ConteoDetalle, ConteoDetalleDto, ConteoDetalleResponse> service,
            GenericService<VwBien, BienResponse, BienResponse> bienService,
            EGestionContext context,
            IUserContextService userContext)
        {
            _service = service;
            _bienService = bienService;
            _context = context;
            _userContext = userContext;
        }

        public async Task<PagedResult<BienResponse>> BuscarBienes(string? filtro, string? tipoBienCodigo, int page = 1, int pageSize = 20)
        {
            try
            {
                var request = new PagedRequest
                {
                    Page = page,
                    PageSize = pageSize,
                    Filtro = filtro ?? string.Empty,
                    SortLabel = "Clave",
                    SortDirection = "Ascending"
                };

                var result = await _bienService.GetAllPaginadoAsync(request);
                var bienes = result.Items.ToList();

                if (!string.IsNullOrWhiteSpace(tipoBienCodigo))
                {
                    bienes = bienes.Where(b =>
                        b.TipoBienCodigoClave?.Equals(tipoBienCodigo, StringComparison.OrdinalIgnoreCase) == true
                    ).ToList();
                }

                if (!string.IsNullOrWhiteSpace(filtro))
                {
                    bienes = bienes.Where(b =>
                        (b.Clave?.Contains(filtro, StringComparison.OrdinalIgnoreCase) ?? false) ||
                        (b.ClaveAnt?.Contains(filtro, StringComparison.OrdinalIgnoreCase) ?? false) ||
                        (b.Descripcion?.Contains(filtro, StringComparison.OrdinalIgnoreCase) ?? false) ||
                        (b.Serie?.Contains(filtro, StringComparison.OrdinalIgnoreCase) ?? false) ||
                        (b.Modelo?.Contains(filtro, StringComparison.OrdinalIgnoreCase) ?? false)
                    ).ToList();
                }

                return new PagedResult<BienResponse>
                {
                    Success = true,
                    Message = "Bienes obtenidos correctamente",
                    Code = "SUCCESS",
                    Items = bienes,
                    TotalCount = bienes.Count
                };
            }
            catch (Exception ex)
            {
                return new PagedResult<BienResponse>
                {
                    Success = false,
                    Message = ex.Message,
                    Code = "ERROR"
                };
            }
        }

        public async Task<PagedResult<BienResponse>> BuscarPorCodigo(string codigo, string? tipoBienCodigo = null)
        {
            try
            {
                var filtro = codigo.ToLower();
                var request = new PagedRequest
                {
                    Page = 1,
                    PageSize = 50,
                    Filtro = string.Empty,
                    SortLabel = "Clave",
                    SortDirection = "Ascending"
                };

                var result = await _bienService.GetAllPaginadoAsync(request);
                var bienes = result.Items.Where(b =>
                    (b.Clave?.ToLower() == filtro ||
                    b.ClaveAnt?.ToLower() == filtro ||
                    b.Serie?.ToLower() == filtro) &&
                    (string.IsNullOrWhiteSpace(tipoBienCodigo) ||
                     b.TipoBienCodigoClave?.Equals(tipoBienCodigo, StringComparison.OrdinalIgnoreCase) == true)
                ).ToList();

                return new PagedResult<BienResponse>
                {
                    Success = true,
                    Message = bienes.Any() ? "Bien encontrado" : "No se encontraron bienes",
                    Code = "SUCCESS",
                    Items = bienes,
                    TotalCount = bienes.Count
                };
            }
            catch (Exception ex)
            {
                return new PagedResult<BienResponse>
                {
                    Success = false,
                    Message = ex.Message,
                    Code = "ERROR"
                };
            }
        }

        public async Task<PagedResult<ConteoDetalleResponse>> AgregarBien(AgregarBienConteoDto dto, int usuarioActual)
        {
            try
            {
                var conteoDetalle = new ConteoDetalle
                {
                    FkidConteoAlma = dto.FkidConteoAlma,
                    FkidNumeroConteoAlma = dto.FkidNumeroConteoAlma,
                    FkidPersonaNom = dto.FkidPersonaNom,
                    Cantidad = dto.Cantidad,
                    Fecha = DateTime.Now,
                    Activo = true,
                    UsuarioCreacion = usuarioActual,
                    FechaCreacion = DateTime.Now
                };

                _context.ConteoDetalles.Add(conteoDetalle);
                await _context.SaveChangesAsync();

                return new PagedResult<ConteoDetalleResponse>
                {
                    Success = true,
                    Message = "Bien agregado al conteo correctamente",
                    Code = "SUCCESS",
                    TotalCount = 1
                };
            }
            catch (Exception ex)
            {
                return new PagedResult<ConteoDetalleResponse>
                {
                    Success = false,
                    Message = $"Error al agregar bien: {ex.Message}",
                    Code = "ERROR"
                };
            }
        }

        public async Task<PagedResult<ConteoDetalleResponse>> GetPorConteo(int conteoId)
        {
            try
            {
                var detalles = await _context.ConteoDetalles
                    .Where(d => d.FkidConteoAlma == conteoId)
                    .Include(d => d.FkidPersonaNomNavigation)
                    .ToListAsync();

                var response = detalles.Select(d => new ConteoDetalleResponse
                {
                    PkidDetalleConteo = d.PkidDetalleConteo,
                    FkidConteoAlma = d.FkidConteoAlma,
                    FkidNumeroConteoAlma = d.FkidNumeroConteoAlma,
                    FkidPersonaNom = d.FkidPersonaNom,
                    PersonaNombre = d.FkidPersonaNomNavigation != null
                        ? $"{d.FkidPersonaNomNavigation.Nombre} {d.FkidPersonaNomNavigation.Paterno} {d.FkidPersonaNomNavigation.Materno}".Trim()
                        : null,
                    Cantidad = d.Cantidad,
                    Fecha = d.Fecha,
                    Activo = d.Activo,
                    FechaCreacion = d.FechaCreacion,
                    UsuarioCreacion = d.UsuarioCreacion,
                    FechaModificacion = d.FechaModificacion,
                    UsuarioModificacion = d.UsuarioModificacion
                });

                return new PagedResult<ConteoDetalleResponse>
                {
                    Success = true,
                    Message = "Detalles obtenidos correctamente",
                    Code = "SUCCESS",
                    Items = response.ToList(),
                    TotalCount = response.Count()
                };
            }
            catch (Exception ex)
            {
                return new PagedResult<ConteoDetalleResponse>
                {
                    Success = false,
                    Message = ex.Message,
                    Code = "ERROR"
                };
            }
        }

        public async Task<PagedResult<ConteoDetalleResponse>> ActualizarCantidad(int id, decimal cantidad, int usuarioActual)
        {
            try
            {
                var detalle = await _context.ConteoDetalles.FindAsync(id);
                if (detalle == null)
                {
                    return new PagedResult<ConteoDetalleResponse>
                    {
                        Success = false,
                        Message = "Detalle no encontrado",
                        Code = "NOT_FOUND"
                    };
                }

                detalle.Cantidad = cantidad;
                detalle.FechaModificacion = DateTime.Now;
                detalle.UsuarioModificacion = usuarioActual;

                await _context.SaveChangesAsync();

                return new PagedResult<ConteoDetalleResponse>
                {
                    Success = true,
                    Message = "Cantidad actualizada correctamente",
                    Code = "SUCCESS",
                    TotalCount = 1
                };
            }
            catch (Exception ex)
            {
                return new PagedResult<ConteoDetalleResponse>
                {
                    Success = false,
                    Message = ex.Message,
                    Code = "ERROR"
                };
            }
        }

        public async Task<PagedResult<bool>> Delete(int id)
        {
            try
            {
                var detalle = await _context.ConteoDetalles.FindAsync(id);
                if (detalle == null)
                {
                    return new PagedResult<bool>
                    {
                        Success = false,
                        Message = "Detalle no encontrado",
                        Code = "NOT_FOUND"
                    };
                }

                detalle.Activo = false;
                detalle.FechaModificacion = DateTime.Now;
                await _context.SaveChangesAsync();

                return new PagedResult<bool>
                {
                    Success = true,
                    Message = "Detalle eliminado correctamente",
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
                    Message = ex.Message,
                    Code = "ERROR"
                };
            }
        }
    }
}
