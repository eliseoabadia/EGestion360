using EG.Application.Interfaces.Account;
using EG.Business.Interfaces;
using EG.Domain.Platform.Licensing;
using EG.Dommain.DTOs.Responses;
using EG.Infraestructure.Models;

namespace EG.Application.Services.Account
{
    public class NavigateAppService : INavigateAppService
    {
        private readonly INavigateService _navigateService;
        private readonly ILicenseRuntimeState _licensing;
        private readonly EG.Domain.Interfaces.IUserContextService _userContext;

        public NavigateAppService(INavigateService navigateService, ILicenseRuntimeState licensing,
            EG.Domain.Interfaces.IUserContextService userContext)
        {
            _navigateService = navigateService;
            _licensing = licensing;
            _userContext = userContext;
        }

        public async Task<IEnumerable<spNodeMenuResponse>> GetMenuAsync(int userId)
        {
            // 🔧 VALIDACIÓN
            if (userId <= 0)
                throw new ArgumentException("Usuario ID debe ser mayor a 0");

            try
            {
                // 🔧 LÓGICA: Obtener menú
                var menu = await _navigateService.GetMenuAsync(userId);

                if (menu == null)
                    throw new KeyNotFoundException($"Menú para usuario {userId} no encontrado");

                return EG.Common.Security.SystemRoles.IsSuperAdmin(_userContext.GetUserPrincipal())
                    ? menu
                    : FilterLicensedMenu(menu);
            }
            catch (KeyNotFoundException)
            {
                throw;
            }
            catch (Exception ex)
            {
                throw new InvalidOperationException($"Error al obtener menú: {ex.Message}", ex);
            }
        }

        private IReadOnlyList<spNodeMenuResponse> FilterLicensedMenu(IEnumerable<spNodeMenuResponse> source)
        {
            var items = source.ToList();
            var byId = items
                .Where(item => item.PKIdMenu.HasValue)
                .GroupBy(item => item.PKIdMenu!.Value)
                .ToDictionary(group => group.Key, group => group.First());
            var included = new HashSet<long>();

            foreach (var item in items)
            {
                if (!item.PKIdMenu.HasValue)
                    continue;

                var ancestorContext = BuildAncestorContext(item, byId);
                var moduleCode = LicenseModuleResolver.ResolveMenuModule(
                    item.Nombre,
                    item.LegacyName,
                    item.Ruta,
                    ancestorContext);

                var allowed = moduleCode is not null
                    ? _licensing.Evaluate(moduleCode).Allowed
                    : LicenseModuleResolver.IsCoreMenu(
                        item.Nombre,
                        item.LegacyName,
                        item.Ruta,
                        ancestorContext);

                if (allowed)
                    AddWithParents(item, byId, included);
            }

            return items
                .Where(item => item.PKIdMenu.HasValue && included.Contains(item.PKIdMenu.Value))
                .ToList();
        }

        private static string BuildAncestorContext(
            spNodeMenuResponse item,
            IReadOnlyDictionary<long, spNodeMenuResponse> byId)
        {
            var values = new List<string>();
            var visited = new HashSet<long>();
            var parentId = item.FkidMenuSis;

            while (parentId.HasValue && parentId.Value > 0 && visited.Add(parentId.Value) &&
                   byId.TryGetValue(parentId.Value, out var parent))
            {
                values.Add($"{parent.Nombre} {parent.LegacyName} {parent.Ruta}");
                parentId = parent.FkidMenuSis;
            }

            values.Reverse();
            return string.Join(' ', values);
        }

        private static void AddWithParents(
            spNodeMenuResponse item,
            IReadOnlyDictionary<long, spNodeMenuResponse> byId,
            ISet<long> included)
        {
            var current = item;
            var visited = new HashSet<long>();

            while (current.PKIdMenu.HasValue && visited.Add(current.PKIdMenu.Value))
            {
                included.Add(current.PKIdMenu.Value);
                if (!current.FkidMenuSis.HasValue || current.FkidMenuSis.Value <= 0 ||
                    !byId.TryGetValue(current.FkidMenuSis.Value, out var parent))
                {
                    break;
                }

                current = parent;
            }
        }

        /// <summary>
        /// Obtiene todos los claims del usuario desde la base de datos
        /// </summary>
        public async Task<List<spGetClaimsByUserResult>> GetAllClaimsByUser(int userId)
        {
            if (userId <= 0)
                throw new ArgumentException("Usuario ID debe ser mayor a 0");

            try
            {
                return await _navigateService.ObtenerClaimsUsuarioAsync(userId);
            }
            catch (Exception ex)
            {
                throw new InvalidOperationException($"Error al obtener claims para usuario {userId}: {ex.Message}", ex);
            }
        }
    }
}
