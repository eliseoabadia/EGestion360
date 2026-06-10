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

            var allowedLegacyNames = await _context.AspNetClaims
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
                .Select(c => c.SubGroup)
                .Distinct()
                .ToListAsync();

            if (allowedLegacyNames.Count == 0)
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

            var allowed = menus
                .Where(m => allowedLegacyNames.Contains(m.LegacyName))
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
        /// EsParaLogin NO se envía (default en SP) — este método es para cargar permisos post-login.
        /// </summary>
        public async Task<List<spGetClaimsByUserResult>> ObtenerClaimsUsuarioAsync(int usuarioId)
        {
            if (usuarioId <= 0)
                throw new ArgumentException("Usuario ID debe ser mayor a 0", nameof(usuarioId));

            try
            {
                // Solo se pasa @PkIdUser; @EsParaLogin NO se envía (queda NULL/0 en el SP)
                var paramUserId = new SqlParameter("@PkIdUser", usuarioId);
                var resultClaims = await _repositorySP.ExecuteStoredProcedureAsync<spGetClaimsByUserResult>(
                    "[SIS].[spGetClaimsByUser]",
                    paramUserId);

                return resultClaims?.ToList() ?? new List<spGetClaimsByUserResult>();
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error obteniendo claims para usuario {usuarioId}: {ex.Message}");
                throw;
            }
        }
    }
}
