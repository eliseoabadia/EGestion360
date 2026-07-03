using EG.Application.Interfaces.General;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Responses.General;
using EG.Infraestructure.Models;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;

namespace EG.Application.Services.General
{
    public class DashboardAppService : IDashboardAppService
    {
        private readonly EGestionContext _context;
        private readonly ILogger<DashboardAppService> _logger;

        public DashboardAppService(EGestionContext context, ILogger<DashboardAppService> logger)
        {
            _context = context;
            _logger = logger;
        }

        public async Task<PagedResult<DashboardResumenResponse>> GetResumenAsync()
        {
            try
            {
                var response = new DashboardResumenResponse
                {
                    Conteos = new List<ConteoResumen>
                    {
                        new() { Etiqueta = "Proveedores", Conteo = await _context.Set<Proveedor>().CountAsync(p => p.Activo) },
                        new() { Etiqueta = "Unidades Responsables", Conteo = await _context.Set<Area>().CountAsync(a => a.Activo) },
                        new() { Etiqueta = "Fracciones", Conteo = await _context.Set<Fraccion>().CountAsync(f => f.Activo) },
                        new() { Etiqueta = "Grupos de Bien", Conteo = await _context.Set<GrupoBien>().CountAsync(g => g.Activo) },
                        new() { Etiqueta = "Conceptos", Conteo = await _context.Set<Concepto>().CountAsync(c => c.Activo) },
                        new() { Etiqueta = "Articulos", Conteo = await _context.Set<Articulo>().CountAsync(a => a.Activo) },
                        new() { Etiqueta = "Tipos de Cambio", Conteo = await _context.Set<TipoCambio>().CountAsync(t => t.Activo) },
                        new() { Etiqueta = "Usuarios", Conteo = await _context.Set<Usuario>().CountAsync(u => u.Activo) },
                    }
                };

                return new PagedResult<DashboardResumenResponse>
                {
                    Success = true,
                    Message = "OK",
                    Code = "SUCCESS",
                    Data = response,
                    Items = new List<DashboardResumenResponse> { response },
                    TotalCount = 1
                };
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al obtener resumen del dashboard");
                return new PagedResult<DashboardResumenResponse>
                {
                    Success = false,
                    Message = $"Error: {ex.Message}",
                    Code = "ERROR"
                };
            }
        }
    }
}
