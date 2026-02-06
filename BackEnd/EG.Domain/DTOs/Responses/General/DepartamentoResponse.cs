using System;
using System.Collections.Generic;
using System.Text;

namespace EG.Domain.DTOs.Responses.General
{
    public class DepartamentoResponse
    {
        public int? PkidDepartamento { get; set; }

        public int FkidEmpresaSis { get; set; }

        public string Nombre { get; set; }

        public bool Activo { get; set; }
    }
}
