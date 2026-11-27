namespace EG.Common;

/// <summary>
/// Shared Spanish presentation text. Contains no UI framework dependencies.
/// </summary>
public static class ApplicationText
{
    public static class FiscalYear
    {
        public const string LoadingContext = "Preparando empresa y ejercicio presupuestal...";
        public const string SelectionRequired = "Selecciona un año presupuestal en el encabezado.";
    }

    public static class Actions
    {
        public const string Create = "Crear";
        public const string Update = "Actualizar";
        public const string Edit = "Editar";
        public const string Delete = "Eliminar";
        public const string Save = "Guardar";
        public const string Cancel = "Cancelar";
        public const string Close = "Cerrar";
        public const string Clear = "Limpiar";
    }

    public static class Status
    {
        public const string LoadingData = "Cargando datos...";
        public const string Saving = "Guardando...";
        public const string Creating = "Creando...";
        public const string Updating = "Actualizando...";
        public const string Active = "Activo";
        public const string Inactive = "Inactivo";
    }

    public static class Records
    {
        public const string Invalid = "Registro no válido";
        public const string Selected = "Registro seleccionado";
        public const string Related = "Registro relacionado";
        public const string MissingDescription = "Registro sin descripción";
        public const string PeriodMissingDescription = "Periodo sin descripción";
        public const string EmployeeMissingName = "Empleado sin clave ni nombre";
        public const string New = "Nuevo registro";
        public const string Edit = "Editar registro";
    }

    public static class Validation
    {
        public const string RequiredFields = "Completa los campos requeridos.";
        public const string InvalidUser = "El usuario seleccionado no es válido.";
        public const string InvalidCredentials = "Credenciales incorrectas";
    }

    public static class Permissions
    {
        public const string CreateDenied = "No tienes permisos para crear";
        public const string EditDenied = "No tienes permisos para editar";
        public const string DeleteDenied = "No tienes permisos para eliminar";
        public const string ExportDenied = "No tienes permisos para exportar";
        public const string ResourceDenied = "No tienes permiso para acceder a este recurso.";
        public const string OwnNavigationOnly = "Solo puedes consultar tu propio menú y permisos.";
    }

    public static class Paging
    {
        public const string ContextChanged = "El contexto de consulta cambió.";
        public const string QueryFailed = "No fue posible consultar todos los registros.";
        public const string DataChanged = "Los registros cambiaron durante la consulta. Actualiza e intenta nuevamente.";
        public const string Incomplete = "La consulta paginada está incompleta.";
        public const string CountMismatch = "El total recibido no coincide con los registros consultados.";
    }
}
