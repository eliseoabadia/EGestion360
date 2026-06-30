using System.Data;
using System.Data.Common;
using EG.Application.Interfaces.AccessConfiguration;
using EG.Common.Enums;
using EG.Domain.Platform.DTOs.Requests.AccessConfiguration;
using EG.Domain.Platform.DTOs.Responses.AccessConfiguration;
using EG.Infraestructure.Models;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Storage;

namespace EG.Application.Services.AccessConfiguration;

public sealed class AccessConfigurationAppService(EGestionContext context) : IAccessConfigurationAppService
{
    private readonly EGestionContext _context = context;

    public async Task<AccessConfigurationSnapshotResponse> GetSnapshotAsync()
    {
        await _context.Database.OpenConnectionAsync();
        try
        {
            var snapshot = new AccessConfigurationSnapshotResponse
            {
                Roles = await QueryAsync(GetRolesSql, MapRole),
                Users = await QueryAsync(GetUsersSql, MapUser),
                MenuRoleCount = await ScalarAsync<int>("SELECT COUNT(1) FROM SIS.MenuRole WHERE Activo = 1;")
            };

            snapshot.PermissionActions.AddRange(PermissionActionExtensions.GetAllClaimValues());
            return snapshot;
        }
        finally
        {
            await _context.Database.CloseConnectionAsync();
        }
    }

    public async Task<AccessRoleDetailResponse> GetNewRoleTemplateAsync()
    {
        await _context.Database.OpenConnectionAsync();
        try
        {
            return new AccessRoleDetailResponse
            {
                Role = new AccessRoleSummaryResponse { Name = "Nuevo rol" },
                Menus = await QueryAsync(GetMenusSql, MapMenu)
            };
        }
        finally
        {
            await _context.Database.CloseConnectionAsync();
        }
    }

    public async Task<AccessRoleDetailResponse> GetRoleDetailAsync(string roleId)
    {
        if (string.IsNullOrWhiteSpace(roleId))
        {
            throw new ArgumentException("El rol es requerido.", nameof(roleId));
        }

        await _context.Database.OpenConnectionAsync();
        try
        {
            var role = (await QueryAsync(GetRoleSql, MapRole, Param("@RoleId", roleId))).FirstOrDefault()
                ?? throw new KeyNotFoundException("Rol no encontrado.");

            var detail = new AccessRoleDetailResponse
            {
                Role = role,
                AssignedUserIds = await QueryAsync(GetRoleUsersSql, reader => GetInt(reader, "PkIdUsuario"), Param("@RoleId", roleId)),
                Menus = await QueryAsync(GetMenusSql, MapMenu),
                Claims = await QueryAsync(GetRoleClaimsSql, MapClaim, Param("@RoleId", roleId))
            };

            var values = await QueryAsync(GetRoleClaimValuesSql, reader => new
            {
                ClaimId = GetInt(reader, "ClaimId"),
                Value = GetString(reader, "Value")
            }, Param("@RoleId", roleId));

            var groupedValues = values
                .GroupBy(x => x.ClaimId)
                .ToDictionary(x => x.Key, x => x.Select(v => v.Value).Where(v => !string.IsNullOrWhiteSpace(v)).Distinct(StringComparer.OrdinalIgnoreCase).ToList());

            foreach (var claim in detail.Claims)
            {
                if (groupedValues.TryGetValue(claim.Id, out var claimValues) && claimValues.Count > 0)
                {
                    claim.ValueList = claimValues;
                    claim.Values = string.Join(",", claimValues);
                    continue;
                }

                claim.ValueList = SplitValues(claim.Values);
            }

            return detail;
        }
        finally
        {
            await _context.Database.CloseConnectionAsync();
        }
    }

