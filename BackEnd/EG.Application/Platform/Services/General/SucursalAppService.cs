using Mapster;
using EG.Application.Interfaces.General;
using EG.Business.Services;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.General;
using EG.Domain.DTOs.Responses.General;
using EG.Infraestructure.Models;
using Microsoft.EntityFrameworkCore;

namespace EG.Application.Services.General
{
    public class SucursalAppService : ISucursalAppService
    {
        private readonly GenericService<Sucursal, SucursalDto, SucursalResponse> _service;
        private readonly EGestionContext _context;

        public SucursalAppService(
            GenericService<Sucursal, SucursalDto, SucursalResponse> service,
            EGestionContext context)
        {
            _service = service;
            _context = context;
            ConfigureService();
            ConfigureValidations();
        }

        private void ConfigureService()
        {
            _service.AddInclude(s => s.FkidEmpresaSisNavigation);
            _service.AddInclude(s => s.FkidEstadoSisNavigation);
            _service.AddRelationFilter("Empresa", new List<string> { "Nombre", "Rfc" });
            _service.AddRelationFilter("Estado", new List<string> { "Nombre" });
        }

        private void ConfigureValidations()
        {
            _service.AddValidationRule("UniqueSucursalCodePerCompany", async (dto) =>
            {
                var sucursalDto = dto as SucursalDto;
                if (sucursalDto == null) return true;
                var exists = _service.GetQueryWithIncludes()
                    .Any(s => s.FkidEmpresaSis == sucursalDto.FkidEmpresaSis &&
                             s.CodigoSucursal.ToLower() == sucursalDto.CodigoSucursal.ToLower() &&
                             s.Activo);
                return !exists;
            });

            _service.AddValidationRuleWithId("UniqueSucursalCodePerCompanyUpdate", async (dto, id) =>
            {
                var sucursalDto = dto as SucursalDto;
                if (sucursalDto == null || !id.HasValue) return true;
                var exists = _service.GetQueryWithIncludes()
                    .Any(s => s.FkidEmpresaSis == sucursalDto.FkidEmpresaSis &&
                             s.CodigoSucursal.ToLower() == sucursalDto.CodigoSucursal.ToLower() &&
                             s.PkidSucursal != id.Value &&
                             s.Activo);
                return !exists;
            });

            _service.AddValidationRule("ValidNameLength", async (dto) =>
            {
                var sucursalDto = dto as SucursalDto;
                return !string.IsNullOrWhiteSpace(sucursalDto?.Nombre) && sucursalDto.Nombre.Length >= 3;
            });
        }

        public async Task<PagedResult<SucursalResponse>> GetAllAsync()
        {
            var result = await _service.GetAllAsync();
            return new PagedResult<SucursalResponse>
            {
                Success = true,
                Message = "Sucursales obtenidas correctamente",
                Code = "SUCCESS",
                Items = result.ToList(),
                TotalCount = result.Count()
            };
        }

        public async Task<SucursalResponse> GetByIdAsync(int id)
        {
            return await _service.GetByIdAsync(id, idPropertyName: "PkidSucursal");
        }

        public async Task<PagedResult<SucursalResponse>> GetAllPaginadoAsync(PagedRequest pageRequest)
        {
            var result = await _service.GetAllPaginadoAsync(pageRequest);
            return new PagedResult<SucursalResponse>
            {
                Success = true,
                Message = "Sucursales obtenidas correctamente",
                Code = "SUCCESS",
                Items = result.Items,
                TotalCount = result.TotalCount
            };
        }

        public async Task<SucursalResponse> CreateAsync(SucursalDto dto, int usuarioActual)
        {
            dto.FkidTipoSucursal = await ResolveTipoSucursalAsync(dto.FkidTipoSucursal);
            dto.UsuarioCreacion = usuarioActual;
            dto.FechaCreacion = DateTime.Now;
            dto.Activo = true;
            await _service.AddAsync(dto);
            return await _service.GetByIdAsync(dto.PkidSucursal, idPropertyName: "PkidSucursal");
        }

        public async Task<SucursalResponse> UpdateAsync(int id, SucursalDto dto, int usuarioActual)
        {
            dto.FkidTipoSucursal = await ResolveTipoSucursalAsync(dto.FkidTipoSucursal);
            dto.PkidSucursal = id;
            dto.UsuarioModificacion = usuarioActual;
            dto.FechaModificacion = DateTime.Now;
            await _service.UpdateAsync(id, dto);
            return await _service.GetByIdAsync(id, idPropertyName: "PkidSucursal");
        }

        public async Task<bool> DeleteAsync(int id)
        {
            var sucursal = await _service.GetByIdAsync(id, idPropertyName: "PkidSucursal");
            if (sucursal != null && sucursal.EsMatriz)
                throw new InvalidOperationException("No se puede eliminar la sucursal matriz");
            await _service.DeleteAsync(id);
            return true;
        }

        private async Task<int> ResolveTipoSucursalAsync(int tipoSucursalId)
        {
            if (tipoSucursalId > 0 &&
                await _context.CatTipoSucursals.AnyAsync(x => x.PkidTipoSucursal == tipoSucursalId && x.Activo))
            {
                return tipoSucursalId;
            }

            var defaultId = await _context.CatTipoSucursals
                .Where(x => x.Activo)
                .OrderBy(x => x.PkidTipoSucursal)
                .Select(x => x.PkidTipoSucursal)
                .FirstOrDefaultAsync();

            if (defaultId <= 0)
            {
                throw new InvalidOperationException("No hay tipos de sucursal activos configurados.");
            }

            return defaultId;
        }
    }
}
