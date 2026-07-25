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
                var query = _context.VwBiens.AsNoTracking().Where(b => b.Activo);
                if (!string.IsNullOrWhiteSpace(tipoBienCodigo))
                    query = query.Where(b => b.TipoBienCodigoClave == tipoBienCodigo);

                if (!string.IsNullOrWhiteSpace(filtro))
                {
                    var term = filtro.Trim();
                    query = query.Where(b =>
                        (b.Clave != null && b.Clave.Contains(term)) ||
                        (b.ClaveAnt != null && b.ClaveAnt.Contains(term)) ||
                        (b.Descripcion != null && b.Descripcion.Contains(term)) ||
                        (b.Serie != null && b.Serie.Contains(term)) ||
                        (b.Modelo != null && b.Modelo.Contains(term)));
                }

                page = Math.Max(1, page);
                pageSize = Math.Clamp(pageSize, 1, 100);
                var total = await query.CountAsync();
                var entities = await query.OrderBy(b => b.Clave)
                    .Skip((page - 1) * pageSize)
                    .Take(pageSize)
                    .ToListAsync();
                var bienes = await MapBienesAsync(entities);

                return new PagedResult<BienResponse>
                {
                    Success = true,
                    Message = "Bienes obtenidos correctamente",
                    Code = "SUCCESS",
                    Items = bienes,
                    TotalCount = total
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
                var value = (codigo ?? string.Empty).Trim();
                if (string.IsNullOrWhiteSpace(value))
                    throw new ArgumentException("El codigo del bien es requerido.");

                var query = _context.VwBiens.AsNoTracking().Where(b =>
                    b.Activo && (b.Clave == value || b.ClaveAnt == value || b.Serie == value));

                if (!string.IsNullOrWhiteSpace(tipoBienCodigo))
                    query = query.Where(b => b.TipoBienCodigoClave == tipoBienCodigo);

                var entities = await query.OrderBy(b => b.PkidBien).Take(10).ToListAsync();
                var bienes = await MapBienesAsync(entities);

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

        private async Task<List<BienResponse>> MapBienesAsync(List<VwBien> entities)
        {
            var ids = entities.Select(b => b.PkidBien).ToList();
            var tipoIds = await _context.Biens.AsNoTracking()
                .Where(b => ids.Contains(b.PkidBien))
                .ToDictionaryAsync(b => b.PkidBien, b => b.FkidTipoBienAlma);

            return entities.Select(b => new BienResponse
            {
                PkidBien = b.PkidBien,
                FkidTipoBienAlma = tipoIds.GetValueOrDefault(b.PkidBien),
                Clave = b.Clave,
                ClaveAnt = b.ClaveAnt,
                Descripcion = b.Descripcion,
                Modelo = b.Modelo,
                Serie = b.Serie,
                Costo = b.Costo,
                FechaAdq = b.FechaAdq,
                Factura = b.Factura,
                Ubicacion = b.Ubicacion,
                Estatus = b.Estatus,
                Activo = b.Activo,
                GrupoBienDescripcion = b.GrupoBienDescripcion,
                GrupoBienClave = b.GrupoBienClave,
                TipoBienCodigoClave = b.TipoBienCodigoClave,
                TipoBienDescripcion = b.TipoBienDescripcion,
                MarcaDescripcion = b.MarcaDescripcion,
                EstadoBienDescripcionGeneral = b.EstadoBienDescripcionGeneral
            }).ToList();
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
