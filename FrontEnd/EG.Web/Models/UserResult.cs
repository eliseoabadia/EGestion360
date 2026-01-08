namespace EG.Web.Models
{
    public class UserResult
    {
        public Guid Id { get; set; }
        public int PkIdUsuario { get; set; }
        public string PayrollId { get; set; }
        public string FirstName { get; set; }
        public string LastName { get; set; }
        public string Email { get; set; }
        public string Gender { get; set; }
        public DateTime CreateAt { get; set; }
        public DateTime UpdateAt { get; set; }
        public string? AccessToken { get; set; }
        public string? RefreshToken { get; set; }
    }
}
