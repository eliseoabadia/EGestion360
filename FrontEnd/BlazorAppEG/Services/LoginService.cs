using System.Net.Http.Json;
using System.Text;
using System.Text.Json;

namespace BlazorAppEG.Services
{
    public class LoginService
    {
        private readonly HttpClient _httpClient;

        public LoginService(HttpClient httpClient)
        {
            _httpClient = httpClient;
        }

        public async Task<string> LoginAsync(string email, string password)
        {
            try
            {
                var jsonParams = new { email = email, password = password };
                var content = new StringContent(JsonSerializer.Serialize(jsonParams), Encoding.UTF8, "application/json");

                Console.WriteLine($"Intentando login en {_httpClient.BaseAddress}api/Auth/Login");
                
                var response = await _httpClient.PostAsync("api/Auth/Login", content);

                if (response.IsSuccessStatusCode)
                {
                    var responseBody = await response.Content.ReadAsStringAsync();
                    Console.WriteLine("Login exitoso: " + responseBody);
                    return "Exito: " + responseBody;
                }
                else
                {
                    var responseBody = await response.Content.ReadAsStringAsync();
                    Console.WriteLine($"Error HTTP {response.StatusCode}: {responseBody}");
                    return $"Error {response.StatusCode}: {responseBody}";
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Excepción: {ex.Message}");
                return $"Excepción: {ex.Message}";
            }
        }
    }
}