    public async Task<AccessUserRoleDetailResponse> GetUserRoleDetailAsync(int pkIdUsuario)
    {
        if (pkIdUsuario <= 0)
        {
            throw new ArgumentException("El usuario es requerido.", nameof(pkIdUsuario));
        }

        await _context.Database.OpenConnectionAsync();
        try
        {
            var user = (await QueryAsync(GetUserSql, MapUser, Param("@PkIdUsuario", pkIdUsuario))).FirstOrDefault()
                ?? throw new KeyNotFoundException("Usuario activo no encontrado.");

            return new AccessUserRoleDetailResponse
            {
                User = user,
                AssignedRoleIds = await QueryAsync(GetUserRolesSql, reader => GetString(reader, "RoleId"), Param("@PkIdUsuario", pkIdUsuario))
            };
        }
        finally
        {
            await _context.Database.CloseConnectionAsync();
        }
    }

    public async Task<AccessRoleDetailResponse> SaveRoleAsync(SaveAccessRoleRequest request, int operatorId)
    {
        if (request == null)
        {
            throw new ArgumentNullException(nameof(request));
        }

        request.Name = request.Name?.Trim() ?? string.Empty;
        request.Code = string.IsNullOrWhiteSpace(request.Code) ? null : request.Code.Trim();

        if (string.IsNullOrWhiteSpace(request.Name))
        {
            throw new ArgumentException("El nombre del rol es obligatorio.");
        }

        await _context.Database.OpenConnectionAsync();
        await using var transaction = await _context.Database.BeginTransactionAsync();
        try
        {
            var roleId = string.IsNullOrWhiteSpace(request.Id)
                ? await CreateRoleAsync(request, transaction)
                : await UpdateRoleAsync(request, transaction);

            if (request.ReplaceUsers)
            {
                await ReplaceRoleUsersAsync(roleId, request.AssignedUserIds, transaction);
            }

            if (request.ReplaceClaims)
            {
                var normalizedClaims = NormalizeClaims(request.Claims).ToList();
                var incomingValueCount = normalizedClaims.Sum(claim => claim.Values.Count(value => !string.IsNullOrWhiteSpace(value)));
                var existingClaimCount = await ScalarAsync<int>(
                    "SELECT COUNT(1) FROM dbo.AspNetClaims WHERE RoleId = @RoleId;",
                    transaction,
                    Param("@RoleId", roleId));

                if (existingClaimCount > 0 && incomingValueCount == 0)
                {
                    throw new InvalidOperationException("La matriz no cargo permisos para guardar. Se cancelo el reemplazo de claims existentes.");
                }

                await ReplaceRoleClaimsAsync(roleId, normalizedClaims, transaction);
            }

            await SynchronizeMenuRolesInternalAsync(operatorId, transaction);

            await transaction.CommitAsync();
            return await GetRoleDetailAsync(roleId);
        }
        catch
        {
            await transaction.RollbackAsync();
            throw;
        }
        finally
        {
            await _context.Database.CloseConnectionAsync();
        }
    }

    public async Task<AccessUserRoleDetailResponse> SaveUserRolesAsync(SaveAccessUserRolesRequest request, int operatorId)
    {
        if (request == null)
        {
            throw new ArgumentNullException(nameof(request));
        }

        if (request.PkIdUsuario <= 0)
        {
            throw new ArgumentException("El usuario es requerido.");
        }

        var roleIds = request.RoleIds
            .Select(roleId => roleId?.Trim())
            .Where(roleId => !string.IsNullOrWhiteSpace(roleId))
            .Select(roleId => roleId!)
            .Distinct(StringComparer.OrdinalIgnoreCase)
            .ToList();

        await _context.Database.OpenConnectionAsync();
        await using var transaction = await _context.Database.BeginTransactionAsync();
        try
        {
            var aspNetUserId = await ScalarAsync<string>(
                """
                SELECT TOP (1) AU.Id
                FROM dbo.AspNetUsers AS AU
                INNER JOIN SIS.Usuario AS U ON U.PKIdUsuario = AU.PkIdUsuario
                WHERE U.Activo = 1
                  AND U.PKIdUsuario = @PkIdUsuario;
                """,
                transaction,
                Param("@PkIdUsuario", request.PkIdUsuario));

            if (string.IsNullOrWhiteSpace(aspNetUserId))
            {
                throw new KeyNotFoundException("Usuario activo no encontrado.");
            }

            if (roleIds.Count > 0)
            {
                var existingRoleCount = await ScalarAsync<int>(
                    """
                    SELECT COUNT(1)
                    FROM dbo.AspNetRoles
                    WHERE Id IN (
                        SELECT [value]
                        FROM STRING_SPLIT(@RoleIds, '|')
                    );
                    """,
                    transaction,
                    Param("@RoleIds", string.Join('|', roleIds)));

                if (existingRoleCount != roleIds.Count)
                {
                    throw new ArgumentException("Uno o mas roles seleccionados no existen.");
                }
            }

            await ReplaceUserRolesAsync(aspNetUserId, roleIds, transaction);
            await SynchronizeMenuRolesInternalAsync(operatorId, transaction);

            await transaction.CommitAsync();
            return await GetUserRoleDetailAsync(request.PkIdUsuario);
        }
        catch
        {
            await transaction.RollbackAsync();
            throw;
        }
        finally
        {
            await _context.Database.CloseConnectionAsync();
        }
    }

