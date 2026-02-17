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
        }

        public static List<IconoItem> Lista = new()
        {
            // Home
            new IconoItem { Nombre = "Home", Valor = "FaHome", Categoria = "Navegación", MaterialIcon = Icons.Material.Filled.Home },
            new IconoItem { Nombre = "Dashboard", Valor = "FaDashboard", Categoria = "Navegación", MaterialIcon = Icons.Material.Filled.Dashboard },
            new IconoItem { Nombre = "Menu", Valor = "RiMenuLine", Categoria = "Navegación", MaterialIcon = Icons.Material.Filled.Menu },
            
            // Usuarios
            new IconoItem { Nombre = "Usuario", Valor = "FaUser", Categoria = "Usuarios", MaterialIcon = Icons.Material.Filled.Person },
            new IconoItem { Nombre = "Usuarios", Valor = "FaUsers", Categoria = "Usuarios", MaterialIcon = Icons.Material.Filled.People },
            new IconoItem { Nombre = "Usuario Regular", Valor = "FaRegUser", Categoria = "Usuarios", MaterialIcon = Icons.Material.Filled.People },
            new IconoItem { Nombre = "Usuario Círculo", Valor = "FaUserCircle", Categoria = "Usuarios", MaterialIcon = Icons.Material.Filled.AccountCircle },
            new IconoItem { Nombre = "Grupo", Valor = "FaUserGroup", Categoria = "Usuarios", MaterialIcon = Icons.Material.Filled.Group },
            
            // Configuración
            new IconoItem { Nombre = "Configuración", Valor = "FaCog", Categoria = "Configuración", MaterialIcon = Icons.Material.Filled.Settings },
            new IconoItem { Nombre = "Sol", Valor = "FaRegSun", Categoria = "Configuración", MaterialIcon = Icons.Material.Filled.Settings },
            new IconoItem { Nombre = "Herramientas", Valor = "FaTools", Categoria = "Configuración", MaterialIcon = Icons.Material.Filled.Build },
            new IconoItem { Nombre = "Engranajes", Valor = "FaGears", Categoria = "Configuración", MaterialIcon = Icons.Material.Filled.Tune },
            
            // Archivos
            new IconoItem { Nombre = "Carpeta", Valor = "FaFolder", Categoria = "Archivos", MaterialIcon = Icons.Material.Filled.Folder },
            new IconoItem { Nombre = "Carpeta Abierta", Valor = "FaFolderOpen", Categoria = "Archivos", MaterialIcon = Icons.Material.Filled.FolderOpen },
            new IconoItem { Nombre = "Archivo", Valor = "FaFile", Categoria = "Archivos", MaterialIcon = Icons.Material.Filled.Description },
            new IconoItem { Nombre = "Lista", Valor = "RiListCheck2", Categoria = "Archivos", MaterialIcon = Icons.Material.Filled.List },
            new IconoItem { Nombre = "Documento", Valor = "FaDocument", Categoria = "Archivos", MaterialIcon = Icons.Material.Filled.Article },
            
            // Acciones
            new IconoItem { Nombre = "Agregar", Valor = "FaPlus", Categoria = "Acciones", MaterialIcon = Icons.Material.Filled.Add },
            new IconoItem { Nombre = "Editar", Valor = "FaEdit", Categoria = "Acciones", MaterialIcon = Icons.Material.Filled.Edit },
            new IconoItem { Nombre = "Eliminar", Valor = "FaTrash", Categoria = "Acciones", MaterialIcon = Icons.Material.Filled.Delete },
            new IconoItem { Nombre = "Guardar", Valor = "FaSave", Categoria = "Acciones", MaterialIcon = Icons.Material.Filled.Save },
            new IconoItem { Nombre = "Buscar", Valor = "FaSearch", Categoria = "Acciones", MaterialIcon = Icons.Material.Filled.Search },
            
            // Reportes
            new IconoItem { Nombre = "Gráfico Barras", Valor = "FaChartBar", Categoria = "Reportes", MaterialIcon = Icons.Material.Filled.BarChart },
            new IconoItem { Nombre = "Gráfico Pastel", Valor = "FaChartPie", Categoria = "Reportes", MaterialIcon = Icons.Material.Filled.PieChart },
            new IconoItem { Nombre = "Estadísticas", Valor = "FaChartLine", Categoria = "Reportes", MaterialIcon = Icons.Material.Filled.ShowChart },
            new IconoItem { Nombre = "Tabla", Valor = "FaTable", Categoria = "Reportes", MaterialIcon = Icons.Material.Filled.TableChart },
            
            // Seguridad
            new IconoItem { Nombre = "Candado", Valor = "FaLock", Categoria = "Seguridad", MaterialIcon = Icons.Material.Filled.Lock },
            new IconoItem { Nombre = "Candado Abierto", Valor = "FaLockOpen", Categoria = "Seguridad", MaterialIcon = Icons.Material.Filled.LockOpen },
            new IconoItem { Nombre = "Llave", Valor = "FaKey", Categoria = "Seguridad", MaterialIcon = Icons.Material.Filled.Key },
            
            // Notificaciones
            new IconoItem { Nombre = "Campana", Valor = "FaBell", Categoria = "Notificaciones", MaterialIcon = Icons.Material.Filled.Notifications },
            new IconoItem { Nombre = "Email", Valor = "FaEnvelope", Categoria = "Notificaciones", MaterialIcon = Icons.Material.Filled.Email },
            new IconoItem { Nombre = "Mensaje", Valor = "FaMessage", Categoria = "Notificaciones", MaterialIcon = Icons.Material.Filled.Message },
            
            // Varios
            new IconoItem { Nombre = "Estrella", Valor = "FaStar", Categoria = "Varios", MaterialIcon = Icons.Material.Filled.Star },
            new IconoItem { Nombre = "Corazón", Valor = "FaHeart", Categoria = "Varios", MaterialIcon = Icons.Material.Filled.Favorite },
            new IconoItem { Nombre = "Bandera", Valor = "FaFlag", Categoria = "Varios", MaterialIcon = Icons.Material.Filled.Flag },
            new IconoItem { Nombre = "Etiqueta", Valor = "FaTag", Categoria = "Varios", MaterialIcon = Icons.Material.Filled.Tag },
            new IconoItem { Nombre = "Calendario", Valor = "FaCalendar", Categoria = "Varios", MaterialIcon = Icons.Material.Filled.CalendarMonth },
            new IconoItem { Nombre = "Reloj", Valor = "FaClock", Categoria = "Varios", MaterialIcon = Icons.Material.Filled.Schedule },
            new IconoItem { Nombre = "Info", Valor = "FaInfo", Categoria = "Varios", MaterialIcon = Icons.Material.Filled.Info },
        };
    }
}
