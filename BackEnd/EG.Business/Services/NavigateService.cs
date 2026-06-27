using Mapster;
using EG.Business.Interfaces;
using EG.Domain.Interfaces;
using EG.Dommain.DTOs.Responses;
using EG.Infraestructure.Models;
using Microsoft.Data.SqlClient;
using Microsoft.EntityFrameworkCore;


namespace EG.Business.Services
{
    public class NavigateService(IRepositorySP<spNodeMenuResult> repositorySP, EGestionContext context) : INavigateService
    {
        private readonly IRepositorySP<spNodeMenuResult> _repositorySP = repositorySP;
        private readonly EGestionContext _context = context;

        public async Task<IEnumerable<spNodeMenuResponse>> GetMenuAsync(int empId)
        {
            var param1 = new SqlParameter("@NoEmploye", empId);
            var param2 = new SqlParameter("@Lenguaje", "ESP");
            var menu = await _repositorySP.ExecuteStoredProcedureAsync<spNodeMenuResult>("[SIS].[spNodeMenu]", param1, param2);
            var mappedMenu = menu.Adapt<List<spNodeMenuResponse>>();

            if (mappedMenu.Count > 0)
            {
                return mappedMenu;
            }

            return await GetMenuFromClaimsAsync(empId, "ESP");
        }

        private async Task<List<spNodeMenuResponse>> GetMenuFromClaimsAsync(int userId, string lenguaje)
        {
            var roleIds = await _context.AspNetUserRoles
                .AsNoTracking()
                .Where(ur => ur.User.PkIdUsuario == userId)
                .Select(ur => ur.RoleId)
                .Distinct()
                .ToListAsync();

            if (roleIds.Count == 0)
            {
                return new List<spNodeMenuResponse>();
            }

            var allowedClaims = await _context.AspNetClaims
                .AsNoTracking()
                .Where(c =>
                    c.RoleId != null &&
                    roleIds.Contains(c.RoleId) &&
                    c.Group != null &&
                    c.SubGroup != null &&
                    (
                        (c.Values != null && c.Values.Contains("view-menu")) ||
                        c.AspNetClaimValues.Any(v => v.Value == "view-menu")
                    ))
                .Select(c => new MenuClaimKey
                {
                    SubGroup = c.SubGroup,
                    Code = c.Code,
                    Name = c.Name,
                    Description = c.Description,
                    ReferenceId = c.ReferenceId
                })
                .Distinct()
                .ToListAsync();

            if (allowedClaims.Count == 0)
            {
                return new List<spNodeMenuResponse>();
            }

            var menus = await _context.Menus
                .AsNoTracking()
                .Where(m =>
                    m.Activo &&
                    m.Lenguaje == lenguaje &&
                    m.LegacyName != null)
                .ToListAsync();

            var allowedClaimKeys = allowedClaims
                .SelectMany(BuildClaimMatchKeys)
                .Where(key => !string.IsNullOrWhiteSpace(key))
                .ToHashSet(StringComparer.OrdinalIgnoreCase);

            var allowedReferenceIds = allowedClaims
                .Select(claim => claim.ReferenceId)
                .Where(referenceId => referenceId > 0)
                .ToHashSet();

            var allowed = menus
                .Where(menu => allowedReferenceIds.Contains(menu.PkidMenu)
                               || BuildMenuMatchKeys(menu).Any(allowedClaimKeys.Contains))
                .ToList();

            var result = new Dictionary<int, Menu>();
            foreach (var menu in allowed)
            {
                AddMenuWithParents(menu, menus, result);
            }

            return result.Values
                .OrderBy(m => m.PkidMenu)
                .Select(ToMenuResponse)
                .ToList();
        }

        private static void AddMenuWithParents(Menu menu, List<Menu> allMenus, Dictionary<int, Menu> result)
        {
            if (!result.ContainsKey(menu.PkidMenu))
            {
                result.Add(menu.PkidMenu, menu);
            }

            if (!menu.FkidMenuSis.HasValue || menu.FkidMenuSis.Value <= 0)
            {
                return;
            }

            var parent = allMenus.FirstOrDefault(m => m.PkidMenu == menu.FkidMenuSis.Value);
            if (parent != null)
            {
                AddMenuWithParents(parent, allMenus, result);
            }
        }

        private static spNodeMenuResponse ToMenuResponse(Menu menu)
        {
            return new spNodeMenuResponse
            {
                PKIdMenu = menu.PkidMenu,
                Nombre = menu.Nombre,
                Tipo = Convert.ToByte(menu.Tipo),
                FkidMenuSis = menu.FkidMenuSis ?? 0,
                LegacyName = menu.LegacyName,
                Ruta = menu.Ruta,
                ImageUrl = menu.ImageUrl,
                Activo = menu.Activo,
                Lenguaje = menu.Lenguaje,
                UserId = string.Empty,
                Orden = menu.Orden.HasValue ? Convert.ToInt16(menu.Orden.Value) : null
            };
        }

