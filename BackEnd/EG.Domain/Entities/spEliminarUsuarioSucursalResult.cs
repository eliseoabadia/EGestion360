
using System.ComponentModel.DataAnnotations;


namespace EG.Domain.Entities
{
    public partial class spEliminarUsuarioSucursalResult
    {
        public int Success { get; set; }
        [StringLength(41)]
        public string Message { get; set; }
        [StringLength(9)]
        public string Code { get; set; }
    }
}
