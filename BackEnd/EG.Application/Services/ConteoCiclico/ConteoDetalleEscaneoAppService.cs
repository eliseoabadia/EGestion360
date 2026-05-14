using EG.Application.Interfaces.ConteoCiclico;
using EG.Business.Services;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.ConteoCiclico;
using EG.Domain.DTOs.Responses.ConteoCiclico;
using EG.Domain.Interfaces;
using EG.Infraestructure.Models;

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
                var all = await _serviceView.GetAllAsync();
                var filtered = all.Where(e => e.FkidConteoAlma == conteoId).ToList();

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
                var escaneo = new ConteoDetalleEscaneo
                {
                    FkidConteoAlma = request.FkidConteoAlma,
                    FkidPersonaNom = request.FkidPersonaNom,
                    FkidBienAlma = request.FkidBienAlma,
                    FkidTipoBienAlma = request.FkidTipoBienAlma,
                    CodigoBarras = request.CodigoBarras ?? "",
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
                    Message = ex.Message,
                    Code = "ERROR"
                };
            }
        }
    }
}
