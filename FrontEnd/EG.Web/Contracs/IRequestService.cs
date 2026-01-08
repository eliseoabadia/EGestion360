namespace EG.Web.Contracs
{
    public interface IRequestService
    {
        Task<T> GetAsync<T>(string url);

        Task<T> GetByIdAsync<T>(string url, int id);

        Task<HttpResponseMessage> PostAsync<T>(string url, T model);

        Task<object> DeleteAsync(string url);

        Task<HttpResponseMessage> PutAsync<T>(string url, T model);

        Task<TResponse> PostAndReadAsync<TResponse, TRequest>(string url, TRequest model);

        Task<HttpResponseMessage> PutAsync(string url);
    }
}