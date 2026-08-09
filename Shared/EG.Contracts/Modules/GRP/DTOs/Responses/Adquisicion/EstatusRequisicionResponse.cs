using System;

namespace EG.Domain.DTOs.Responses.Adquisicion
{
    public class EstatusRequisicionResponse
    {
        public int PkidEstatusRequisicion { get; set; }
        public string Descripcion { get; set; } = string.Empty;
        public string Color { get; set; } = string.Empty;
        public int Orden { get; set; }
        public string Icono { get; set; } = string.Empty;
        public bool Activo { get; set; }
        public DateTime? FechaCreacion { get; set; }
    }
}