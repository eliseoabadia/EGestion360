

using EG.Web.Models.Configuration;
using MudBlazor;

namespace EG.Web.Contracs.Configuration
{
    public interface IEmpresaService
    {
        //Task<List<EmpresaResponse>> GetEmpresa(int id);
        //Task<List<EmpresaResponse>> GetAllEmpresa();
        /// <summary>
        /// Obtiene todos los Empresas
        /// </summary>
        /// <returns>Lista de Empresas</returns>
        Task<IList<EmpresaResponse>> GetAllEmpresas();

        /// <summary>
        /// Obtiene Empresas paginados con filtros y ordenamiento
        /// </summary>
        /// <param name="page">Número de página (base 1)</param>
        /// <param name="pageSize">Tamaño de página</param>
        /// <param name="filtro">Texto para filtrar</param>
        /// <param name="sortLabel">Campo para ordenar</param>
        /// <param name="sortDirection">Dirección del ordenamiento</param>
        /// <returns>Tupla con lista de Empresas y total de registros</returns>
        Task<(List<EmpresaResponse> Empresas, int TotalCount)> GetAllEmpresasPaginadoAsync(
            int page = 1,
            int pageSize = 10,
            string filtro = "",
            string sortLabel = "",
            SortDirection sortDirection = SortDirection.Ascending);

        /// <summary>
        /// Obtiene un Empresa por su ID
        /// </summary>
        /// <param name="EmpresaId">ID del Empresa</param>
        /// <returns>Empresa encontrado</returns>
        Task<EmpresaResponse> GetEmpresaByIdAsync(int EmpresaId);

        /// <summary>
        /// Crea un nuevo Empresa
        /// </summary>
        /// <param name="Empresa">Datos del Empresa a crear</param>
        /// <returns>Tupla con resultado y mensaje</returns>
        Task<(bool resultado, string mensaje)> CreateEmpresaAsync(EmpresaResponse Empresa);

        /// <summary>
        /// Actualiza un Empresa existente
        /// </summary>
        /// <param name="Empresa">Datos del Empresa a actualizar</param>
        /// <returns>Tupla con resultado y mensaje</returns>
        Task<(bool resultado, string mensaje)> UpdateEmpresaAsync(EmpresaResponse Empresa);

        /// <summary>
        /// Elimina un Empresa
        /// </summary>
        /// <param name="EmpresaId">ID del Empresa a eliminar</param>
        /// <returns>Tupla con resultado y mensaje</returns>
        Task<(bool resultado, string mensaje)> DeleteEmpresaAsync(int EmpresaId);


    }
}
