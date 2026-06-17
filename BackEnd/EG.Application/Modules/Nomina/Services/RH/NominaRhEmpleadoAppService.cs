using System.Data;
using System.Text.Json;
using EG.Application.Interfaces.Nomina;
using EG.Common;
using EG.Common.Enums;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Responses.Nomina;
using EG.Infraestructure.Models;
using Microsoft.Data.SqlClient;
using Microsoft.EntityFrameworkCore;

namespace EG.Application.Services.Nomina
{
    public class NominaRhEmpleadoAppService(EGestionContext context) : INominaRhEmpleadoAppService
    {
        private readonly EGestionContext _context = context;
        private readonly Logger.Log4NetLogger _logger = new(typeof(NominaRhEmpleadoAppService));

        public Task<PagedResult<NominaRhEmpleadoResponse>> GetAllAsync(int? empresaId)
            => GetAllPaginadoAsync(new PagedRequest
            {
                Page = 1,
                PageSize = 500,
                SortLabel = "NombreCompleto",
                SortDirection = "Ascending"
            }, empresaId);

        public async Task<PagedResult<NominaRhEmpleadoResponse>> GetByIdAsync(int id)
        {
            try
            {
                await using var command = CreateCommand("[NOM].[spRhEmpleado_GetById]");
                command.Parameters.Add(Param("@Id", SqlDbType.Int, id));

                if (command.Connection?.State != ConnectionState.Open)
                {
                    await _context.Database.OpenConnectionAsync();
                }

                await using var reader = await command.ExecuteReaderAsync();
                if (!await reader.ReadAsync())
                {
                    return Failure<NominaRhEmpleadoResponse>($"Empleado con ID {id} no encontrado", "NOT_FOUND");
                }

                var item = MapEmpleado(reader);
                return Success("Empleado encontrado", [item], item, 1);
            }
            catch (Exception ex)
            {
                LogException("obtener empleado RH", ex);
                return Failure<NominaRhEmpleadoResponse>(UserFacingMessages.OperationFailed("obtener empleado"));
            }
        }

        public Task<PagedResult<NominaRhEmpleadoResponse>> CreateAsync(
            NominaRhEmpleadoResponse response,
            int usuarioActual,
            int? empresaId)
            => SaveAsync(null, response, usuarioActual, empresaId);

        public Task<PagedResult<NominaRhEmpleadoResponse>> UpdateAsync(
            int id,
            NominaRhEmpleadoResponse response,
            int usuarioActual,
            int? empresaId)
            => SaveAsync(id, response, usuarioActual, empresaId);

        public async Task<PagedResult<bool>> DeleteAsync(int id, int usuarioActual)
        {
            try
            {
                await using var command = CreateCommand("[NOM].[spRhEmpleado_Delete]");
                command.Parameters.Add(Param("@Id", SqlDbType.Int, id));
                command.Parameters.Add(Param("@UsuarioActual", SqlDbType.Int, usuarioActual));

                if (command.Connection?.State != ConnectionState.Open)
                {
                    await _context.Database.OpenConnectionAsync();
                }

                var result = await command.ExecuteScalarAsync();
                var deleted = result != DBNull.Value && Convert.ToBoolean(result);

                return new PagedResult<bool>
                {
                    Success = deleted,
                    Code = deleted ? "SUCCESS" : "NOT_FOUND",
                    Message = deleted ? "Empleado eliminado correctamente" : $"Empleado con ID {id} no encontrado",
                    Data = deleted,
                    Items = new List<bool> { deleted },
                    TotalCount = deleted ? 1 : 0
                };
            }
            catch (Exception ex)
            {
                LogException("eliminar empleado RH", ex);
                return new PagedResult<bool>
                {
                    Success = false,
                    Code = "ERROR",
                    Message = UserFacingMessages.OperationFailed("eliminar empleado"),
                    TotalCount = 0
                };
            }
        }

