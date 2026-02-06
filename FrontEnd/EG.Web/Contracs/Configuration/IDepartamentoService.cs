using EG.Web.Models.Configuration;
using SortDirection = MudBlazor.SortDirection;

namespace EG.Web.Contracs.Configuration
{
    public interface IDepartamentoService
    {
        /// <summary>
        /// Obtiene todos los departamentos
        /// </summary>
        /// <returns>Lista de departamentos</returns>
        Task<IList<DepartamentoResponse>> GetAllDepartamentos();

        /// <summary>
        /// Obtiene departamentos paginados con filtros y ordenamiento
        /// </summary>
        /// <param name="page">Número de página (base 1)</param>
        /// <param name="pageSize">Tamaño de página</param>
        /// <param name="filtro">Texto para filtrar</param>
        /// <param name="sortLabel">Campo para ordenar</param>
        /// <param name="sortDirection">Dirección del ordenamiento</param>
        /// <returns>Tupla con lista de departamentos y total de registros</returns>
        Task<(List<DepartamentoResponse> Departamentos, int TotalCount)> GetAllDepartamentosPaginadoAsync(
            int page = 1,
            int pageSize = 10,
            string filtro = "",
            string sortLabel = "",
            SortDirection sortDirection = SortDirection.Ascending);

        /// <summary>
        /// Obtiene un departamento por su ID
        /// </summary>
        /// <param name="departamentoId">ID del departamento</param>
        /// <returns>Departamento encontrado</returns>
        Task<DepartamentoResponse> GetDepartamentoByIdAsync(int departamentoId);

        /// <summary>
        /// Crea un nuevo departamento
        /// </summary>
        /// <param name="departamento">Datos del departamento a crear</param>
        /// <returns>Tupla con resultado y mensaje</returns>
        Task<(bool resultado, string mensaje)> CreateDepartamentoAsync(DepartamentoResponse departamento);

        /// <summary>
        /// Actualiza un departamento existente
        /// </summary>
        /// <param name="departamento">Datos del departamento a actualizar</param>
        /// <returns>Tupla con resultado y mensaje</returns>
        Task<(bool resultado, string mensaje)> UpdateDepartamentoAsync(DepartamentoResponse departamento);

        /// <summary>
        /// Elimina un departamento
        /// </summary>
        /// <param name="departamentoId">ID del departamento a eliminar</param>
        /// <returns>Tupla con resultado y mensaje</returns>
        Task<(bool resultado, string mensaje)> DeleteDepartamentoAsync(int departamentoId);

        /// <summary>
        /// Obtiene solo los departamentos activos
        /// </summary>
        /// <returns>Lista de departamentos activos</returns>
        Task<IList<DepartamentoResponse>> GetDepartamentosActivos();

        /// <summary>
        /// Obtiene departamentos filtrados por empresa
        /// </summary>
        /// <param name="empresaId">ID de la empresa</param>
        /// <returns>Lista de departamentos de la empresa</returns>
        Task<IList<DepartamentoResponse>> GetDepartamentosPorEmpresaAsync(int empresaId);

        /// <summary>
        /// Cambia el estado activo/inactivo de un departamento
        /// </summary>
        /// <param name="departamentoId">ID del departamento</param>
        /// <returns>True si la operación fue exitosa</returns>
        Task<bool> ToggleEstadoDepartamentoAsync(int departamentoId);
    }
}
