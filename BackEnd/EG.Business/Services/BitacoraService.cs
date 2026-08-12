using EG.Business.Interfaces;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.General;
using EG.Domain.DTOs.Requests.Seguridad;
using EG.Domain.DTOs.Responses.Seguridad;
using EG.Infraestructure.Models;
using Microsoft.EntityFrameworkCore;

namespace EG.Business.Services;

public sealed class BitacoraService(
    GenericService<SystemLog, BitacoraRequest, BitacoraResponse> logs,
    GenericService<Usuario, UsuarioDto> usuarios) : IBitacoraService
{
    public async Task<PagedResult<BitacoraResponse>> ConsultarAsync(BitacoraRequest request)
    {
        var hastaExclusiva = request.Hasta <= request.Desde
            ? request.Desde.AddDays(1)
            : request.Hasta;

        var usuariosEmpresa = await usuarios.GetAllAsync();
        var claves = usuariosEmpresa
            .Select(x => x.PayrollId)
            .Where(x => !string.IsNullOrWhiteSpace(x))
            .ToHashSet(StringComparer.OrdinalIgnoreCase);

        if (claves.Count == 0)
        {
            return new PagedResult<BitacoraResponse>
            {
                Success = true,
                Message = "No hay usuarios asociados a la empresa activa.",
                Items = [],
                TotalCount = 0
            };
        }

        var pagedRequest = new PagedRequest
        {
            Page = request.Page,
            PageSize = request.PageSize,
            Filtro = request.Filtro,
            SearchString = request.SearchString,
            SortLabel = request.SortLabel,
            SortDirection = request.SortDirection
        };

        return await logs
            .DisableActivoFilter()
            .DisableEmpresaFilter()
            .AddSearchFilter(nameof(SystemLog.EmployeeNo), nameof(SystemLog.ProgName), nameof(SystemLog.Category),
                nameof(SystemLog.Level), nameof(SystemLog.Message), nameof(SystemLog.MethodName), nameof(SystemLog.Ipclient))
            .GetAllPaginadoAsync(pagedRequest, x =>
                x.Date >= request.Desde && x.Date < hastaExclusiva &&
                claves.Contains(x.EmployeeNo) &&
                (string.IsNullOrWhiteSpace(request.Usuario) || x.EmployeeNo.Contains(request.Usuario)) &&
                (string.IsNullOrWhiteSpace(request.Modulo) || x.ProgName.Contains(request.Modulo) || x.Category.Contains(request.Modulo)) &&
                (string.IsNullOrWhiteSpace(request.Nivel) || x.Level == request.Nivel) &&
                (!request.SinUsuario || string.IsNullOrWhiteSpace(x.EmployeeNo)) &&
                (string.IsNullOrWhiteSpace(request.Categoria) || x.Category == request.Categoria) &&
                (string.IsNullOrWhiteSpace(request.Referencia) || x.Message.Contains(request.Referencia) ||
                    x.Parameters.Contains(request.Referencia) || x.Context.Contains(request.Referencia)));
    }

    public async Task<PagedResult<BitacoraResponse>> ObtenerFiltrosAsync(BitacoraRequest request)
    {
        var usuariosEmpresa = (await usuarios.GetAllAsync())
            .Where(x => !string.IsNullOrWhiteSpace(x.PayrollId))
            .OrderBy(x => x.Nombre).ThenBy(x => x.ApellidoPaterno)
            .Select(x => new BitacoraResponse
            {
                TipoCatalogo = "usuario",
                Valor = x.PayrollId,
                Etiqueta = string.Join(" ", new[] { x.Nombre, x.ApellidoPaterno, x.ApellidoMaterno }.Where(v => !string.IsNullOrWhiteSpace(v))).Trim()
            })
            .ToList();

        var claves = usuariosEmpresa.Select(x => x.Valor!).ToHashSet(StringComparer.OrdinalIgnoreCase);
        var hasta = request.Hasta <= request.Desde ? request.Desde.AddDays(1) : request.Hasta;
        var query = logs.DisableActivoFilter().DisableEmpresaFilter().GetQueryWithIncludes()
            .AsNoTracking()
            .Where(x => x.Date >= request.Desde && x.Date < hasta &&
                (string.IsNullOrWhiteSpace(x.EmployeeNo) || claves.Contains(x.EmployeeNo)));

        var modulos = await query
            .Where(x => x.ProgName != null && x.ProgName != "")
            .GroupBy(x => x.ProgName)
            .Select(x => new BitacoraResponse { TipoCatalogo = "modulo", Valor = x.Key, Etiqueta = x.Key, Cantidad = x.Count() })
            .OrderByDescending(x => x.Cantidad).Take(100).ToListAsync();

        var categorias = await query
            .Where(x => x.Category != null && x.Category != "")
            .GroupBy(x => x.Category)
            .Select(x => new BitacoraResponse { TipoCatalogo = "categoria", Valor = x.Key, Etiqueta = x.Key, Cantidad = x.Count() })
            .OrderByDescending(x => x.Cantidad).Take(100).ToListAsync();

        usuariosEmpresa.AddRange(modulos);
        usuariosEmpresa.AddRange(categorias);
        return new PagedResult<BitacoraResponse> { Success = true, Items = usuariosEmpresa, TotalCount = usuariosEmpresa.Count };
    }
}