        public async Task<PagedResult<NominaRhEmpleadoResponse>> GetAllPaginadoAsync(PagedRequest request, int? empresaId)
        {
            request ??= new PagedRequest();

            try
            {
                var page = request.Page <= 0 ? 1 : request.Page;
                var pageSize = request.PageSize <= 0 ? 10 : request.PageSize;
                var filtro = request.Filtro ?? request.SearchString ?? string.Empty;
                var sortLabel = string.IsNullOrWhiteSpace(request.SortLabel) ? "NombreCompleto" : request.SortLabel;
                var sortDirection = string.IsNullOrWhiteSpace(request.SortDirection) ? "Ascending" : request.SortDirection;
                var requestEmpresaId = ReadIntFilter(request, "EmpresaId") ?? empresaId;

                await using var command = CreateCommand("[NOM].[spRhEmpleado_List]");
                command.Parameters.Add(Param("@EmpresaId", SqlDbType.Int, requestEmpresaId));
                command.Parameters.Add(Param("@Page", SqlDbType.Int, page));
                command.Parameters.Add(Param("@PageSize", SqlDbType.Int, pageSize));
                command.Parameters.Add(Param("@Filtro", SqlDbType.NVarChar, filtro, 250));
                command.Parameters.Add(Param("@SortLabel", SqlDbType.NVarChar, sortLabel, 80));
                command.Parameters.Add(Param("@SortDirection", SqlDbType.NVarChar, sortDirection, 20));

                if (command.Connection?.State != ConnectionState.Open)
                {
                    await _context.Database.OpenConnectionAsync();
                }

                var items = new List<NominaRhEmpleadoResponse>();
                var totalCount = 0;

                await using var reader = await command.ExecuteReaderAsync();
                while (await reader.ReadAsync())
                {
                    var item = MapEmpleado(reader);
                    totalCount = item.TotalCount;
                    items.Add(item);
                }

                return Success("Empleados obtenidos correctamente", items, items.FirstOrDefault(), totalCount);
            }
            catch (Exception ex)
            {
                LogException("obtener empleados RH", ex);
                return Failure<NominaRhEmpleadoResponse>(UserFacingMessages.OperationFailed("obtener empleados"));
            }
        }

