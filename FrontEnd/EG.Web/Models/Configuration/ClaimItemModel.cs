namespace EG.Web.Models.Configuration
{
    /// <summary>
    /// Modelo que representa un claim de permisos retornado por [SIS].[spGetClaimsByUser]
    /// Propiedades: Group, SubGroup, Values (CSV de acciones)
    /// </summary>
    public class ClaimItemModel
    {
        public string Group { get; set; } = string.Empty;
        public string SubGroup { get; set; } = string.Empty;
        public string Values { get; set; } = string.Empty;
    }
}
