// Services/MenuStateService.cs
using EG.Web.Models.Configuration;

namespace EG.Web.Services
{
    public class MenuStateService
    {
        private Dictionary<long, bool> _expandedStates = new();
        private string _searchTerm = string.Empty;
        private List<MenuItem> _originalItems = new();
        private List<MenuItem> _filteredItems = new();

        public event EventHandler? StateChanged;
        public event EventHandler? SearchChanged;

        public IReadOnlyList<MenuItem> FilteredItems => _filteredItems.AsReadOnly();
        public string SearchTerm
        {
            get => _searchTerm;
            set
            {
                if (_searchTerm != value)
                {
                    _searchTerm = value;
                    FilterItems();
                    SearchChanged?.Invoke(this, EventArgs.Empty);
                }
            }
        }

        public void Initialize(List<MenuItem> items)
        {
            _originalItems = items;
            _filteredItems = new List<MenuItem>(items);

            // Inicializar estados expandidos
            _expandedStates.Clear();
            foreach (var item in FlattenMenu(items).Where(x => x.Children?.Any() == true))
            {
                _expandedStates[item.PkidMenu] = false;
            }

            StateChanged?.Invoke(this, EventArgs.Empty);
        }

        public bool GetExpandedState(long pkId) =>
            _expandedStates.TryGetValue(pkId, out var state) ? state : false;

        public void SetExpandedState(long pkId, bool expanded)
        {
            _expandedStates[pkId] = expanded;
            StateChanged?.Invoke(this, EventArgs.Empty);
        }

        public void ToggleAll(bool expand)
        {
            var keys = _expandedStates.Keys.ToList();
            foreach (var key in keys)
            {
                _expandedStates[key] = expand;
            }
            StateChanged?.Invoke(this, EventArgs.Empty);
        }

        public void CollapseAll() => ToggleAll(false);
        public void ExpandAll() => ToggleAll(true);

        private void FilterItems()
        {
            if (string.IsNullOrWhiteSpace(_searchTerm))
            {
                _filteredItems = new List<MenuItem>(_originalItems);
            }
            else
            {
                var term = _searchTerm.Trim().ToLowerInvariant();
                _filteredItems = _originalItems
                    .Where(item => MenuItemMatchesSearch(item, term))
                    .Select(item => FilterMenuItem(item, term))
                    .Where(item => item != null)
                    .Cast<MenuItem>()
                    .ToList();

                // Expandir automáticamente los grupos que tienen coincidencias
                ExpandMatchingGroups(_filteredItems);
            }

            StateChanged?.Invoke(this, EventArgs.Empty);
        }

        private bool MenuItemMatchesSearch(MenuItem item, string term)
        {
            if (item.Nombre.ToLowerInvariant().Contains(term))
                return true;

            if (item.Children?.Any() == true)
                return item.Children.Any(child => MenuItemMatchesSearch(child, term));

            return false;
        }

        private MenuItem? FilterMenuItem(MenuItem item, string term)
        {
            if (item.Nombre.ToLowerInvariant().Contains(term))
                return item;

            if (item.Children?.Any() == true)
            {
                var filteredChildren = item.Children
                    .Select(child => FilterMenuItem(child, term))
                    .Where(child => child != null)
                    .Cast<MenuItem>()
                    .ToList();

                if (filteredChildren.Any())
                {
                    return new MenuItem
                    {
                        PkidMenu = item.PkidMenu,
                        Nombre = item.Nombre,
                        Ruta = item.Ruta,
                        ImageUrl = item.ImageUrl,
                        Orden = item.Orden,
                        Children = filteredChildren
                    };
                }
            }

            return null;
        }

        private void ExpandMatchingGroups(List<MenuItem> items)
        {
            foreach (var item in FlattenMenu(items))
            {
                if (item.Children?.Any() == true)
                {
                    _expandedStates[item.PkidMenu] = true;
                }
            }
        }

        private IEnumerable<MenuItem> FlattenMenu(List<MenuItem> items)
        {
            foreach (var item in items)
            {
                yield return item;
                if (item.Children?.Any() == true)
                {
                    foreach (var child in FlattenMenu(item.Children))
                    {
                        yield return child;
                    }
                }
            }
        }
    }
}