    public async Task<int> SynchronizeMenuRolesAsync(int operatorId)
    {
        await _context.Database.OpenConnectionAsync();
        await using var transaction = await _context.Database.BeginTransactionAsync();
        try
        {
            var affected = await SynchronizeMenuRolesInternalAsync(operatorId, transaction);
            await transaction.CommitAsync();
            return affected;
        }
        catch
        {
            await transaction.RollbackAsync();
            throw;
        }
        finally
        {
            await _context.Database.CloseConnectionAsync();
        }
    }

    private async Task ReplaceUserRolesAsync(string aspNetUserId, IEnumerable<string> roleIds, IDbContextTransaction transaction)
    {
        await ExecuteAsync("DELETE FROM dbo.AspNetUserRoles WHERE UserId = @UserId;", transaction, Param("@UserId", aspNetUserId));

        foreach (var roleId in roleIds)
        {
            await ExecuteAsync(
                """
                INSERT INTO dbo.AspNetUserRoles (UserId, RoleId, ExpireDate)
                SELECT @UserId, R.Id, NULL
                FROM dbo.AspNetRoles AS R
                WHERE R.Id = @RoleId;
                """,
                transaction,
                Param("@UserId", aspNetUserId),
                Param("@RoleId", roleId));
        }
    }

    private async Task<string> CreateRoleAsync(SaveAccessRoleRequest request, IDbContextTransaction transaction)
    {
        var nextId = await ScalarAsync<string>(
            "SELECT CONVERT(nvarchar(128), ISNULL(MAX(TRY_CONVERT(int, Id)), 0) + 1) FROM dbo.AspNetRoles;",
            transaction);

        await ExecuteAsync(
            "INSERT INTO dbo.AspNetRoles (Id, Name, Code) VALUES (@Id, @Name, @Code);",
            transaction,
            Param("@Id", nextId),
            Param("@Name", request.Name),
            Param("@Code", request.Code));

        return nextId;
    }

    private async Task<string> UpdateRoleAsync(SaveAccessRoleRequest request, IDbContextTransaction transaction)
    {
        var roleId = request.Id!.Trim();
        var exists = await ScalarAsync<int>(
            "SELECT COUNT(1) FROM dbo.AspNetRoles WHERE Id = @Id;",
            transaction,
            Param("@Id", roleId));

        if (exists == 0)
        {
            throw new KeyNotFoundException("Rol no encontrado.");
        }

        await ExecuteAsync(
            "UPDATE dbo.AspNetRoles SET Name = @Name, Code = @Code WHERE Id = @Id;",
            transaction,
            Param("@Id", roleId),
            Param("@Name", request.Name),
            Param("@Code", request.Code));

        return roleId;
    }

