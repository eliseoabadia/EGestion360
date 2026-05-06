using MudBlazor;

namespace EG.Web.Extensions
{
    public static class IconosDisponibles
    {
        public class IconoItem
        {
            public string Nombre { get; set; } = string.Empty;
            public string Valor { get; set; } = string.Empty;
            public string Categoria { get; set; } = string.Empty;
            public string MaterialIcon { get; set; } = string.Empty;
            public string BootstrapIcon { get; set; } = string.Empty;
        }

        public static List<IconoItem> Lista = new()
        {
            new IconoItem { Nombre = "Home", Valor = "FaHome", Categoria = "Navegaci\u00f3n", MaterialIcon = Icons.Material.Filled.Home, BootstrapIcon = "bi bi-house-door" },
            new IconoItem { Nombre = "Dashboard", Valor = "FaDashboard", Categoria = "Navegaci\u00f3n", MaterialIcon = Icons.Material.Filled.Dashboard, BootstrapIcon = "bi bi-speedometer2" },
            new IconoItem { Nombre = "Menu", Valor = "RiMenuLine", Categoria = "Navegaci\u00f3n", MaterialIcon = Icons.Material.Filled.Menu, BootstrapIcon = "bi bi-list" },
            
            new IconoItem { Nombre = "Usuario", Valor = "FaUser", Categoria = "Usuarios", MaterialIcon = Icons.Material.Filled.Person, BootstrapIcon = "bi bi-person" },
            new IconoItem { Nombre = "Usuarios", Valor = "FaUsers", Categoria = "Usuarios", MaterialIcon = Icons.Material.Filled.People, BootstrapIcon = "bi bi-people" },
            new IconoItem { Nombre = "Usuario Regular", Valor = "FaRegUser", Categoria = "Usuarios", MaterialIcon = Icons.Material.Filled.People, BootstrapIcon = "bi bi-person-badge" },
            new IconoItem { Nombre = "Usuario C\u00edrculo", Valor = "FaUserCircle", Categoria = "Usuarios", MaterialIcon = Icons.Material.Filled.AccountCircle, BootstrapIcon = "bi bi-person-circle" },
            new IconoItem { Nombre = "Grupo", Valor = "FaUserGroup", Categoria = "Usuarios", MaterialIcon = Icons.Material.Filled.Group, BootstrapIcon = "bi bi-people-fill" },
            
            new IconoItem { Nombre = "Configuraci\u00f3n", Valor = "FaCog", Categoria = "Configuraci\u00f3n", MaterialIcon = Icons.Material.Filled.Settings, BootstrapIcon = "bi bi-gear" },
            new IconoItem { Nombre = "Sol", Valor = "FaRegSun", Categoria = "Configuraci\u00f3n", MaterialIcon = Icons.Material.Filled.Settings, BootstrapIcon = "bi bi-sun" },
            new IconoItem { Nombre = "Herramientas", Valor = "FaTools", Categoria = "Configuraci\u00f3n", MaterialIcon = Icons.Material.Filled.Build, BootstrapIcon = "bi bi-tools" },
            new IconoItem { Nombre = "Engranajes", Valor = "FaGears", Categoria = "Configuraci\u00f3n", MaterialIcon = Icons.Material.Filled.Tune, BootstrapIcon = "bi bi-gear-wide-connected" },
            
            new IconoItem { Nombre = "Carpeta", Valor = "FaFolder", Categoria = "Archivos", MaterialIcon = Icons.Material.Filled.Folder, BootstrapIcon = "bi bi-folder" },
            new IconoItem { Nombre = "Carpeta Abierta", Valor = "FaFolderOpen", Categoria = "Archivos", MaterialIcon = Icons.Material.Filled.FolderOpen, BootstrapIcon = "bi bi-folder2-open" },
            new IconoItem { Nombre = "Archivo", Valor = "FaFile", Categoria = "Archivos", MaterialIcon = Icons.Material.Filled.Description, BootstrapIcon = "bi bi-file-earmark" },
            new IconoItem { Nombre = "Lista", Valor = "RiListCheck2", Categoria = "Archivos", MaterialIcon = Icons.Material.Filled.List, BootstrapIcon = "bi bi-list-check" },
            new IconoItem { Nombre = "Documento", Valor = "FaDocument", Categoria = "Archivos", MaterialIcon = Icons.Material.Filled.Article, BootstrapIcon = "bi bi-file-earmark-text" },
            
            new IconoItem { Nombre = "Agregar", Valor = "FaPlus", Categoria = "Acciones", MaterialIcon = Icons.Material.Filled.Add, BootstrapIcon = "bi bi-plus-lg" },
            new IconoItem { Nombre = "Editar", Valor = "FaEdit", Categoria = "Acciones", MaterialIcon = Icons.Material.Filled.Edit, BootstrapIcon = "bi bi-pencil" },
            new IconoItem { Nombre = "Eliminar", Valor = "FaTrash", Categoria = "Acciones", MaterialIcon = Icons.Material.Filled.Delete, BootstrapIcon = "bi bi-trash" },
            new IconoItem { Nombre = "Guardar", Valor = "FaSave", Categoria = "Acciones", MaterialIcon = Icons.Material.Filled.Save, BootstrapIcon = "bi bi-save" },
            new IconoItem { Nombre = "Buscar", Valor = "FaSearch", Categoria = "Acciones", MaterialIcon = Icons.Material.Filled.Search, BootstrapIcon = "bi bi-search" },
            
            new IconoItem { Nombre = "Gr\u00e1fico Barras", Valor = "FaChartBar", Categoria = "Reportes", MaterialIcon = Icons.Material.Filled.BarChart, BootstrapIcon = "bi bi-bar-chart" },
            new IconoItem { Nombre = "Gr\u00e1fico Pastel", Valor = "FaChartPie", Categoria = "Reportes", MaterialIcon = Icons.Material.Filled.PieChart, BootstrapIcon = "bi bi-pie-chart" },
            new IconoItem { Nombre = "Estad\u00edsticas", Valor = "FaChartLine", Categoria = "Reportes", MaterialIcon = Icons.Material.Filled.ShowChart, BootstrapIcon = "bi bi-graph-up" },
            new IconoItem { Nombre = "Tabla", Valor = "FaTable", Categoria = "Reportes", MaterialIcon = Icons.Material.Filled.TableChart, BootstrapIcon = "bi bi-table" },
            
            new IconoItem { Nombre = "Candado", Valor = "FaLock", Categoria = "Seguridad", MaterialIcon = Icons.Material.Filled.Lock, BootstrapIcon = "bi bi-lock" },
            new IconoItem { Nombre = "Candado Abierto", Valor = "FaLockOpen", Categoria = "Seguridad", MaterialIcon = Icons.Material.Filled.LockOpen, BootstrapIcon = "bi bi-lock-fill" },
            new IconoItem { Nombre = "Llave", Valor = "FaKey", Categoria = "Seguridad", MaterialIcon = Icons.Material.Filled.Key, BootstrapIcon = "bi bi-key" },
            
            new IconoItem { Nombre = "Campana", Valor = "FaBell", Categoria = "Notificaciones", MaterialIcon = Icons.Material.Filled.Notifications, BootstrapIcon = "bi bi-bell" },
            new IconoItem { Nombre = "Email", Valor = "FaEnvelope", Categoria = "Notificaciones", MaterialIcon = Icons.Material.Filled.Email, BootstrapIcon = "bi bi-envelope" },
            new IconoItem { Nombre = "Mensaje", Valor = "FaMessage", Categoria = "Notificaciones", MaterialIcon = Icons.Material.Filled.Message, BootstrapIcon = "bi bi-chat-dots" },
            
            new IconoItem { Nombre = "Estrella", Valor = "FaStar", Categoria = "Varios", MaterialIcon = Icons.Material.Filled.Star, BootstrapIcon = "bi bi-star" },
            new IconoItem { Nombre = "Coraz\u00f3n", Valor = "FaHeart", Categoria = "Varios", MaterialIcon = Icons.Material.Filled.Favorite, BootstrapIcon = "bi bi-heart" },
            new IconoItem { Nombre = "Bandera", Valor = "FaFlag", Categoria = "Varios", MaterialIcon = Icons.Material.Filled.Flag, BootstrapIcon = "bi bi-flag" },
            new IconoItem { Nombre = "Etiqueta", Valor = "FaTag", Categoria = "Varios", MaterialIcon = Icons.Material.Filled.Tag, BootstrapIcon = "bi bi-tag" },
            new IconoItem { Nombre = "Calendario", Valor = "FaCalendar", Categoria = "Varios", MaterialIcon = Icons.Material.Filled.CalendarMonth, BootstrapIcon = "bi bi-calendar" },
            new IconoItem { Nombre = "Reloj", Valor = "FaClock", Categoria = "Varios", MaterialIcon = Icons.Material.Filled.Schedule, BootstrapIcon = "bi bi-clock" },
            new IconoItem { Nombre = "Info", Valor = "FaInfo", Categoria = "Varios", MaterialIcon = Icons.Material.Filled.Info, BootstrapIcon = "bi bi-info-circle" },
        };
    }
}
