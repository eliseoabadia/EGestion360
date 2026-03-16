using EG.Common.Helper;
using EG.Web.Contracs.Configuration;
using EG.Web.Models;
using EG.Web.Models.ConteoCiclico;
using Microsoft.JSInterop;
using SortDirection = MudBlazor.SortDirection;

namespace EG.Web.Services.ConteoCiclico
{
    public class ArticuloConteoService : BaseService, IArticuloConteoService
    {
        public ArticuloConteoService(HttpClient httpClient, IJSRuntime jsRuntime, ApplicationInstance application)
            : base(httpClient, jsRuntime, application)
        {
        }

        // GET: api/ArticuloConteo
        public async Task<ApiResponse<List<ArticuloConteoResponse>>> GetAllAsync()
        {
            if (!IsClientSide())
                return new ApiResponse<List<ArticuloConteoResponse>>();

            var response = await GetAsync<ApiResponse<List<ArticuloConteoResponse>>>("api/ArticuloConteo/", useBaseUrl: false);
            return response ?? new ApiResponse<List<ArticuloConteoResponse>>();
        }

        // GET: api/ArticuloConteo/{id}
        public async Task<ApiResponse<ArticuloConteoResponse>> GetByIdAsync(int id)
        {
            if (!IsClientSide())
                return new ApiResponse<ArticuloConteoResponse>();

            var response = await GetAsync<ApiResponse<ArticuloConteoResponse>>($"api/ArticuloConteo/{id}", useBaseUrl: false);
            return response ?? new ApiResponse<ArticuloConteoResponse>
            {
                Success = false,
                Message = "Error al obtener el artículo",
                Code = "ERROR"
            };
        }

        // POST: api/ArticuloConteo/GetAllPaginado
        public async Task<ApiResponse<ArticuloConteoResponse>> GetAllPaginadoAsync(
            int page = 1,
            int pageSize = 10,
            string filtro = "",
            string sortLabel = "",
            SortDirection sortDirection = SortDirection.Ascending,
            int? periodoId = null,
            int? usuarioId = null,
            int? estatusId = null)
        {
            if (!IsClientSide())
                return new ApiResponse<ArticuloConteoResponse>();

            string sortDir = sortDirection == SortDirection.Descending ? "desc" : "asc";

            // Agregar filtros si existen
            var filters = new Dictionary<string, object>();

            if (periodoId.HasValue)
            {
                filters.Add("PeriodoId", new
                {
                    propertyName = "PeriodoId",
                    value = periodoId.Value.ToString(),
                    @operator = "eq"
                });
            }

            if (usuarioId.HasValue)
            {
                filters.Add("UsuarioAsignadoId", new
                {
                    propertyName = "UsuarioAsignadoId",
                    value = usuarioId.Value.ToString(),
                    @operator = "eq"
                });
            }

            if (estatusId.HasValue)
            {
                filters.Add("EstatusId", new
                {
                    propertyName = "EstatusId",
                    value = estatusId.Value.ToString(),
                    @operator = "eq"
                });
            }

            // Usar reflexión para agregar filters
            var jsonParamsWithFilters = new PagedRequest
            {

                Page= page,
                PageSize= pageSize,
                Filtro = filtro ?? "",
                SortLabel = sortLabel ?? string.Empty,
                SortDirection = sortDir,
                SearchString = string.Empty,
                AdditionalFilters = filters
            };
            //public Dictionary<string, object> AdditionalFilters { get; set; } = new Dictionary<string, object>();
            var response = await PostAsync<ApiResponse<ArticuloConteoResponse>>(
                "api/ArticuloConteo/GetAllPaginado/",
                jsonParamsWithFilters,
                useBaseUrl: false);

            return response ?? new ApiResponse<ArticuloConteoResponse>
            {
                Success = false,
                Message = "Error al obtener artículos paginados",
                Code = "ERROR",
                Data = new ArticuloConteoResponse()
            };
        }

        // POST: api/ArticuloConteo
        public async Task<ApiResponse<ArticuloConteoResponse>> CreateAsync(ArticuloConteoResponse entity)
        {
            if (!IsClientSide())
                return new ApiResponse<ArticuloConteoResponse>();

            var response = await PostAsync<ApiResponse<ArticuloConteoResponse>>(
                "api/ArticuloConteo/",
                entity,
                useBaseUrl: false);

            return response ?? new ApiResponse<ArticuloConteoResponse>
            {
                Success = false,
                Message = "Error al crear artículo",
                Code = "ERROR"
            };
        }

