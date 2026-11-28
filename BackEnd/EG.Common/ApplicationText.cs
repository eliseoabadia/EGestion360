namespace EG.Common;

/// <summary>
/// Shared Spanish presentation text. Contains no UI framework dependencies.
/// </summary>
public static class ApplicationText
{
    public static class NextTask
    {
        public const string Next = "Qué sigue";
        public const string Owner = "Quién lo hace";
        public const string Yours = "Qué puedes hacer tú";
        public const string SelectRecord = "Confirma el contexto y consulta los datos de esta pantalla. Selecciona un registro si necesitas revisar su detalle.";
        public const string UnknownOwner = "Se confirma al consultar el expediente y los roles asignados.";
        public const string ReadOnly = "Consulta los datos. Las acciones que no permite tu perfil no estarán disponibles.";
        public const string AvailableActions = "Usa las acciones disponibles según tu perfil y el estado del registro.";
        public const string FillForm = "Completa los campos requeridos y revisa los datos antes de confirmar.";
        public const string CaptureOwner = "La persona que está realizando esta captura.";
        public const string ConfirmThenContinue = "Confirma con el botón del formulario. Si hay datos inválidos, corrige los campos indicados.";
    }
    public static class Summary
    {
        public const string QuickHelp = "Guía rápida";
        public const string ProcessDetails = "Detalle del proceso";
        public const string Title = "Resumen del registro";
        public const string Open = "Ver resumen";
    }
    public static class Journey
    {
        public const string Title = "¿Dónde va esta requisición?";
        public const string Unavailable = "No se pudo confirmar el seguimiento. Actualiza el expediente para consultarlo.";
        public const string Recorded = "Comprobado";
        public const string Partial = "Parcial";
        public const string Pending = "Pendiente";
        public const string Scope = "El seguimiento refleja los documentos relacionados. Una palomita no confirma por sí sola el pago total del expediente.";
    }
    public static class Connection
    {
        public const string StartupUnavailable = "No pudimos conectar con el servidor para cargar tu espacio de trabajo. Comprueba que la API esté iniciada y vuelve a intentar.";
        public const string RetryStartup = "Volver a cargar";
    }
    public static class Workflow
    {
        public const string DeliveryUnconfirmed = "El envío requiere revisión: no se pudo confirmar su resultado. Verifica la entrega antes de intentar reenviarlo.";
        public const string DeliveryUnconfirmedCode = "DELIVERY_UNCONFIRMED";
    }

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
        public static string MaximumLength(string field, int maximum) => $"{field} no puede exceder {maximum} caracteres.";
        public const string Folio = "El folio";
        public const string ReceiptRejected = "No se pudo aplicar la recepción: revisa el saldo pendiente, la empresa y el ejercicio de la orden.";
        public const string ConcurrentChange = "El registro fue modificado por otro usuario. Recarga la información antes de guardar nuevamente.";
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
        public const string InvalidIdentity = "La sesión no contiene una identidad válida. Inicia sesión nuevamente.";
        public const string CompanyDenied = "No tienes acceso a la empresa solicitada.";
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