    private async Task ReplaceRoleUsersAsync(string roleId, IEnumerable<int> assignedUserIds, IDbContextTransaction transaction)
    {
        await ExecuteAsync("DELETE FROM dbo.AspNetUserRoles WHERE RoleId = @RoleId;", transaction, Param("@RoleId", roleId));

        foreach (var userId in assignedUserIds.Distinct().Where(x => x > 0))
        {
            await ExecuteAsync(
                """
                INSERT INTO dbo.AspNetUserRoles (UserId, RoleId, ExpireDate)
                SELECT TOP (1) AU.Id, @RoleId, NULL
                FROM dbo.AspNetUsers AS AU
                INNER JOIN SIS.Usuario AS U ON U.PKIdUsuario = AU.PkIdUsuario
                WHERE U.Activo = 1
                  AND U.PKIdUsuario = @PkIdUsuario
                  AND NOT EXISTS (
                      SELECT 1
                      FROM dbo.AspNetUserRoles AS UR
                      WHERE UR.UserId = AU.Id AND UR.RoleId = @RoleId
                  );
                """,
                transaction,
                Param("@RoleId", roleId),
                Param("@PkIdUsuario", userId));
        }
    }

    private async Task ReplaceRoleClaimsAsync(string roleId, IEnumerable<SaveAccessClaimRequest> claims, IDbContextTransaction transaction)
    {
        await ExecuteAsync(
            """
            DELETE CV
            FROM dbo.AspNetClaimValues AS CV
            INNER JOIN dbo.AspNetClaims AS C ON C.Id = CV.ClaimId
            WHERE C.RoleId = @RoleId;

            DELETE FROM dbo.AspNetClaims WHERE RoleId = @RoleId;
            """,
            transaction,
            Param("@RoleId", roleId));

        foreach (var claim in NormalizeClaims(claims))
        {
            var values = claim.Values
                .Select(v => v.Trim())
                .Where(v => !string.IsNullOrWhiteSpace(v))
                .Distinct(StringComparer.OrdinalIgnoreCase)
                .ToList();

            if (values.Count == 0)
            {
                continue;
            }

            var claimId = await ScalarAsync<int>(
                """
                INSERT INTO dbo.AspNetClaims
                    (ClaimTypeId, Name, [Group], RoleId, TokenFormat, Created, SubGroup, Code, Description, [Values], ReferenceId)
                OUTPUT INSERTED.Id
                VALUES
                    (NULL, @Name, @Group, @RoleId, NULL, GETDATE(), @SubGroup, @Code, @Description, @Values, @ReferenceId);
                """,
                transaction,
                Param("@Name", string.IsNullOrWhiteSpace(claim.Name) ? claim.SubGroup : claim.Name),
                Param("@Group", claim.Group),
                Param("@RoleId", roleId),
                Param("@SubGroup", claim.SubGroup),
                Param("@Code", claim.Code),
                Param("@Description", claim.Description),
                Param("@Values", string.Join(",", values)),
                Param("@ReferenceId", claim.ReferenceId));

            foreach (var value in values)
            {
                await ExecuteAsync(
                    "INSERT INTO dbo.AspNetClaimValues (ClaimId, Value, Created) VALUES (@ClaimId, @Value, GETDATE());",
                    transaction,
                    Param("@ClaimId", claimId),
                    Param("@Value", value));
            }
        }
    }

