namespace EG.Domain.DTOs.Responses.General
{
    public class PeriodoPagoResponse
    {
        public int PkidCatalogoSimple { get; set; }

        public int? LegacyId { get; set; }

        public string Descripcion { get; set; } = string.Empty;

        public string DescripcionCorta { get; set; } = string.Empty;

        public int? Orden { get; set; }

        public bool Activo { get; set; }

        public string ClaveNombre => Descripcion;
    }
}
