
namespace EG.Common
{
    public static class Constants
    {
        #region Constants

        public const string KEY_SECURITY = "ContraseñaSuperSecreta";
        public const string KEY_USERID = "UserId";
        public const string KEY_TOKEN = "Token";
        public const string BD_CON = "BD_MatrixEntities";

        #endregion


        #region Sistema

        public const int CATALOG_ORIGEN_LOG_MESSAGE_1 = 1; //SISTEMA GRP
        public const int CATALOG_ORIGEN_LOG_MESSAGE_2 = 2; //STORE PROCEDURE
        public const int CATALOG_ORIGEN_LOG_MESSAGE_3 = 3; //TRIGGERS
        public const string CATALOG_PARAM_SISTEMA = "SISTEMA";
        public const int CATALOG_PARAM_SISTEMA_VALUE = 1;
        public const string CATALOG_PARAM_SISTEMA_VALUE_CACHE = "CATALOG_PARAM_SISTEMA_VALUE";

        // User's data
        public const string FK_IDUSUARIO = "FK_IDUSUARIO";
        public const string FK_IDPERSONA = "FkIdPersonaSis";
        public const string USUARIO = "USUARIO";
        public const string EMAIL = "EMAIL";
        public const string FK_IDROL = "FK_IDROL";
        public const string LIST_AREAS = "LIST_AREAS";

        //Mensajes
        public const string MSG_DELETE = "¡Se eliminó el registro correctamente!";

        #endregion

    }
}