        private async Task<PagedResult<NominaRhEmpleadoResponse>> SaveAsync(
            int? id,
            NominaRhEmpleadoResponse response,
            int usuarioActual,
            int? empresaId)
        {
            response ??= new NominaRhEmpleadoResponse();

            try
            {
                var effectiveEmpresaId = response.EmpresaId ?? empresaId;
                await using var command = CreateCommand("[NOM].[spRhEmpleado_Save]");
                var idParameter = new SqlParameter("@Id", SqlDbType.Int)
                {
                    Direction = ParameterDirection.InputOutput,
                    Value = id.HasValue && id.Value > 0 ? id.Value : DBNull.Value
                };

                command.Parameters.Add(idParameter);
                command.Parameters.Add(Param("@EmpresaId", SqlDbType.Int, effectiveEmpresaId));
                command.Parameters.Add(Param("@Empleado", SqlDbType.NVarChar, response.Empleado, 30));
                command.Parameters.Add(Param("@Iniciales", SqlDbType.NVarChar, response.Iniciales, 6));
                command.Parameters.Add(Param("@Nombre", SqlDbType.NVarChar, response.Nombre, 100));
                command.Parameters.Add(Param("@Paterno", SqlDbType.NVarChar, response.Paterno, 100));
                command.Parameters.Add(Param("@Materno", SqlDbType.NVarChar, response.Materno, 100));
                command.Parameters.Add(Param("@Rfc", SqlDbType.NVarChar, response.Rfc, 30));
                command.Parameters.Add(Param("@Curp", SqlDbType.NVarChar, response.Curp, 36));
                command.Parameters.Add(Param("@Sexo", SqlDbType.NVarChar, response.Sexo, 20));
                command.Parameters.Add(Param("@FechaNacimiento", SqlDbType.DateTime, response.FechaNacimiento));
                command.Parameters.Add(Param("@FechaIngreso", SqlDbType.DateTime, response.FechaIngreso));
                command.Parameters.Add(Param("@FechaFin", SqlDbType.DateTime, response.FechaFin));
                command.Parameters.Add(Param("@TipoContratacion", SqlDbType.NVarChar, response.TipoContratacion, 100));
                command.Parameters.Add(Param("@Puesto", SqlDbType.NVarChar, response.Puesto, 200));
                command.Parameters.Add(Param("@SueldoBase", SqlDbType.Decimal, response.SueldoBase, precision: 18, scale: 2));
                command.Parameters.Add(Param("@CompensacionGarantizada", SqlDbType.Decimal, response.CompensacionGarantizada, precision: 18, scale: 2));
                command.Parameters.Add(Param("@Banco", SqlDbType.NVarChar, response.Banco, 200));
                command.Parameters.Add(Param("@NumeroCuenta", SqlDbType.NVarChar, response.NumeroCuenta, 50));
                command.Parameters.Add(Param("@Clabe", SqlDbType.NVarChar, response.Clabe, 100));
                command.Parameters.Add(Param("@Email", SqlDbType.NVarChar, response.Email, 500));
                command.Parameters.Add(Param("@Telefono", SqlDbType.NVarChar, response.Telefono, 30));
                command.Parameters.Add(Param("@Celular", SqlDbType.NVarChar, response.Celular, 30));
                command.Parameters.Add(Param("@Calle", SqlDbType.NVarChar, response.Calle, 80));
                command.Parameters.Add(Param("@NumExterior", SqlDbType.NVarChar, response.NumExterior, 20));
                command.Parameters.Add(Param("@NumInterior", SqlDbType.NVarChar, response.NumInterior, 20));
                command.Parameters.Add(Param("@Colonia", SqlDbType.NVarChar, response.Colonia, 80));
                command.Parameters.Add(Param("@CP", SqlDbType.NVarChar, response.CP, 12));
                command.Parameters.Add(Param("@Municipio", SqlDbType.NVarChar, response.Municipio, 40));
                command.Parameters.Add(Param("@Estado", SqlDbType.NVarChar, response.Estado, 60));
                command.Parameters.Add(Param("@EstadoCivil", SqlDbType.NVarChar, response.EstadoCivil, 40));
                command.Parameters.Add(Param("@RegImss", SqlDbType.NVarChar, response.RegImss, 24));
                command.Parameters.Add(Param("@NoCartilla", SqlDbType.NVarChar, response.NoCartilla, 32));
                command.Parameters.Add(Param("@NoLicencia", SqlDbType.NVarChar, response.NoLicencia, 32));
                command.Parameters.Add(Param("@NoPasaporte", SqlDbType.NVarChar, response.NoPasaporte, 32));
                command.Parameters.Add(Param("@NoCredencialElector", SqlDbType.NVarChar, response.NoCredencialElector, 64));
                command.Parameters.Add(Param("@Gafete", SqlDbType.NVarChar, response.Gafete, 22));
                command.Parameters.Add(Param("@Activo", SqlDbType.Bit, response.Activo));
                command.Parameters.Add(Param("@UsuarioActual", SqlDbType.Int, usuarioActual));

                if (command.Connection?.State != ConnectionState.Open)
                {
                    await _context.Database.OpenConnectionAsync();
                }

                await using var reader = await command.ExecuteReaderAsync();
                if (!await reader.ReadAsync())
                {
                    return Failure<NominaRhEmpleadoResponse>(UserFacingMessages.OperationFailed(id.HasValue ? "actualizar empleado" : "crear empleado"));
                }

                var item = MapEmpleado(reader);
                return Success(
                    id.HasValue ? "Empleado actualizado correctamente" : "Empleado creado correctamente",
                    [item],
                    item,
                    1);
            }
            catch (Exception ex)
            {
                LogException(id.HasValue ? "actualizar empleado RH" : "crear empleado RH", ex);
                return Failure<NominaRhEmpleadoResponse>(UserFacingMessages.OperationFailed(id.HasValue ? "actualizar empleado" : "crear empleado"));
            }
        }

        private SqlCommand CreateCommand(string commandText)
        {
            var command = (SqlCommand)_context.Database.GetDbConnection().CreateCommand();
            command.CommandText = commandText;
            command.CommandType = CommandType.StoredProcedure;
            command.CommandTimeout = 120;
            return command;
        }

        private static SqlParameter Param(string name, SqlDbType type, object? value)
            => new(name, type) { Value = value ?? DBNull.Value };

