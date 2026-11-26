namespace EG.Infraestructure.Models
{
    public partial class LoginInformationEmployeeResult
    {
        public int? FkidEmpresaSis { get; set; }

        [System.ComponentModel.DataAnnotations.Schema.NotMapped]
        public List<string> Roles { get; set; } = new();
    }
}
