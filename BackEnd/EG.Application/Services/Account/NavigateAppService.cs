using EG.Application.Interfaces.Account;
using EG.Business.Interfaces;
using EG.Dommain.DTOs.Responses;

namespace EG.Application.Services.Account
{
    public class NavigateAppService : INavigateAppService
    {
        private readonly INavigateService _navigateService;

        public NavigateAppService(INavigateService navigateService)
        {
            _navigateService = navigateService;
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

                return menu;
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
    }
}