    private async Task<int> SynchronizeMenuRolesInternalAsync(int operatorId, IDbContextTransaction transaction)
    {
        return await ExecuteAsync(
            """
            MERGE INTO SIS.MenuRole AS TARGET
            USING (
                SELECT DISTINCT M.PKIdMenu, R.Id AS RoleId, 1 AS Activo, @OperatorId AS CreatedByOperatorId, GETDATE() AS CreatedDateTime
                FROM dbo.AspNetRoles AS R
                INNER JOIN dbo.AspNetUserRoles AS UR ON R.Id = UR.RoleId
                INNER JOIN dbo.AspNetUsers AS U ON U.Id = UR.UserId
                INNER JOIN SIS.Usuario AS SU ON SU.PKIdUsuario = U.PkIdUsuario AND SU.Activo = 1
                INNER JOIN dbo.AspNetClaims AS C ON C.RoleId = R.Id
                INNER JOIN dbo.AspNetClaimValues AS CV ON C.Id = CV.ClaimId
                INNER JOIN SIS.Menu AS M ON M.Activo = 1
                CROSS APPLY (
                    SELECT
                        MenuLegacyKey = LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(ISNULL(M.LegacyName, ''), '_', ''), ' ', ''), '-', ''), '/', ''), '.', '')),
                        MenuNameKey = LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(ISNULL(M.Nombre, ''), '_', ''), ' ', ''), '-', ''), '/', ''), '.', '')),
                        MenuRouteKey = LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(ISNULL(M.Ruta, ''), '_', ''), ' ', ''), '-', ''), '/', ''), '.', '')),
                        MenuLastRouteKey = LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
                            CASE
                                WHEN M.Ruta IS NULL OR M.Ruta = '' THEN ''
                                WHEN CHARINDEX('/', REVERSE(M.Ruta)) = 0 THEN M.Ruta
                                ELSE RIGHT(M.Ruta, CHARINDEX('/', REVERSE(M.Ruta)) - 1)
                            END, '_', ''), ' ', ''), '-', ''), '/', ''), '.', ''))
                ) MK
                CROSS APPLY (
                    SELECT
                        ClaimSubGroupKey = LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(ISNULL(C.SubGroup, ''), '_', ''), ' ', ''), '-', ''), '/', ''), '.', '')),
                        ClaimCodeKey = LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(ISNULL(C.Code, ''), '_', ''), ' ', ''), '-', ''), '/', ''), '.', '')),
                        ClaimNameKey = LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(ISNULL(C.Name, ''), '_', ''), ' ', ''), '-', ''), '/', ''), '.', '')),
                        ClaimDescriptionKey = LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(ISNULL(C.Description, ''), '_', ''), ' ', ''), '-', ''), '/', ''), '.', ''))
                ) CK
                WHERE CV.Value LIKE '%view-menu%'
                  AND (
                      M.PKIdMenu = C.ReferenceId
                      OR MK.MenuLegacyKey = CK.ClaimSubGroupKey
                      OR MK.MenuNameKey = CK.ClaimSubGroupKey
                      OR MK.MenuLastRouteKey = CK.ClaimSubGroupKey
                      OR MK.MenuLastRouteKey = CK.ClaimNameKey
                      OR CK.ClaimSubGroupKey LIKE MK.MenuLastRouteKey + '%'
                      OR MK.MenuRouteKey = CK.ClaimSubGroupKey
                  )
            ) AS SOURCE (FKIdMenu_SIS, RoleId, Activo, CreatedByOperatorId, CreatedDateTime)
            ON (TARGET.FKIdMenu_SIS = SOURCE.FKIdMenu_SIS AND TARGET.RoleId = SOURCE.RoleId)
            WHEN MATCHED THEN
                UPDATE SET
                    TARGET.Activo = SOURCE.Activo,
                    TARGET.CreatedByOperatorId = SOURCE.CreatedByOperatorId,
                    TARGET.CreatedDateTime = SOURCE.CreatedDateTime,
                    TARGET.ModifiedByOperatorId = @OperatorId,
                    TARGET.ModifiedDateTime = GETDATE()
            WHEN NOT MATCHED BY TARGET THEN
                INSERT (FKIdMenu_SIS, RoleId, Activo, CreatedByOperatorId, CreatedDateTime)
                VALUES (SOURCE.FKIdMenu_SIS, SOURCE.RoleId, SOURCE.Activo, SOURCE.CreatedByOperatorId, SOURCE.CreatedDateTime);
            """,
            transaction,
            Param("@OperatorId", operatorId));
    }

    private async Task<List<T>> QueryAsync<T>(string sql, Func<DbDataReader, T> map, params DbParameter[] parameters)
    {
        await using var command = CreateCommand(sql, null, parameters);
        await using var reader = await command.ExecuteReaderAsync();
        var results = new List<T>();

        while (await reader.ReadAsync())
        {
            results.Add(map(reader));
        }

        return results;
    }

