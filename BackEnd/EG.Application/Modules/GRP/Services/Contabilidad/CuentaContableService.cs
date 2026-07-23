using Mapster;
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
        private readonly EGestionContext _context;

        public CuentaContableService(
            GenericService<CuentaContable, CuentaContableDto, CuentaContableResponse> service,
            EGestionContext context)
        {
            _service = service;
            _context = context;
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
            var dto = response.Adapt<CuentaContableDto>();
            dto.UsuarioCreacion = usuarioId;
            dto.FechaCreacion = DateTime.Now;
            dto.Activo = true;
            await NormalizeAsync(dto);

            if (!await _service.CanAddAsync(dto))
                throw new InvalidOperationException("Ya existe una cuenta contable con esa cuenta");

            await _service.AddAsync(dto);
            return await _service.GetByIdAsync(dto.PkidCuentaContable);
        }

        public async Task<CuentaContableResponse?> UpdateAsync(int id, CuentaContableResponse response, int usuarioId)
        {
            var existing = await _service.GetByIdAsync(id);
            if (existing == null)
                throw new KeyNotFoundException($"Cuenta contable con ID {id} no encontrada");

            var dto = response.Adapt<CuentaContableDto>();
            dto.PkidCuentaContable = id;
            dto.UsuarioModificacion = usuarioId;
            dto.FechaModificacion = DateTime.Now;
            await NormalizeAsync(dto);

            // Bases heredadas pueden contener cuentas duplicadas. No se debe bloquear la
            // edicion de la descripcion cuando el valor de Cuenta permanece sin cambios.
            var cuentaCambio = !string.Equals(existing.Cuenta?.Trim(), dto.Cuenta, StringComparison.OrdinalIgnoreCase);
            if (cuentaCambio && !await _service.CanUpdateAsync(id, dto))
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

        private async Task NormalizeAsync(CuentaContableDto dto)
        {
            dto.Cuenta = FitSegment(dto.Cuenta);
            dto.Descripcion = (dto.Descripcion ?? string.Empty).Trim();
            dto.SubCuenta = FitSegment(FirstFilled(dto.SubCuenta, GetCuentaPart(dto.Cuenta, 1)));
            dto.SubSubCuenta = FitSegment(FirstFilled(dto.SubSubCuenta, GetCuentaPart(dto.Cuenta, 2)));
            dto.SubSubSubCuenta = FitSegment(FirstFilled(dto.SubSubSubCuenta, GetCuentaPart(dto.Cuenta, 3)));
            dto.SubSubSubSubCuenta = FitSegment(dto.SubSubSubSubCuenta);
            dto.S5 = FitSegment(dto.S5);
            dto.S6 = FitSegment(dto.S6);
            dto.S7 = FitSegment(dto.S7);
            dto.S8 = FitSegment(dto.S8);
            dto.S9 = FitSegment(dto.S9);
            dto.S10 = FitSegment(dto.S10);
            dto.ClaveOrd = string.IsNullOrWhiteSpace(dto.ClaveOrd) ? dto.Cuenta : dto.ClaveOrd.Trim();
            dto.Padre = FitLength(dto.Padre, 10);
            dto.Hijo = FitLength(dto.Hijo, 20);
            dto.CtaCoi = FitLength(dto.CtaCoi, 20);
            dto.DescCoi = FitLength(dto.DescCoi, 160);
            dto.TipoCuenta = string.IsNullOrWhiteSpace(dto.TipoCuenta) ? "D" : dto.TipoCuenta.Trim()[0].ToString();
            dto.NivelCuenta ??= CountFilledSegments(dto);

            if (dto.FkidTipoCuentaConta <= 0)
            {
                dto.FkidTipoCuentaConta = await GetDefaultTipoCuentaIdAsync();
            }
        }

        private async Task<int> GetDefaultTipoCuentaIdAsync()
        {
            var tipoCuentaId = await _context.TipoCuenta
                .Where(t => t.Activo)
                .OrderBy(t => t.PkidTipoCuenta)
                .Select(t => t.PkidTipoCuenta)
                .FirstOrDefaultAsync();

            if (tipoCuentaId <= 0)
            {
                throw new InvalidOperationException("No hay tipos de cuenta activos para crear la cuenta contable.");
            }

            return tipoCuentaId;
        }

        private static string GetCuentaPart(string cuenta, int index)
        {
            var parts = (cuenta ?? string.Empty)
                .Split(new[] { '.', '-', ' ' }, StringSplitOptions.RemoveEmptyEntries | StringSplitOptions.TrimEntries);

            return parts.Length > index ? parts[index] : string.Empty;
        }

        private static string FirstFilled(string? current, string fallback) =>
            string.IsNullOrWhiteSpace(current) ? fallback : current;

        private static string FitSegment(string? value) => FitLength(value, 5);

        private static string FitLength(string? value, int maxLength)
        {
            var trimmed = (value ?? string.Empty).Trim();
            return trimmed.Length <= maxLength ? trimmed : trimmed[..maxLength];
        }

        private static int CountFilledSegments(CuentaContableDto dto)
        {
            var segments = new[]
            {
                dto.Cuenta,
                dto.SubCuenta,
                dto.SubSubCuenta,
                dto.SubSubSubCuenta,
                dto.SubSubSubSubCuenta,
                dto.S5,
                dto.S6,
                dto.S7,
                dto.S8,
                dto.S9,
                dto.S10
            };

            return Math.Max(1, segments.Count(s => !string.IsNullOrWhiteSpace(s)));
        }
    }
}