        // PUT: api/ArticuloConteo/{id}
        public async Task<ApiResponse<ArticuloConteoResponse>> UpdateAsync(ArticuloConteoResponse entity)
        {
            if (!IsClientSide())
                return new ApiResponse<ArticuloConteoResponse>();

            if (entity.Id <= 0)
                return new ApiResponse<ArticuloConteoResponse>
                {
                    Success = false,
                    Message = "ID de artículo no válido",
                    Code = "INVALID_ID"
                };

            var response = await PutAsync<ApiResponse<ArticuloConteoResponse>>(
                $"api/ArticuloConteo/{entity.Id}/",
                entity,
                useBaseUrl: false);

            return response ?? new ApiResponse<ArticuloConteoResponse>
            {
                Success = false,
                Message = "Error al actualizar artículo",
                Code = "ERROR"
            };
        }

        // DELETE: api/ArticuloConteo/{id}
        public async Task<ApiResponse<bool>> DeleteAsync(int id)
        {
            if (!IsClientSide())
                return new ApiResponse<bool>();

            var response = await DeleteAsync<ApiResponse<bool>>(
                $"api/ArticuloConteo/{id}/",
                useBaseUrl: false);

            return response ?? new ApiResponse<bool>
            {
                Success = false,
                Message = "Error al eliminar artículo",
                Code = "ERROR",
                Data = false
            };
        }

        // GET: api/ArticuloConteo/ByPeriodo/{periodoId}
        public async Task<ApiResponse<List<ArticuloConteoResponse>>> GetByPeriodoAsync(int periodoId)
        {
            if (!IsClientSide())
                return new ApiResponse<List<ArticuloConteoResponse>>();

            var response = await GetAsync<ApiResponse<List<ArticuloConteoResponse>>>(
                $"api/ArticuloConteo/ByPeriodo/{periodoId}",
                useBaseUrl: false);

            return response ?? new ApiResponse<List<ArticuloConteoResponse>>
            {
                Success = false,
                Message = "Error al obtener artículos por período",
                Code = "ERROR"
            };
        }

        // GET: api/ArticuloConteo/ByUsuario/{usuarioId}
        public async Task<ApiResponse<List<ArticuloConteoResponse>>> GetByUsuarioAsync(int usuarioId)
        {
            if (!IsClientSide())
                return new ApiResponse<List<ArticuloConteoResponse>>();

            var response = await GetAsync<ApiResponse<List<ArticuloConteoResponse>>>(
                $"api/ArticuloConteo/ByUsuario/{usuarioId}",
                useBaseUrl: false);

            return response ?? new ApiResponse<List<ArticuloConteoResponse>>
            {
                Success = false,
                Message = "Error al obtener artículos por usuario",
                Code = "ERROR"
            };
        }

        // POST: api/ArticuloConteo/GetAllPaginadoByPeriodo/{periodoId}
        public async Task<ApiResponse<ArticuloConteoResponse>> GetPaginadoByPeriodoAsync(
            int periodoId,
            int page = 1,
            int pageSize = 10,
            string filtro = "",
            string sortLabel = "",
            SortDirection sortDirection = SortDirection.Ascending)
        {
            if (!IsClientSide())
                return new ApiResponse<ArticuloConteoResponse>();

            string sortDir = sortDirection == SortDirection.Descending ? "desc" : "asc";

            var jsonParams = new
            {
                page,
                pageSize,
                filtro = filtro ?? "",
                sortLabel = sortLabel ?? string.Empty,
                sortDirection = sortDir
            };

            var response = await PostAsync<ApiResponse<ArticuloConteoResponse>>(
                $"api/ArticuloConteo/GetAllPaginadoByPeriodo/{periodoId}",
                jsonParams,
                useBaseUrl: false);

            return response ?? new ApiResponse<ArticuloConteoResponse>
            {
                Success = false,
                Message = "Error al obtener artículos paginados por período",
                Code = "ERROR",
                Data = new ArticuloConteoResponse()
            };
        }

