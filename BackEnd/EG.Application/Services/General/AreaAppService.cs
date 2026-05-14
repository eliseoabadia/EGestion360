using Mapster;
using EG.Application.Interfaces.General;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Responses.General;
using EG.Infraestructure.Models;
using Microsoft.EntityFrameworkCore;

namespace EG.Application.Services.General
{
    public class AreaAppService : IAreaAppService
    {
        private readonly EGestionContext _context;

        public AreaAppService(EGestionContext context)
        {
            _context = context;
        }

        public async Task<PagedResult<AreaResponse>> GetAreasByPersona(int personaId)
        {
            try
            {
                var areas = await _context.PersonaAreas
                    .Where(pa => pa.FkidPersonaNom == personaId && pa.Activo)
                    .Include(pa => pa.FkidAreaSisNavigation)
                    .Select(pa => new AreaResponse
                    {
                        PkidArea = pa.FkidAreaSis,
                        Clave = pa.FkidAreaSisNavigation != null ? pa.FkidAreaSisNavigation.Clave : string.Empty,
                        Descripcion = pa.FkidAreaSisNavigation != null ? pa.FkidAreaSisNavigation.Nombre : string.Empty,
                        Activo = pa.FkidAreaSisNavigation != null && pa.FkidAreaSisNavigation.Activo,
                        FechaCreacion = pa.FkidAreaSisNavigation != null ? pa.FkidAreaSisNavigation.FechaCreacion : null,
                        UsuarioCreacion = pa.FkidAreaSisNavigation != null ? pa.FkidAreaSisNavigation.UsuarioCreacion : 0
                    })
                    .Distinct()
                    .ToListAsync();

                return new PagedResult<AreaResponse>
                {
                    Items = areas,
                    TotalCount = areas.Count,
                    Success = true,
                    Message = "Áreas obtenidas correctamente",
                    Code = "SUCCESS"
                };
            }
            catch (Exception ex)
            {
                return new PagedResult<AreaResponse>
                {
                    Success = false,
                    Message = $"Error interno: {ex.Message}",
                    Code = "ERROR",
                    TotalCount = 0
                };
            }
        }
    }
}
