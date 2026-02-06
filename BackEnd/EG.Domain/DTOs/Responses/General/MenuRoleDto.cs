using System;
using System.Collections.Generic;
using System.Text;

namespace EG.Domain.DTOs.Responses.General
{
    public class MenuRoleDto
    {
        public long FkidMenuSis { get; set; }

        public string RoleId { get; set; }

        public bool Activo { get; set; }
    }
}
