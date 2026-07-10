using EG.Application.Interfaces.ConteoCiclico;
using EG.Business.Services;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.ConteoCiclico;
using EG.Domain.DTOs.Responses.ConteoCiclico;
using EG.Infraestructure.Models;
using Microsoft.EntityFrameworkCore;

namespace EG.Application.Services.ConteoCiclico
{
    public class PeriodoConteoAppService : IPeriodoConteoAppService
    {
        private readonly GenericService<PeriodoConteo, PeriodoConteoDto, PeriodoConteoResponse> _service;
        private readonly GenericService<VwPeriodoConteo, PeriodoConteoDto, PeriodoConteoResponse> _serviceView;
        private readonly EGestionContext _context;

        public PeriodoConteoAppService(
            GenericService<PeriodoConteo, PeriodoConteoDto, PeriodoConteoResponse> service,
            GenericService<VwPeriodoConteo, PeriodoConteoDto, PeriodoConteoResponse> serviceView,
            EGestionContext context)
        {
            _service = service;
            _serviceView = serviceView;
            _context = context;
        }

        public async Task<PagedResult<PeriodoConteoResponse>> GetAllAsync()
        {
            var result = await _serviceView.GetAllAsync();
            return new PagedResult<PeriodoConteoResponse>
            {
                Success = true,
                Message = "Períodos obtenidos correctamente",
                Code = "SUCCESS",
                Items = result.ToList(),
                TotalCount = result.Count()
            };
        }

        public async Task<PeriodoConteoResponse> GetByIdAsync(int id)
        {
            return await _serviceView.GetByIdAsync(id, idPropertyName: "PkidPeriodoConteo");
        }

        public async Task<PeriodoConteoResponse> CreateAsync(PeriodoConteoDto dto, int usuarioActual)
        {
            dto.UsuarioCreacion = usuarioActual;
            dto.FechaCreacion = DateTime.Now;
            await NormalizeAsync(dto);
            await _service.AddAsync(dto);
            return await _serviceView.GetByIdAsync(dto.PkidPeriodoConteo, idPropertyName: "PkidPeriodoConteo");
        }

        public async Task<PeriodoConteoResponse> UpdateAsync(int id, PeriodoConteoDto dto, int usuarioActual)
        {
            dto.PkidPeriodoConteo = id;
            dto.UsuarioModificacion = usuarioActual;
            dto.FechaModificacion = DateTime.Now;
            await NormalizeAsync(dto);
            await _service.UpdateAsync(id, dto);
            return await _serviceView.GetByIdAsync(id, idPropertyName: "PkidPeriodoConteo");
        }

        private async Task NormalizeAsync(PeriodoConteoDto dto)
        {
            dto.CodigoPeriodo = (dto.CodigoPeriodo ?? string.Empty).Trim();
            dto.Nombre = (dto.Nombre ?? string.Empty).Trim();
            dto.Descripcion = (dto.Descripcion ?? string.Empty).Trim();

            if (string.IsNullOrWhiteSpace(dto.CodigoPeriodo))
            {
                throw new ArgumentException("El codigo del periodo es requerido.");
            }

            if (string.IsNullOrWhiteSpace(dto.Nombre))
            {
                throw new ArgumentException("El nombre del periodo es requerido.");
            }

            if (dto.FkidSucursalSis <= 0)
            {
                throw new ArgumentException("Selecciona una sucursal valida.");
            }

            if (!await _context.Sucursals.AnyAsync(s => s.PkidSucursal == dto.FkidSucursalSis && s.Activo))
            {
                throw new ArgumentException("La sucursal seleccionada no existe o no esta activa.");
            }

            if (dto.FkidTipoConteoAlma <= 0 || !await _context.TipoConteos.AnyAsync(t => t.PkidTipoConteo == dto.FkidTipoConteoAlma && t.Activo))
            {
                dto.FkidTipoConteoAlma = await GetDefaultTipoConteoIdAsync();
            }

            if (dto.FkidEstatusAlma <= 0 || !await _context.EstatusPeriodos.AnyAsync(e => e.PkidEstatusPeriodo == dto.FkidEstatusAlma && e.Activo))
            {
                dto.FkidEstatusAlma = await GetDefaultEstatusPeriodoIdAsync();
            }
        }

        private async Task<int> GetDefaultTipoConteoIdAsync()
        {
            var tipoId = await _context.TipoConteos
                .Where(t => t.Activo)
                .OrderBy(t => t.PkidTipoConteo)
                .Select(t => t.PkidTipoConteo)
                .FirstOrDefaultAsync();

            if (tipoId <= 0)
            {
                throw new ArgumentException("No hay tipos de conteo activos para crear el periodo.");
            }

            return tipoId;
        }

        private async Task<int> GetDefaultEstatusPeriodoIdAsync()
        {
            var estatus = await _context.EstatusPeriodos
                .Where(e => e.Activo)
                .OrderByDescending(e => e.Nombre.Contains("Abierto"))
                .ThenByDescending(e => e.Nombre.Contains("Activo"))
                .ThenBy(e => e.PkidEstatusPeriodo)
                .Select(e => e.PkidEstatusPeriodo)
                .FirstOrDefaultAsync();

            if (estatus <= 0)
            {
                throw new ArgumentException("No hay estatus de periodo activos para crear el periodo.");
            }

            return estatus;
        }

        public async Task<bool> DeleteAsync(int id)
        {
            await _service.DeleteAsync(id);
            return true;
        }

        public async Task<PagedResult<PeriodoConteoResponse>> GetAllPaginadoAsync(PagedRequest pageRequest)
        {
            var result = await _serviceView.GetAllPaginadoAsync(pageRequest);
            return new PagedResult<PeriodoConteoResponse>
            {
                Success = true,
                Message = "Períodos obtenidos correctamente",
                Code = "SUCCESS",
                Items = result.Items,
                TotalCount = result.TotalCount
            };
        }
    }
}