        /// <summary>
        /// Obtiene los claims del usuario desde la base de datos.
        /// Solo devuelve permisos asociados a menús activos.
        /// </summary>
        public async Task<List<spGetClaimsByUserResult>> ObtenerClaimsUsuarioAsync(int usuarioId)
        {
            if (usuarioId <= 0)
                throw new ArgumentException("Usuario ID debe ser mayor a 0", nameof(usuarioId));

            try
            {
                var parameters = new[]
                {
                    new SqlParameter("@PkIdUser", usuarioId),
                    new SqlParameter("@EsParaLogin", true)
                };
                var resultClaims = await _repositorySP.ExecuteStoredProcedureAsync<spGetClaimsByUserResult>(
                    "[SIS].[spGetClaimsByUser]",
                    parameters);

                var claims = resultClaims?.ToList() ?? new List<spGetClaimsByUserResult>();
                if (claims.Count > 0)
                {
                    return claims;
                }

                return await GetClaimsFromRolesAsync(usuarioId);
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error obteniendo claims para usuario {usuarioId}: {ex.Message}");
                throw;
            }
        }

        private async Task<List<spGetClaimsByUserResult>> GetClaimsFromRolesAsync(int usuarioId)
        {
            var claims = await _context.AspNetClaims
                .AsNoTracking()
                .Include(claim => claim.AspNetClaimValues)
                .Where(claim =>
                    claim.Role != null &&
                    claim.Role.AspNetUserRoles.Any(userRole =>
                        userRole.User != null &&
                        userRole.User.PkIdUsuario == usuarioId &&
                        userRole.User.PkIdUsuarioNavigation != null &&
                        userRole.User.PkIdUsuarioNavigation.Activo))
                .Where(claim => claim.Group != null && claim.SubGroup != null)
                .ToListAsync();

            return claims
                .Select(claim => new spGetClaimsByUserResult
                {
                    Group = claim.Group!,
                    SubGroup = claim.SubGroup!,
                    Values = BuildClaimValues(claim)
                })
                .DistinctBy(claim => $"{claim.Group}|{claim.SubGroup}|{claim.Values}")
                .OrderBy(claim => claim.Group)
                .ThenBy(claim => claim.SubGroup)
                .ThenBy(claim => claim.Values)
                .ToList();
        }

        private static string BuildClaimValues(AspNetClaim claim)
        {
            var values = claim.AspNetClaimValues
                .Select(value => value.Value)
                .Concat((claim.Values ?? string.Empty).Split(',', StringSplitOptions.RemoveEmptyEntries | StringSplitOptions.TrimEntries))
                .Where(value => !string.IsNullOrWhiteSpace(value))
                .Distinct(StringComparer.OrdinalIgnoreCase);

            return string.Join(",", values);
        }

        private static IEnumerable<string> BuildClaimMatchKeys(MenuClaimKey claim)
        {
            yield return NormalizeLooseKey(claim.SubGroup);
            yield return NormalizeLooseKey(claim.Code);
            yield return NormalizeLooseKey(claim.Name);
            yield return NormalizeLooseKey(claim.Description);
        }

        private static HashSet<string> BuildMenuMatchKeys(Menu menu)
        {
            var keys = new HashSet<string>(StringComparer.OrdinalIgnoreCase);
            AddLooseKey(keys, menu.LegacyName);
            AddLooseKey(keys, menu.Nombre);
            AddLooseKey(keys, menu.Ruta);

            var routeSegments = (menu.Ruta ?? string.Empty)
                .Split('/', StringSplitOptions.RemoveEmptyEntries | StringSplitOptions.TrimEntries);

            if (routeSegments.Length > 0)
            {
                AddLooseKey(keys, routeSegments[^1]);
                AddLooseKey(keys, routeSegments[0]);
            }

            if (routeSegments.Length > 1)
            {
                AddLooseKey(keys, $"{routeSegments[^1]}_{routeSegments[0]}");
                AddLooseKey(keys, $"{routeSegments[0]}_{routeSegments[^1]}");
            }

            return keys;
        }

        private static void AddLooseKey(HashSet<string> keys, string? value)
        {
            var key = NormalizeLooseKey(value);
            if (!string.IsNullOrWhiteSpace(key))
            {
                keys.Add(key);
            }
        }

        private static string NormalizeLooseKey(string? value)
        {
            var normalized = (value ?? string.Empty)
                .Trim()
                .Normalize(System.Text.NormalizationForm.FormD);

            return new string(normalized
                .Where(ch => System.Globalization.CharUnicodeInfo.GetUnicodeCategory(ch) != System.Globalization.UnicodeCategory.NonSpacingMark)
                .Where(char.IsLetterOrDigit)
                .Select(char.ToLowerInvariant)
                .ToArray());
        }

        private sealed class MenuClaimKey
        {
            public string? SubGroup { get; set; }
            public string? Code { get; set; }
            public string? Name { get; set; }
            public string? Description { get; set; }
            public int ReferenceId { get; set; }
        }
    }
}