    private async Task<T> ScalarAsync<T>(string sql, IDbContextTransaction? transaction = null, params DbParameter[] parameters)
    {
        await using var command = CreateCommand(sql, transaction, parameters);
        var value = await command.ExecuteScalarAsync();
        if (value == null || value == DBNull.Value)
        {
            return default!;
        }

        return (T)Convert.ChangeType(value, typeof(T));
    }

    private async Task<int> ExecuteAsync(string sql, IDbContextTransaction transaction, params DbParameter[] parameters)
    {
        await using var command = CreateCommand(sql, transaction, parameters);
        return await command.ExecuteNonQueryAsync();
    }

    private DbCommand CreateCommand(string sql, IDbContextTransaction? transaction, params DbParameter[] parameters)
    {
        var command = _context.Database.GetDbConnection().CreateCommand();
        command.CommandText = sql;
        command.CommandType = CommandType.Text;
        command.Transaction = transaction?.GetDbTransaction();

        foreach (var parameter in parameters)
        {
            command.Parameters.Add(parameter);
        }

        return command;
    }

    private static DbParameter Param(string name, object? value)
    {
        var parameter = new Microsoft.Data.SqlClient.SqlParameter(name, value ?? DBNull.Value);
        return parameter;
    }

    private static IEnumerable<SaveAccessClaimRequest> NormalizeClaims(IEnumerable<SaveAccessClaimRequest> claims)
    {
        return claims
            .Where(c => !string.IsNullOrWhiteSpace(c.Group) && !string.IsNullOrWhiteSpace(c.SubGroup))
            .Select(c =>
            {
                c.Group = c.Group.Trim();
                c.SubGroup = c.SubGroup.Trim();
                c.Name = string.IsNullOrWhiteSpace(c.Name) ? c.SubGroup : c.Name.Trim();
                c.Code = string.IsNullOrWhiteSpace(c.Code) ? c.SubGroup : c.Code.Trim();
                c.Description = string.IsNullOrWhiteSpace(c.Description) ? c.Name : c.Description.Trim();
                return c;
            });
    }

    private static AccessRoleSummaryResponse MapRole(DbDataReader reader) => new()
    {
        Id = GetString(reader, "Id"),
        Name = GetString(reader, "Name"),
        Code = GetNullableString(reader, "Code"),
        ClaimCount = GetInt(reader, "ClaimCount"),
        UserCount = GetInt(reader, "UserCount"),
        MenuCount = GetInt(reader, "MenuCount")
    };

    private static AccessUserSummaryResponse MapUser(DbDataReader reader) => new()
    {
        PkIdUsuario = GetInt(reader, "PkIdUsuario"),
        AspNetUserId = GetString(reader, "AspNetUserId"),
        DisplayName = GetString(reader, "DisplayName"),
        Email = GetNullableString(reader, "Email"),
        PayrollId = GetNullableString(reader, "PayrollId"),
        AccessNumber = GetNullableString(reader, "AccessNumber"),
        RoleCount = GetInt(reader, "RoleCount")
    };

    private static AccessMenuSummaryResponse MapMenu(DbDataReader reader) => new()
    {
        PkIdMenu = GetInt(reader, "PkIdMenu"),
        ParentMenuId = GetNullableInt(reader, "ParentMenuId"),
        Name = GetString(reader, "Name"),
        LegacyName = GetString(reader, "LegacyName"),
        Route = GetNullableString(reader, "Route"),
        Icon = GetNullableString(reader, "Icon"),
        Type = GetInt(reader, "Type"),
        Order = GetNullableInt(reader, "Order")
    };

    private static AccessClaimResponse MapClaim(DbDataReader reader) => new()
    {
        Id = GetInt(reader, "Id"),
        Group = GetString(reader, "Group"),
        SubGroup = GetString(reader, "SubGroup"),
        Name = GetString(reader, "Name"),
        Code = GetNullableString(reader, "Code"),
        Description = GetNullableString(reader, "Description"),
        Values = GetNullableString(reader, "Values") ?? string.Empty,
        ReferenceId = GetInt(reader, "ReferenceId")
    };

