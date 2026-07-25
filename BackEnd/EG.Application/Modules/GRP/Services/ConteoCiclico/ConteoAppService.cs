using EG.Application.Interfaces.ConteoCiclico;
using EG.Business.Services;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.ConteoCiclico;
using EG.Domain.DTOs.Responses.ConteoCiclico;
using EG.Infraestructure.Models;
using Microsoft.EntityFrameworkCore;

namespace EG.Application.Services.ConteoCiclico
{
    public class ConteoAppService : IConteoAppService
    {
        private readonly GenericService<Conteo, ConteoDto, ConteoResponse> _service;
        private readonly GenericService<VwConteo, ConteoDto, ConteoResponse> _serviceView;
        private readonly EGestionContext _context;

        public ConteoAppService(
            GenericService<Conteo, ConteoDto, ConteoResponse> service,
            GenericService<VwConteo, ConteoDto, ConteoResponse> serviceView,
            EGestionContext context)
        {
            _service = service;
            _serviceView = serviceView;
            _context = context;
        }

        public async Task<PagedResult<ConteoResponse>> GetAllAsync()
        {
            var result = await _serviceView.GetAllAsync();
            return new PagedResult<ConteoResponse>
            {
                Success = true,
                Message = "Conteos obtenidos correctamente",
                Code = "SUCCESS",
                Items = result.ToList(),
                TotalCount = result.Count()
            };
        }

        public async Task<ConteoResponse> GetByIdAsync(int id)
        {
            return await _serviceView.GetByIdAsync(id, idPropertyName: "PkidConteo");
        }

        public async Task<ConteoResponse> CreateAsync(ConteoDto dto, int usuarioActual)
        {
            ConteoCiclicoValidator.ValidateConteo(dto);
            await ValidateReferencesAndStatusAsync(dto);

            var duplicate = await _context.Conteos.AnyAsync(c =>
                c.Activo &&
                c.FkidPeriodoConteoAlma == dto.FkidPeriodoConteoAlma &&
                c.FkidTipoBienAlma == dto.FkidTipoBienAlma);
            if (duplicate)
                throw new ArgumentException("Ya existe un conteo activo para ese tipo de bien en el periodo.");

            dto.UsuarioCreacion = usuarioActual;
            dto.FechaCreacion = DateTime.Now;
            await _service.AddAsync(dto);
            return await _serviceView.GetByIdAsync(dto.PkidConteo, idPropertyName: "PkidConteo")
                ?? MapFromDto(dto);
        }

        public async Task<ConteoResponse> UpdateAsync(int id, ConteoDto dto, int usuarioActual)
        {
            ConteoCiclicoValidator.ValidateConteo(dto);
            var existing = await _service.GetByIdAsync(id);
            if (existing == null)
            {
                throw new KeyNotFoundException($"Conteo con ID {id} no encontrado.");
            }

            await ValidateReferencesAndStatusAsync(dto);
            if (await _context.ConteoDetalleEscaneos.AnyAsync(e => e.FkidConteoAlma == id && e.Activo))
                throw new InvalidOperationException("No se puede modificar un conteo que ya tiene lecturas registradas.");

            var duplicate = await _context.Conteos.AnyAsync(c =>
                c.Activo && c.PkidConteo != id &&
                c.FkidPeriodoConteoAlma == dto.FkidPeriodoConteoAlma &&
                c.FkidTipoBienAlma == dto.FkidTipoBienAlma);
            if (duplicate)
                throw new ArgumentException("Ya existe otro conteo activo para ese tipo de bien en el periodo.");

            dto.PkidConteo = id;
            dto.UsuarioCreacion = existing.UsuarioCreacion;
            dto.FechaCreacion = existing.FechaCreacion;
            dto.UsuarioModificacion = usuarioActual;
            dto.FechaModificacion = DateTime.Now;
            await _service.UpdateAsync(id, dto);
            return await _serviceView.GetByIdAsync(id, idPropertyName: "PkidConteo")
                ?? MapFromDto(dto);
        }

        public async Task<bool> DeleteAsync(int id)
        {
            var existing = await _context.Conteos
                .Include(c => c.FkidPeriodoConteoAlmaNavigation)
                .FirstOrDefaultAsync(c => c.PkidConteo == id && c.Activo)
                ?? throw new KeyNotFoundException($"Conteo con ID {id} no encontrado.");

            await EnsureEditablePeriodStatusAsync(existing.FkidPeriodoConteoAlmaNavigation);
            if (await _context.ConteoDetalleEscaneos.AnyAsync(e => e.FkidConteoAlma == id && e.Activo))
                throw new InvalidOperationException("No se puede eliminar un conteo que ya tiene lecturas registradas.");

            await _service.DeleteAsync(id);
            return true;
        }

        public async Task<PagedResult<ConteoResponse>> GetAllPaginadoAsync(PagedRequest pageRequest)
        {
            var result = await _serviceView.GetAllPaginadoAsync(pageRequest);
            return new PagedResult<ConteoResponse>
            {
                Success = true,
                Message = "Conteos obtenidos correctamente",
                Code = "SUCCESS",
                Items = result.Items,
                TotalCount = result.TotalCount
            };
        }

        private static ConteoResponse MapFromDto(ConteoDto dto) => new()
        {
            PkidConteo = dto.PkidConteo,
            IdTipoBien = dto.FkidTipoBienAlma,
            IdPeriodoConteo = dto.FkidPeriodoConteoAlma,
            CantidadInventario = dto.CantidadInventario,
            Descripcion = dto.Descripcion,
            FechaInicio = dto.FechaInicio,
            FechaFin = dto.FechaFin,
            Activo = dto.Activo,
            FechaCreacion = dto.FechaCreacion,
            UsuarioCreacion = dto.UsuarioCreacion,
            FechaModificacion = dto.FechaModificacion,
            UsuarioModificacion = dto.UsuarioModificacion
        };

        private async Task ValidateReferencesAndStatusAsync(ConteoDto dto)
        {
            if (!dto.FkidPeriodoConteoAlma.HasValue || dto.FkidPeriodoConteoAlma.Value <= 0)
                throw new ArgumentException("Selecciona un periodo de conteo.");

            if (!await _context.TipoBiens.AnyAsync(t => t.PkidTipoBien == dto.FkidTipoBienAlma && t.Activo))
                throw new ArgumentException("El tipo de bien seleccionado no existe o no esta activo.");

            var periodo = await _context.PeriodoConteos
                .FirstOrDefaultAsync(p => p.PkidPeriodoConteo == dto.FkidPeriodoConteoAlma && p.Activo)
                ?? throw new ArgumentException("El periodo seleccionado no existe o no esta activo.");

            await EnsureEditablePeriodStatusAsync(periodo);
        }

        private async Task EnsureEditablePeriodStatusAsync(PeriodoConteo? periodo)
        {
            if (periodo == null)
                throw new ArgumentException("El conteo no tiene un periodo activo asociado.");

            var status = await _context.EstatusPeriodos
                .AsNoTracking()
                .Where(e => e.PkidEstatusPeriodo == periodo.FkidEstatusAlma)
                .Select(e => e.Nombre)
                .FirstOrDefaultAsync();

            if (!string.Equals(status, "Pendiente", StringComparison.OrdinalIgnoreCase) &&
                !string.Equals(status, "En Proceso", StringComparison.OrdinalIgnoreCase))
                throw new InvalidOperationException("Solo se pueden modificar conteos de periodos pendientes o en proceso.");
        }
    }
}
