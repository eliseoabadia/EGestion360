using AutoMapper;
using EG.Application.Interfaces.ConteoCiclico;
using EG.Business.Services;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.ConteoCiclico;
using EG.Domain.DTOs.Responses.ConteoCiclico;
using EG.Infraestructure.Models;
using Microsoft.EntityFrameworkCore;

namespace EG.Application.Services.ConteoCiclico
{
    public class BienAppService : IBienAppService
    {
        private readonly GenericService<Bien, BienDto, BienResponse> _service;
        private readonly GenericService<VwBien, BienDto, BienResponse> _serviceView;
        private readonly IMapper _mapper;

        public BienAppService(
            GenericService<Bien, BienDto, BienResponse> service,
            GenericService<VwBien, BienDto, BienResponse> serviceView,
            IMapper mapper)
        {
            _service = service;
            _serviceView = serviceView;
            _mapper = mapper;
            ConfigureService();
        }

        private void ConfigureService()
        {
            _service.AddInclude(b => b.FkidTipoBienAlmaNavigation);
            _service.AddInclude(b => b.FkidAreaSisNavigation);
            _service.AddInclude(b => b.FkidProveedorSisNavigation);
            _service.AddInclude(b => b.FkidEstadoBienAlmaNavigation);
            _service.AddInclude(b => b.FkidTipoPatrimonioAlmaNavigation);
            _service.AddInclude(b => b.FkidMarcaAlmaNavigation);
            _service.AddInclude(b => b.FkidMaterialAlmaNavigation);
            _service.AddInclude(b => b.FkidTipoAdqAlmaNavigation);
            _service.AddInclude(b => b.FkidPartidaContaNavigation);
            _service.AddInclude(b => b.FkidGrupoBienAlmaNavigation);

            _service.AddRelationFilter("TipoBien", new List<string> { "CodigoClave", "Descripcion" });
            _service.AddRelationFilter("Area", new List<string> { "Nombre", "Clave" });
            _service.AddRelationFilter("Proveedor", new List<string> { "Nombre", "RFC" });
            _service.AddRelationFilter("EstadoBien", new List<string> { "DescripcionGeneral", "DescripcionEspecifica" });
            _service.AddRelationFilter("TipoPatrimonio", new List<string> { "Descripcion" });
            _service.AddRelationFilter("Marca", new List<string> { "Descripcion" });
            _service.AddRelationFilter("Material", new List<string> { "Descripcion" });
            _service.AddRelationFilter("TipoAdquisicion", new List<string> { "Clave", "Descripcion" });
            _service.AddRelationFilter("Partida", new List<string> { "Clave", "Descripcion" });
            _service.AddRelationFilter("GrupoBien", new List<string> { "Clave", "Descripcion" });
        }

        public async Task<PagedResult<BienResponse>> GetAllAsync()
        {
            try
            {
                var result = await _serviceView.GetAllAsync();
                return new PagedResult<BienResponse>
                {
                    Success = true,
                    Message = "Listado de bienes obtenido correctamente",
                    Code = "SUCCESS",
                    Items = result.ToList(),
                    TotalCount = result.Count()
                };
            }
            catch (Exception ex)
            {
                return new PagedResult<BienResponse>
                {
                    Success = false,
                    Message = ex.Message,
                    Code = "ERROR",
                    TotalCount = 0
                };
            }
        }

        public async Task<BienResponse> GetByIdAsync(int id)
        {
            try
            {
                return await _serviceView.GetByIdAsync(id);
            }
            catch
            {
                return null;
            }
        }

        public async Task<PagedResult<BienResponse>> GetAllPaginadoAsync(PagedRequest pageRequest)
        {
            try
            {
                return await _serviceView.GetAllPaginadoAsync(pageRequest);
            }
            catch (Exception ex)
            {
                return new PagedResult<BienResponse>
                {
                    Success = false,
                    Message = ex.Message,
                    Code = "ERROR",
                    TotalCount = 0
                };
            }
        }

        public async Task<PagedResult<BienResponse>> GetByPeriodoIdAsync(int periodoId)
        {
            return await GetAllPaginadoAsync(new PagedRequest { Page = 1, PageSize = 1000 });
        }

        public async Task<PagedResult<BienResponse>> GetBySucursalIdAsync(int sucursalId)
        {
            return await GetAllPaginadoAsync(new PagedRequest { Page = 1, PageSize = 1000 });
        }

        public async Task<PagedResult<BienResponse>> GetByAreaIdAsync(int areaId)
        {
            return await GetAllPaginadoAsync(new PagedRequest { Page = 1, PageSize = 1000 });
        }

        public async Task<PagedResult<BienResponse>> GetActivosAsync()
        {
            try
            {
                var query = await _serviceView.GetAllAsync();
                var activos = query.Where(b => b.Activo).ToList();
                return new PagedResult<BienResponse>
                {
                    Success = true,
                    Message = "Listado de bienes activos obtenido correctamente",
                    Code = "SUCCESS",
                    Items = activos,
                    TotalCount = activos.Count
                };
            }
            catch (Exception ex)
            {
                return new PagedResult<BienResponse>
                {
                    Success = false,
                    Message = ex.Message,
                    Code = "ERROR",
                    TotalCount = 0
                };
            }
        }

        public async Task<BienResponse> CreateAsync(BienDto dto, int usuarioActual)
        {
            if (dto == null)
                throw new ArgumentNullException(nameof(dto), "Los datos del bien son requeridos");

            dto.FechaCreacion = DateTime.Now;
            dto.UsuarioCreacion = usuarioActual;
            dto.Activo = true;

            await _service.AddAsync(dto);
            return await GetByIdAsync(dto.PkidBien);
        }

        public async Task<BienResponse> UpdateAsync(int id, BienDto dto, int usuarioActual)
        {
            if (id <= 0)
                throw new ArgumentException("ID de bien inválido", nameof(id));

            var bien = await _service.GetByIdAsync(id, idPropertyName: "PkidBien");
            if (bien == null)
                throw new InvalidOperationException("Bien no encontrado");

            var bienDto = _mapper.Map<BienDto>(bien);
            bienDto.FechaModificacion = DateTime.Now;
            bienDto.UsuarioModificacion = usuarioActual;

            await _service.UpdateAsync(id, bienDto);
            return await GetByIdAsync(id);
        }

        public async Task<bool> DeleteAsync(int id, int usuarioActual)
        {
            if (id <= 0)
                throw new ArgumentException("ID de bien inválido", nameof(id));

            var bien = await _service.GetByIdAsync(id, idPropertyName: "PkidBien");
            if (bien == null)
                throw new InvalidOperationException("Bien no encontrado");

            var bienDto = _mapper.Map<BienDto>(bien);
            bienDto.Activo = false;
            bienDto.FechaModificacion = DateTime.Now;
            bienDto.UsuarioModificacion = usuarioActual;

            await _service.UpdateAsync(id, bienDto);
            return true;
        }
    }
}