        private static SqlParameter Param(string name, SqlDbType type, string? value, int size)
            => new(name, type, size) { Value = string.IsNullOrWhiteSpace(value) ? DBNull.Value : value.Trim() };

        private static SqlParameter Param(string name, SqlDbType type, decimal? value, byte precision, byte scale)
        {
            var parameter = new SqlParameter(name, type)
            {
                Precision = precision,
                Scale = scale,
                Value = value.HasValue ? value.Value : DBNull.Value
            };
            return parameter;
        }

        internal static int? ReadIntFilter(PagedRequest request, string key)
        {
            if (request.AdditionalFilters == null ||
                !request.AdditionalFilters.TryGetValue(key, out var value) ||
                value == null)
            {
                return null;
            }

            return value switch
            {
                int number => number,
                long number => Convert.ToInt32(number),
                JsonElement json when json.ValueKind == JsonValueKind.Number && json.TryGetInt32(out var parsed) => parsed,
                JsonElement json when json.ValueKind == JsonValueKind.String && int.TryParse(json.GetString(), out var parsed) => parsed,
                string text when int.TryParse(text, out var parsed) => parsed,
                _ => null
            };
        }

        private static PagedResult<T> Failure<T>(string message, string code = "ERROR") => new()
        {
            Success = false,
            Code = code,
            Message = message,
            TotalCount = 0
        };

        private static PagedResult<NominaRhEmpleadoResponse> Success(
            string message,
            IList<NominaRhEmpleadoResponse> items,
            NominaRhEmpleadoResponse? data,
            int totalCount)
            => new()
            {
                Success = true,
                Code = "SUCCESS",
                Message = message,
                Data = data,
                Items = items,
                TotalCount = totalCount
            };

        private void LogException(string operation, Exception ex)
        {
            _logger.LogMessage(
                LogLevelGRP.Error,
                $"Error al {operation}: {ex}",
                (byte)SystemLogTypes.Error,
                nameof(NominaRhEmpleadoAppService),
                string.Empty,
                string.Empty);
        }

        internal static NominaRhEmpleadoResponse MapEmpleado(IDataRecord reader)
            => new()
            {
                Id = GetInt(reader, "Id"),
                EmpresaId = GetNullableInt(reader, "EmpresaId"),
                Empresa = GetString(reader, "Empresa"),
                Empleado = GetString(reader, "Empleado"),
                Iniciales = GetString(reader, "Iniciales"),
                Nombre = GetString(reader, "Nombre"),
                Paterno = GetString(reader, "Paterno"),
                Materno = GetString(reader, "Materno"),
                NombreCompleto = GetString(reader, "NombreCompleto"),
                Rfc = GetString(reader, "Rfc"),
                Curp = GetString(reader, "Curp"),
                Sexo = GetString(reader, "Sexo"),
                FechaNacimiento = GetNullableDateTime(reader, "FechaNacimiento"),
                FechaIngreso = GetNullableDateTime(reader, "FechaIngreso"),
                FechaFin = GetNullableDateTime(reader, "FechaFin"),
                TipoContratacion = GetString(reader, "TipoContratacion"),
                Puesto = GetString(reader, "Puesto"),
                Departamento = GetString(reader, "Departamento"),
                Contrato = GetString(reader, "Contrato"),
                SueldoMensual = GetNullableDecimal(reader, "SueldoMensual"),
                SueldoBase = GetNullableDecimal(reader, "SueldoBase"),
                CompensacionGarantizada = GetNullableDecimal(reader, "CompensacionGarantizada"),
                Banco = GetString(reader, "Banco"),
                NumeroCuenta = GetString(reader, "NumeroCuenta"),
                Clabe = GetString(reader, "Clabe"),
                Email = GetString(reader, "Email"),
                Telefono = GetString(reader, "Telefono"),
                Celular = GetString(reader, "Celular"),
                Direccion = GetString(reader, "Direccion"),
                Calle = GetString(reader, "Calle"),
                NumExterior = GetString(reader, "NumExterior"),
                NumInterior = GetString(reader, "NumInterior"),
                Colonia = GetString(reader, "Colonia"),
                CP = GetString(reader, "CP"),
                Municipio = GetString(reader, "Municipio"),
                Estado = GetString(reader, "Estado"),
                EstadoCivil = GetString(reader, "EstadoCivil"),
                RegImss = GetString(reader, "RegImss"),
                NoCartilla = GetString(reader, "NoCartilla"),
                NoLicencia = GetString(reader, "NoLicencia"),
                NoPasaporte = GetString(reader, "NoPasaporte"),
                NoCredencialElector = GetString(reader, "NoCredencialElector"),
                Gafete = GetString(reader, "Gafete"),
                TienePension = GetBool(reader, "TienePension"),
                TotalExpedientes = GetInt(reader, "TotalExpedientes"),
                TotalIncidencias = GetInt(reader, "TotalIncidencias"),
                Activo = GetBool(reader, "Activo"),
                UsuarioCreacion = GetNullableInt(reader, "UsuarioCreacion"),
                FechaCreacion = GetNullableDateTime(reader, "FechaCreacion"),
                UsuarioModificacion = GetNullableInt(reader, "UsuarioModificacion"),
                FechaModificacion = GetNullableDateTime(reader, "FechaModificacion"),
                TotalCount = GetInt(reader, "TotalCount")
            };

