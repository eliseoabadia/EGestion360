using EG.Web.Models.Configuration;

namespace EG.Web.Services
{
    public class MenuStateService
    {
        private int? _loadedUserId;
        private List<MenuItem> _items = new();

        public void Initialize(int userId, List<MenuItem> items)
        {
            _loadedUserId = userId;
            _items = items ?? new List<MenuItem>();
        }

        public bool TryGetItems(int userId, out List<MenuItem> items)
        {
            if (_loadedUserId == userId && _items.Count > 0)
            {
                items = _items;
                return true;
            }

            items = new List<MenuItem>();
            return false;
        }

        public void Clear()
        {
            _loadedUserId = null;
            _items = new List<MenuItem>();
        }
    }
}
