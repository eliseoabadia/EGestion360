using System;
using System.Collections.Generic;
using System.Text;

namespace EG.Domain.DTOs.Responses.General
{
    public class DepartamentoResponse
    {
        public int? PkidEmpresa { get; set; }

        public string EmpresaNombre { get; set; }

        public string Rfc { get; set; }

        public int? PkidDepartamento { get; set; }

        public string DepartamentoNombre { get; set; }

        public bool? DepartamentoActivo { get; set; }

        public bool? EmpresaActivo { get; set; }
    }
}