    private static List<string> SplitValues(string? values) =>
        (values ?? string.Empty)
            .Split(',', StringSplitOptions.RemoveEmptyEntries | StringSplitOptions.TrimEntries)
            .Where(v => !string.IsNullOrWhiteSpace(v))
            .Distinct(StringComparer.OrdinalIgnoreCase)
            .ToList();

    private static string GetString(DbDataReader reader, string name) =>
        reader[name] == DBNull.Value ? string.Empty : Convert.ToString(reader[name]) ?? string.Empty;

    private static string? GetNullableString(DbDataReader reader, string name) =>
        reader[name] == DBNull.Value ? null : Convert.ToString(reader[name]);

    private static int GetInt(DbDataReader reader, string name) =>
        reader[name] == DBNull.Value ? 0 : Convert.ToInt32(reader[name]);

    private static int? GetNullableInt(DbDataReader reader, string name) =>
        reader[name] == DBNull.Value ? null : Convert.ToInt32(reader[name]);

    private const string GetRolesSql =
        """
        SELECT
            R.Id,
            R.Name,
            R.Code,
            ISNULL(C.ClaimCount, 0) AS ClaimCount,
            ISNULL(UR.UserCount, 0) AS UserCount,
            ISNULL(MR.MenuCount, 0) AS MenuCount
        FROM dbo.AspNetRoles AS R
        LEFT JOIN (
            SELECT RoleId, COUNT(1) AS ClaimCount
            FROM dbo.AspNetClaims
            GROUP BY RoleId
        ) AS C ON C.RoleId = R.Id
        LEFT JOIN (
            SELECT RoleId, COUNT(DISTINCT UserId) AS UserCount
            FROM dbo.AspNetUserRoles
            GROUP BY RoleId
        ) AS UR ON UR.RoleId = R.Id
        LEFT JOIN (
            SELECT RoleId, COUNT(DISTINCT FKIdMenu_SIS) AS MenuCount
            FROM SIS.MenuRole
            WHERE Activo = 1
            GROUP BY RoleId
        ) AS MR ON MR.RoleId = R.Id
        ORDER BY R.Name;
        """;

    private const string GetRoleSql =
        """
        SELECT
            R.Id,
            R.Name,
            R.Code,
            ISNULL(C.ClaimCount, 0) AS ClaimCount,
            ISNULL(UR.UserCount, 0) AS UserCount,
            ISNULL(MR.MenuCount, 0) AS MenuCount
        FROM dbo.AspNetRoles AS R
        OUTER APPLY (
            SELECT COUNT(1) AS ClaimCount
            FROM dbo.AspNetClaims
            WHERE RoleId = R.Id
        ) AS C
        OUTER APPLY (
            SELECT COUNT(DISTINCT UserId) AS UserCount
            FROM dbo.AspNetUserRoles
            WHERE RoleId = R.Id
        ) AS UR
        OUTER APPLY (
            SELECT COUNT(DISTINCT FKIdMenu_SIS) AS MenuCount
            FROM SIS.MenuRole
            WHERE Activo = 1
              AND RoleId = R.Id
        ) AS MR
        WHERE R.Id = @RoleId;
        """;

    private const string GetUsersSql =
        """
        SELECT
            U.PKIdUsuario AS PkIdUsuario,
            AU.Id AS AspNetUserId,
            COALESCE(NULLIF(CONCAT(P.Nombre, ' ', P.Paterno, ' ', P.Materno), '  '), AU.Email, U.PayrollID, AU.Id) AS DisplayName,
            COALESCE(NULLIF(AU.Email, ''), P.CORREO_ELECTRONICO) AS Email,
            U.PayrollID AS PayrollId,
            AU.AccessNumber,
            ISNULL(UR.RoleCount, 0) AS RoleCount
        FROM SIS.Usuario AS U
        INNER JOIN dbo.AspNetUsers AS AU ON AU.PkIdUsuario = U.PKIdUsuario
        LEFT JOIN NOM.Persona AS P ON P.PKIdPersona = U.FKIdPersona_NOM
        LEFT JOIN (
            SELECT UserId, COUNT(DISTINCT RoleId) AS RoleCount
            FROM dbo.AspNetUserRoles
            GROUP BY UserId
        ) AS UR ON UR.UserId = AU.Id
        WHERE U.Activo = 1
        ORDER BY DisplayName;
        """;

