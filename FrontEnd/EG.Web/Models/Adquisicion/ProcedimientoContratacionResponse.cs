using System;

namespace EG.Web.Models.Adquisicion
{
    public class ProcedimientoContratacionResponse
    {
        public int PkidProcedimientoContratacion { get; set; }
        public string Descripcion { get; set; } = string.Empty;
        public string FundamentoJuridico { get; set; } = string.Empty;
        public bool Activo { get; set; }
        public DateTime? FechaCreacion { get; set; }
    }
}