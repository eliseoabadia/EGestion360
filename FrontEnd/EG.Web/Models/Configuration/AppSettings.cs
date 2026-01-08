namespace EG.Web.Models.Configuration
{
    public class ApiSettings
    {
        public string BaseUrl { get; set; } = string.Empty;
    }

    public class AppSettings
    {
        public ApiSettings ApiSetting { get; set; } = new();
    }
}
