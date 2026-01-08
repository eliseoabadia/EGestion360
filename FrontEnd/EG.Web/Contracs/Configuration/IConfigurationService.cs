namespace EG.Web.Contracs.Configuration
{
    public interface IConfigurationService
    {
        Task<T> GetAsync<T>(string key, T defaultValue = default);
        Task<string> GetBaseUrlAsync();
    }
}