        internal static NominaRhEmpleadoDetalleResponse MapDetalle(IDataRecord reader)
            => new()
            {
                Seccion = GetString(reader, "Seccion"),
                Id = GetInt(reader, "Id"),
                PersonaId = GetInt(reader, "PersonaId"),
                EmpresaId = GetNullableInt(reader, "EmpresaId"),
                Clave = GetString(reader, "Clave"),
                Titulo = GetString(reader, "Titulo"),
                Descripcion = GetString(reader, "Descripcion"),
                Tipo = GetString(reader, "Tipo"),
                Estatus = GetString(reader, "Estatus"),
                Fecha = GetNullableDateTime(reader, "Fecha"),
                FechaInicio = GetNullableDateTime(reader, "FechaInicio"),
                FechaFin = GetNullableDateTime(reader, "FechaFin"),
                Importe = GetNullableDecimal(reader, "Importe"),
                Porcentaje = GetNullableDecimal(reader, "Porcentaje"),
                Documento = GetString(reader, "Documento"),
                Referencia = GetString(reader, "Referencia"),
                Observaciones = GetString(reader, "Observaciones"),
                Activo = GetBool(reader, "Activo"),
                UsuarioCreacion = GetNullableInt(reader, "UsuarioCreacion"),
                FechaCreacion = GetNullableDateTime(reader, "FechaCreacion"),
                UsuarioModificacion = GetNullableInt(reader, "UsuarioModificacion"),
                FechaModificacion = GetNullableDateTime(reader, "FechaModificacion"),
                TotalCount = GetInt(reader, "TotalCount")
            };

        private static string GetString(IDataRecord reader, string name)
            => reader[name] == DBNull.Value ? string.Empty : Convert.ToString(reader[name]) ?? string.Empty;

        private static int GetInt(IDataRecord reader, string name)
            => reader[name] == DBNull.Value ? 0 : Convert.ToInt32(reader[name]);

        private static int? GetNullableInt(IDataRecord reader, string name)
            => reader[name] == DBNull.Value ? null : Convert.ToInt32(reader[name]);

        private static bool GetBool(IDataRecord reader, string name)
            => reader[name] != DBNull.Value && Convert.ToBoolean(reader[name]);

        private static DateTime? GetNullableDateTime(IDataRecord reader, string name)
            => reader[name] == DBNull.Value ? null : Convert.ToDateTime(reader[name]);

        private static decimal? GetNullableDecimal(IDataRecord reader, string name)
            => reader[name] == DBNull.Value ? null : Convert.ToDecimal(reader[name]);
    }

    public class NominaRhEmpleadoDetalleAppService(EGestionContext context) : INominaRhEmpleadoDetalleAppService
    {
        private readonly EGestionContext _context = context;
        private readonly Logger.Log4NetLogger _logger = new(typeof(NominaRhEmpleadoDetalleAppService));

