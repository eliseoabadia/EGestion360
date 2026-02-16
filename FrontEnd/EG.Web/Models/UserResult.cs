namespace EG.Web.Models
{
    public class UserResult
    {
        public Guid Id { get; set; }
        public int PkIdUsuario { get; set; }
        public string PayrollId { get; set; }
        public string NombreUsuario { get; set; }
        public string Email { get; set; }
        public string Gafete { get; set; }
        public DateTime CreateAt { get; set; }
        public DateTime UpdateAt { get; set; }
        public string? AccessToken { get; set; }
        public string? RefreshToken { get; set; }

        public DateTime RefreshTokenExpiryTime { get; set; }

        public bool? IsAuthenticated { get; set; }

        public string? Message { get; set; }
    }
}
