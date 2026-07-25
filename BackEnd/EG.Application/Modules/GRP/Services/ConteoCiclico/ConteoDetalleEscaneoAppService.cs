using EG.Application.Interfaces.ConteoCiclico;
using EG.Business.Services;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.ConteoCiclico;
using EG.Domain.DTOs.Responses.ConteoCiclico;
using EG.Domain.Interfaces;
using EG.Infraestructure.Models;
using Mapster;
using Microsoft.EntityFrameworkCore;

namespace EG.Application.Services.ConteoCiclico
{
    public class ConteoDetalleEscaneoAppService : IConteoDetalleEscaneoAppService
    {
        private readonly GenericService<VwConteoDetalleEscaneo, ConteoDto, ConteoDetalleEscaneoResponse> _serviceView;
        private readonly EGestionContext _context;

        public ConteoDetalleEscaneoAppService(
            GenericService<VwConteoDetalleEscaneo, ConteoDto, ConteoDetalleEscaneoResponse> serviceView,
            EGestionContext context)
        {
            _serviceView = serviceView;
            _context = context;
        }

        public async Task<PagedResult<ConteoDetalleEscaneoResponse>> GetAllAsync()
        {
            var result = await _serviceView.GetAllAsync();
            return new PagedResult<ConteoDetalleEscaneoResponse>
            {
                Success = true,
                Message = "Escaneos obtenidos correctamente",
                Code = "SUCCESS",
                Items = result.ToList(),
                TotalCount = result.Count()
            };
        }

        public async Task<PagedResult<ConteoDetalleEscaneoResponse>> GetByIdAsync(int id)
        {
            try
            {
                var result = await _serviceView.GetByIdAsync(id, idPropertyName: "PkidDetalleEscaneo");
                if (result == null)
                    return new PagedResult<ConteoDetalleEscaneoResponse>
                    {
                        Success = false,
                        Message = "Escaneo no encontrado",
                        Code = "NOT_FOUND"
                    };

                return new PagedResult<ConteoDetalleEscaneoResponse>
                {
                    Success = true,
                    Message = "Escaneo encontrado",
                    Code = "SUCCESS",
                    Data = result,
                    Items = new List<ConteoDetalleEscaneoResponse> { result },
                    TotalCount = 1
                };
            }
            catch (Exception ex)
            {
                return new PagedResult<ConteoDetalleEscaneoResponse>
                {
                    Success = false,
                    Message = ex.Message,
                    Code = "ERROR"
                };
            }
        }

        public async Task<PagedResult<ConteoDetalleEscaneoResponse>> GetAllPaginadoAsync(PagedRequest pageRequest)
        {
            try
            {
                var result = await _serviceView.GetAllPaginadoAsync(pageRequest);
                return new PagedResult<ConteoDetalleEscaneoResponse>
                {
                    Success = true,
                    Message = "Escaneos obtenidos correctamente",
                    Code = "SUCCESS",
                    Items = result.Items,
                    TotalCount = result.TotalCount
                };
            }
            catch (Exception ex)
            {
                return new PagedResult<ConteoDetalleEscaneoResponse>
                {
                    Success = false,
                    Message = ex.Message,
                    Code = "ERROR"
                };
            }
        }

        public async Task<PagedResult<ConteoDetalleEscaneoResponse>> GetByConteoAsync(int conteoId)
        {
            try
            {
                var filtered = await _context.VwConteoDetalleEscaneos
                    .AsNoTracking()
                    .Where(e => e.FkidConteoAlma == conteoId && e.Activo)
                    .OrderByDescending(e => e.FechaEscaneo)
                    .ProjectToType<ConteoDetalleEscaneoResponse>()
                    .ToListAsync();

                return new PagedResult<ConteoDetalleEscaneoResponse>
                {
                    Success = true,
                    Message = "Escaneos del conteo obtenidos correctamente",
                    Code = "SUCCESS",
                    Items = filtered,
                    TotalCount = filtered.Count
                };
            }
            catch (Exception ex)
            {
                return new PagedResult<ConteoDetalleEscaneoResponse>
                {
                    Success = false,
                    Message = ex.Message,
                    Code = "ERROR"
                };
            }
        }

