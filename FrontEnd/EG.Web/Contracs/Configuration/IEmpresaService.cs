using EG.Web.Models.Configuration;
using SortDirection = MudBlazor.SortDirection;

namespace EG.Web.Contracs.Configuration
{
    /// <summary>
    /// Servicio para la gestión de empresas
    /// </summary>
    public interface IEmpresaService
    {
        /// <summary>
        /// Obtiene todas las empresas
        /// </summary>
        /// <returns>Lista de empresas</returns>
        Task<IList<EmpresaResponse>> GetAllEmpresas();

        /// <summary>
        /// Obtiene una empresa por su ID
        /// </summary>
        /// <param name="empresaId">ID de la empresa</param>
        /// <returns>Empresa encontrada o nueva instancia</returns>
        Task<EmpresaResponse> GetEmpresaByIdAsync(int empresaId);

        /// <summary>
        /// Obtiene empresas paginadas con filtros
        /// </summary>
        /// <param name="page">Número de página</param>
        /// <param name="pageSize">Tamaño de página</param>
        /// <param name="filtro">Texto de búsqueda</param>
        /// <param name="sortLabel">Campo de ordenamiento</param>
        /// <param name="sortDirection">Dirección del ordenamiento</param>
        /// <param name="estado">Filtro por estado (Activo/Inactivo)</param>
        /// <returns>Lista paginada de empresas y total de registros</returns>
        Task<(List<EmpresaResponse> Empresas, int TotalCount)> GetAllEmpresasPaginadoAsync(
            int page = 1,
            int pageSize = 10,
            string filtro = "",
            string sortLabel = "",
            SortDirection sortDirection = SortDirection.Ascending,
            string? estado = null);

        /// <summary>
        /// Crea una nueva empresa
        /// </summary>
        /// <param name="empresa">Datos de la empresa</param>
        /// <returns>Resultado de la operación y mensaje</returns>
        Task<(bool resultado, string mensaje)> CreateEmpresaAsync(EmpresaResponse empresa);

        /// <summary>
        /// Actualiza una empresa existente
        /// </summary>
        /// <param name="empresa">Datos actualizados de la empresa</param>
        /// <returns>Resultado de la operación y mensaje</returns>
        Task<(bool resultado, string mensaje)> UpdateEmpresaAsync(EmpresaResponse empresa);

        /// <summary>
        /// Elimina una empresa por su ID
        /// </summary>
        /// <param name="empresaId">ID de la empresa a eliminar</param>
        /// <returns>Resultado de la operación y mensaje</returns>
        Task<(bool resultado, string mensaje)> DeleteEmpresaAsync(int empresaId);
    }
}