        // PATCH: api/ArticuloConteo/{id}/cambiar-estatus
        public async Task<ApiResponse<bool>> CambiarEstatusAsync(int id, int estatusId)
        {
            if (!IsClientSide())
                return new ApiResponse<bool>();

            var jsonParams = new
            {
                estatusId
            };

            var response = await PatchAsync<ApiResponse<bool>>(
                $"api/ArticuloConteo/{id}/cambiar-estatus/",
                jsonParams,
                useBaseUrl: false);

            return response ?? new ApiResponse<bool>
            {
                Success = false,
                Message = "Error al cambiar estatus",
                Code = "ERROR",
                Data = false
            };
        }

        // PATCH: api/ArticuloConteo/{id}/asignar-usuario
        public async Task<ApiResponse<bool>> AsignarUsuarioAsync(int id, int usuarioId)
        {
            if (!IsClientSide())
                return new ApiResponse<bool>();

            var jsonParams = new
            {
                usuarioId
            };

            var response = await PatchAsync<ApiResponse<bool>>(
                $"api/ArticuloConteo/{id}/asignar-usuario/",
                jsonParams,
                useBaseUrl: false);

            return response ?? new ApiResponse<bool>
            {
                Success = false,
                Message = "Error al asignar usuario",
                Code = "ERROR",
                Data = false
            };
        }

        //// GET: api/ArticuloConteo/estadisticas/{periodoId}
        //public async Task<ApiResponse<EstadisticasArticulosResponse>> GetEstadisticasAsync(int periodoId)
        //{
        //    if (!IsClientSide())
        //        return new ApiResponse<EstadisticasArticulosResponse>();

        //    try
        //    {
        //        var response = await GetAsync<object>($"api/ArticuloConteo/estadisticas/{periodoId}", useBaseUrl: false);

        //        if (response != null)
        //        {
        //            // Convertir la respuesta a un diccionario para extraer los datos
        //            var jsonString = System.Text.Json.JsonSerializer.Serialize(response);
        //            var jsonDoc = System.Text.Json.JsonDocument.Parse(jsonString);

        //            if (jsonDoc.RootElement.TryGetProperty("data", out var dataElement))
        //            {
        //                var estadisticas = System.Text.Json.JsonSerializer.Deserialize<EstadisticasArticulosResponse>(
        //                    dataElement.GetRawText(),
        //                    new System.Text.Json.JsonSerializerOptions { PropertyNameCaseInsensitive = true });

        //                return new ApiResponse<EstadisticasArticulosResponse>
        //                {
        //                    Success = true,
        //                    Message = "Estadísticas obtenidas correctamente",
        //                    Code = "SUCCESS",
        //                    Data = estadisticas ?? new EstadisticasArticulosResponse()
        //                };
        //            }
        //        }

        //        return new ApiResponse<EstadisticasArticulosResponse>
        //        {
        //            Success = false,
        //            Message = "No se pudieron obtener las estadísticas",
        //            Code = "ERROR",
        //            Data = new EstadisticasArticulosResponse()
        //        };
        //    }
        //    catch (Exception ex)
        //    {
        //        return new ApiResponse<EstadisticasArticulosResponse>
        //        {
        //            Success = false,
        //            Message = $"Error al obtener estadísticas: {ex.Message}",
        //            Code = "ERROR",
        //            Data = new EstadisticasArticulosResponse()
        //        };
        //    }
        //}

        // POST: api/ArticuloConteo/Batch
        public async Task<ApiResponse<List<ArticuloConteoResponse>>> AddBatchAsync(List<ArticuloConteoResponse> articulos)
        {
            if (!IsClientSide())
                return new ApiResponse<List<ArticuloConteoResponse>>();

            if (articulos == null || !articulos.Any())
                return new ApiResponse<List<ArticuloConteoResponse>>
                {
                    Success = false,
                    Message = "La lista de artículos no puede estar vacía",
                    Code = "INVALID_DATA"
                };

            var response = await PostAsync<ApiResponse<List<ArticuloConteoResponse>>>(
                "api/ArticuloConteo/Batch/",
                articulos,
                useBaseUrl: false);

            return response ?? new ApiResponse<List<ArticuloConteoResponse>>
            {
                Success = false,
                Message = "Error al agregar artículos en lote",
                Code = "ERROR"
            };
        }

    }
}