        public async Task<PagedResult<ConteoDetalleEscaneoResponse>> CreateAsync(ConteoDetalleEscaneoResponse request, int usuarioActual)
        {
            try
            {
                if (!request.FkidBienAlma.HasValue || request.FkidBienAlma.Value <= 0)
                    throw new ArgumentException("Selecciona un bien valido para registrar la lectura.");

                var usuario = await _context.Usuarios
                    .AsNoTracking()
                    .FirstOrDefaultAsync(u => u.PkIdUsuario == usuarioActual && u.Activo);
                if (usuario?.FkidPersonaNom is null or <= 0)
                    throw new InvalidOperationException("El usuario autenticado no tiene una persona activa asociada.");

                var personaActiva = await _context.Personas
                    .AsNoTracking()
                    .AnyAsync(p => p.PkidPersona == usuario.FkidPersonaNom.Value && p.Activo);
                if (!personaActiva)
                    throw new InvalidOperationException("La persona asociada al usuario no existe o no esta activa.");

                var conteo = await _context.Conteos
                    .AsNoTracking()
                    .Include(c => c.FkidPeriodoConteoAlmaNavigation)
                    .FirstOrDefaultAsync(c => c.PkidConteo == request.FkidConteoAlma && c.Activo)
                    ?? throw new ArgumentException("El conteo seleccionado no existe o no esta activo.");

                if (conteo.FkidPeriodoConteoAlmaNavigation == null)
                    throw new InvalidOperationException("El conteo no tiene un periodo activo asociado.");

                var status = await _context.EstatusPeriodos
                    .AsNoTracking()
                    .Where(e => e.PkidEstatusPeriodo == conteo.FkidPeriodoConteoAlmaNavigation.FkidEstatusAlma)
                    .Select(e => e.Nombre)
                    .FirstOrDefaultAsync();
                if (!string.Equals(status, "En Proceso", StringComparison.OrdinalIgnoreCase))
                    throw new InvalidOperationException("Solo se pueden registrar lecturas cuando el periodo esta en proceso.");

                var bien = await _context.Biens
                    .AsNoTracking()
                    .FirstOrDefaultAsync(b => b.PkidBien == request.FkidBienAlma.Value && b.Activo)
                    ?? throw new ArgumentException("El bien seleccionado no existe o no esta activo.");

                if (bien.FkidTipoBienAlma != conteo.FkidTipoBienAlma)
                    throw new ArgumentException("El bien no corresponde al tipo configurado para este conteo.");

                var duplicate = await _context.ConteoDetalleEscaneos.AnyAsync(e =>
                    e.Activo &&
                    e.FkidConteoAlma == conteo.PkidConteo &&
                    e.FkidBienAlma == bien.PkidBien);
                if (duplicate)
                    throw new InvalidOperationException("El bien ya fue registrado en este conteo.");

                var escaneo = new ConteoDetalleEscaneo
                {
                    FkidConteoAlma = request.FkidConteoAlma,
                    FkidPersonaNom = usuario.FkidPersonaNom.Value,
                    FkidBienAlma = bien.PkidBien,
                    FkidTipoBienAlma = bien.FkidTipoBienAlma,
                    CodigoBarras = string.IsNullOrWhiteSpace(request.CodigoBarras)
                        ? bien.Serie ?? bien.Clave
                        : request.CodigoBarras.Trim(),
                    FechaEscaneo = DateTime.Now,
                    Activo = true,
                    UsuarioCreacion = usuarioActual,
                    FechaCreacion = DateTime.Now
                };

                _context.ConteoDetalleEscaneos.Add(escaneo);
                await _context.SaveChangesAsync();

                return new PagedResult<ConteoDetalleEscaneoResponse>
                {
                    Success = true,
                    Message = "Escaneo creado correctamente",
                    Code = "SUCCESS",
                    TotalCount = 1
                };
            }
            catch (Exception ex)
            {
                return new PagedResult<ConteoDetalleEscaneoResponse>
                {
                    Success = false,
                    Message = ex is ArgumentException or InvalidOperationException
                        ? ex.Message
                        : "No fue posible registrar la lectura del bien.",
                    Code = "ERROR"
                };
            }
        }
    }
}