        public async Task<PagedResult<NominaRhEmpleadoDetalleResponse>> GetAllPaginadoAsync(PagedRequest request, int? empresaId)
        {
            request ??= new PagedRequest();

            try
            {
                var page = request.Page <= 0 ? 1 : request.Page;
                var pageSize = request.PageSize <= 0 ? 10 : request.PageSize;
                var filtro = request.Filtro ?? request.SearchString ?? string.Empty;
                var sortLabel = string.IsNullOrWhiteSpace(request.SortLabel) ? "Fecha" : request.SortLabel;
                var sortDirection = string.IsNullOrWhiteSpace(request.SortDirection) ? "Descending" : request.SortDirection;
                var requestEmpresaId = NominaRhEmpleadoAppService.ReadIntFilter(request, "EmpresaId") ?? empresaId;
                var personaId = NominaRhEmpleadoAppService.ReadIntFilter(request, "PersonaId");
                var seccion = ReadTextFilter(request, "Seccion");

                await using var command = (SqlCommand)_context.Database.GetDbConnection().CreateCommand();
                command.CommandText = "[NOM].[spRhEmpleadoDetalle_List]";
                command.CommandType = CommandType.StoredProcedure;
                command.CommandTimeout = 120;
                command.Parameters.Add(new SqlParameter("@Seccion", SqlDbType.NVarChar, 40) { Value = seccion });
                command.Parameters.Add(new SqlParameter("@PersonaId", SqlDbType.Int) { Value = personaId.HasValue ? personaId.Value : DBNull.Value });
                command.Parameters.Add(new SqlParameter("@EmpresaId", SqlDbType.Int) { Value = requestEmpresaId.HasValue ? requestEmpresaId.Value : DBNull.Value });
                command.Parameters.Add(new SqlParameter("@Page", SqlDbType.Int) { Value = page });
                command.Parameters.Add(new SqlParameter("@PageSize", SqlDbType.Int) { Value = pageSize });
                command.Parameters.Add(new SqlParameter("@Filtro", SqlDbType.NVarChar, 250) { Value = filtro });
                command.Parameters.Add(new SqlParameter("@SortLabel", SqlDbType.NVarChar, 80) { Value = sortLabel });
                command.Parameters.Add(new SqlParameter("@SortDirection", SqlDbType.NVarChar, 20) { Value = sortDirection });

                if (command.Connection?.State != ConnectionState.Open)
                {
                    await _context.Database.OpenConnectionAsync();
                }

                var items = new List<NominaRhEmpleadoDetalleResponse>();
                var totalCount = 0;

                await using var reader = await command.ExecuteReaderAsync();
                while (await reader.ReadAsync())
                {
                    var item = NominaRhEmpleadoAppService.MapDetalle(reader);
                    totalCount = item.TotalCount;
                    items.Add(item);
                }

                return new PagedResult<NominaRhEmpleadoDetalleResponse>
                {
                    Success = true,
                    Code = "SUCCESS",
                    Message = "Detalle de empleado obtenido correctamente",
                    Items = items,
                    TotalCount = totalCount
                };
            }
            catch (Exception ex)
            {
                _logger.LogMessage(
                    LogLevelGRP.Error,
                    $"Error al obtener detalle RH de empleado: {ex}",
                    (byte)SystemLogTypes.Error,
                    nameof(NominaRhEmpleadoDetalleAppService),
                    string.Empty,
                    string.Empty);

                return new PagedResult<NominaRhEmpleadoDetalleResponse>
                {
                    Success = false,
                    Code = "ERROR",
                    Message = UserFacingMessages.OperationFailed("obtener detalle de empleado"),
                    TotalCount = 0
                };
            }
        }

        private static string ReadTextFilter(PagedRequest request, string key)
        {
            if (request.AdditionalFilters == null ||
                !request.AdditionalFilters.TryGetValue(key, out var value) ||
                value == null)
            {
                return string.Empty;
            }

            return value switch
            {
                string text => text.Trim(),
                JsonElement json when json.ValueKind == JsonValueKind.String => (json.GetString() ?? string.Empty).Trim(),
                _ => Convert.ToString(value)?.Trim() ?? string.Empty
            };
        }
    }
}
