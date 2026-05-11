using AutoMapper;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Logging;
using EG.Application.Interfaces.Contabilidad;
using EG.Business.Services;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.Contabilidad;
using EG.Domain.DTOs.Responses;
using EG.Domain.DTOs.Responses.Contabilidad;
using EG.Infraestructure.Models;
using Microsoft.EntityFrameworkCore;

namespace EG.ApiCoreBS.Services.Contabilidad
{
    public class CuentaContableService : ICuentaContableService
    {
        private readonly GenericService<CuentaContable, CuentaContableDto, CuentaContableResponse> _service;
        private readonly IMapper _mapper;

        public CuentaContableService(
            GenericService<CuentaContable, CuentaContableDto, CuentaContableResponse> service,
            IMapper mapper)
        {
            _service = service;
            _mapper = mapper;
            ConfigureService();
            ConfigureValidations();
        }

        private void ConfigureService()
        {
            _service.AddInclude(c => c.FkidEmpresaSisNavigation);
            _service.AddInclude(c => c.FkidTipoCuentaContaNavigation);
        }

        private void ConfigureValidations()
        {
            _service.AddValidationRule("UniqueCuentaContable", async (dto) =>
            {
                var itemDto = dto as CuentaContableDto;
                if (itemDto == null) return true;
                return !_service.GetQueryWithIncludes()
                    .Any(c => c.Cuenta.ToLower() == itemDto.Cuenta.ToLower() && c.Activo);
            });

            _service.AddValidationRuleWithId("UniqueCuentaContableUpdate", async (dto, id) =>
            {
                var itemDto = dto as CuentaContableDto;
                if (itemDto == null || !id.HasValue) return true;
                return !_service.GetQueryWithIncludes()
                    .Any(c => c.Cuenta.ToLower() == itemDto.Cuenta.ToLower() && c.PkidCuentaContable != id.Value && c.Activo);
            });
        }

        public async Task<IEnumerable<CuentaContableResponse>> GetAllAsync()
        {
            return await _service.GetAllAsync();
        }

        public async Task<CuentaContableResponse?> GetByIdAsync(int id)
        {
            return await _service.GetByIdAsync(id);
        }

        public async Task<CuentaContableResponse> CreateAsync(CuentaContableResponse response, int usuarioId)
        {
            var dto = _mapper.Map<CuentaContableDto>(response);
            dto.UsuarioCreacion = usuarioId;
            dto.FechaCreacion = DateTime.Now;
            dto.Activo = true;

            if (!await _service.CanAddAsync(dto))
                throw new InvalidOperationException("Ya existe una cuenta contable con esa cuenta");

            await _service.AddAsync(dto);
            return await _service.GetByIdAsync(dto.PkidCuentaContable);
        }

        public async Task<CuentaContableResponse?> UpdateAsync(int id, CuentaContableResponse response, int usuarioId)
        {
            var dto = _mapper.Map<CuentaContableDto>(response);
            dto.PkidCuentaContable = id;
            dto.UsuarioModificacion = usuarioId;
            dto.FechaModificacion = DateTime.Now;

            if (!await _service.CanUpdateAsync(id, dto))
                throw new InvalidOperationException("Ya existe otra cuenta contable con esa cuenta");

            await _service.UpdateAsync(id, dto);
            return await _service.GetByIdAsync(id);
        }

        public async Task DeleteAsync(int id)
        {
            var existing = await _service.GetByIdAsync(id);
            if (existing == null) throw new KeyNotFoundException($"Cuenta contable con ID {id} no encontrada");

            await _service.DeleteAsync(id);
        }

        public async Task<PagedResult<CuentaContableResponse>> GetAllPaginadoAsync(PagedRequest request)
        {
            return await _service.GetAllPaginadoAsync(request);
        }

        public async Task<List<LookupItem>> GetLookupAsync()
        {
            return await _service.GetQueryWithIncludes()
                .Where(c => c.Activo)
                .OrderBy(c => c.Cuenta)
                .Select(c => new LookupItem { Id = c.PkidCuentaContable, Text = (c.Cuenta ?? "") + " - " + (c.Descripcion ?? "") })
                .ToListAsync();
        }

        public async Task<PagedResult<LookupItem>> GetLookupPaginadoAsync(int page, int pageSize, string? filter)
        {
            var query = _service.GetQueryWithIncludes()
                .Where(c => c.Activo)
                .OrderBy(c => c.Cuenta)
                .Select(c => new LookupItem { Id = c.PkidCuentaContable, Text = (c.Cuenta ?? "") + " - " + (c.Descripcion ?? "") });

            var totalCount = await query.CountAsync();
            var items = await query
                .Skip((page - 1) * pageSize)
                .Take(pageSize)
                .ToListAsync();
            return new PagedResult<LookupItem>
            {
                Success = true,
                Message = "OK",
                Code = "SUCCESS",
                Items = items,
                TotalCount = totalCount
            };
        }
    }
}