    private const string GetUserSql =
        """
        SELECT
            U.PKIdUsuario AS PkIdUsuario,
            AU.Id AS AspNetUserId,
            COALESCE(NULLIF(CONCAT(P.Nombre, ' ', P.Paterno, ' ', P.Materno), '  '), AU.Email, U.PayrollID, AU.Id) AS DisplayName,
            COALESCE(NULLIF(AU.Email, ''), P.CORREO_ELECTRONICO) AS Email,
            U.PayrollID AS PayrollId,
            AU.AccessNumber,
            ISNULL(UR.RoleCount, 0) AS RoleCount
        FROM SIS.Usuario AS U
        INNER JOIN dbo.AspNetUsers AS AU ON AU.PkIdUsuario = U.PKIdUsuario
        LEFT JOIN NOM.Persona AS P ON P.PKIdPersona = U.FKIdPersona_NOM
        OUTER APPLY (
            SELECT COUNT(DISTINCT RoleId) AS RoleCount
            FROM dbo.AspNetUserRoles
            WHERE UserId = AU.Id
        ) AS UR
        WHERE U.Activo = 1
          AND U.PKIdUsuario = @PkIdUsuario;
        """;

    private const string GetMenusSql =
        """
        SELECT
            M.PKIdMenu AS PkIdMenu,
            M.FKIdMenu_SIS AS ParentMenuId,
            M.Nombre AS Name,
            ISNULL(NULLIF(M.LegacyName, ''), M.Nombre) AS LegacyName,
            M.Ruta AS Route,
            M.ImageUrl AS Icon,
            CONVERT(int, M.Tipo) AS Type,
            CONVERT(int, M.Orden) AS [Order]
        FROM SIS.Menu AS M
        WHERE M.Activo = 1
          AND ISNULL(NULLIF(M.LegacyName, ''), M.Nombre) IS NOT NULL
        ORDER BY ISNULL(M.FKIdMenu_SIS, 0), M.Orden, M.Nombre;
        """;

    private const string GetRoleUsersSql =
        """
        SELECT DISTINCT U.PKIdUsuario AS PkIdUsuario
        FROM dbo.AspNetUserRoles AS UR
        INNER JOIN dbo.AspNetUsers AS AU ON AU.Id = UR.UserId
        INNER JOIN SIS.Usuario AS U ON U.PKIdUsuario = AU.PkIdUsuario
        WHERE UR.RoleId = @RoleId
          AND U.Activo = 1;
        """;

    private const string GetUserRolesSql =
        """
        SELECT DISTINCT UR.RoleId
        FROM dbo.AspNetUserRoles AS UR
        INNER JOIN dbo.AspNetUsers AS AU ON AU.Id = UR.UserId
        INNER JOIN SIS.Usuario AS U ON U.PKIdUsuario = AU.PkIdUsuario
        WHERE U.PKIdUsuario = @PkIdUsuario
          AND U.Activo = 1;
        """;

    private const string GetRoleClaimsSql =
        """
        SELECT
            C.Id,
            C.Name,
            ISNULL(C.[Group], '') AS [Group],
            ISNULL(C.SubGroup, '') AS SubGroup,
            C.Code,
            C.Description,
            C.[Values],
            ISNULL(C.ReferenceId, 0) AS ReferenceId
        FROM dbo.AspNetClaims AS C
        WHERE C.RoleId = @RoleId
        ORDER BY C.[Group], C.SubGroup, C.Name;
        """;

    private const string GetRoleClaimValuesSql =
        """
        SELECT CV.ClaimId, CV.Value
        FROM dbo.AspNetClaimValues AS CV
        INNER JOIN dbo.AspNetClaims AS C ON C.Id = CV.ClaimId
        WHERE C.RoleId = @RoleId
        ORDER BY CV.ClaimId, CV.Value;
        """;
}
