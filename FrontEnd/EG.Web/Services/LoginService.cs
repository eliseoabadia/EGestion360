using EG.Common.Helper;
using EG.Web.Contracs;
using EG.Web.Models;
using Microsoft.AspNetCore.Components;
using Microsoft.Extensions.Configuration;
using Microsoft.JSInterop;
using System.Text;
using System.Text.Json;
using Const = EG.Common.Constants;

namespace EG.Web.Services
{
    public class LoginService : ILoginService
    {
        private readonly ApplicationInstance _application;
        private readonly IJSRuntime _jsRuntime;
        private readonly HttpClient _httpClient;
        private readonly string _baseUrl;
        public bool IsAuthenticated { get; private set; } = false;

        public LoginService(HttpClient httpClient, IJSRuntime jsRuntime, ApplicationInstance application)
        {
            _httpClient = httpClient;
            _jsRuntime = jsRuntime;
            _application = application;
            _baseUrl = httpClient.BaseAddress?.ToString() ?? string.Empty;
        }

        public async Task<UserResult> LoginAsync(string usuario, string password)
        {
            UserResult resultado = new UserResult();

            var jsonParams = new
            {
                email = usuario,
                password = password
            };

            string jsonString = JsonSerializer.Serialize(jsonParams);

            using HttpClient client = new HttpClient();
            var content = new StringContent(jsonString, Encoding.UTF8, "application/json");
            HttpResponseMessage response = await client.PostAsync($"{_baseUrl}api/Auth/Login/", content);

            if (response.IsSuccessStatusCode)
            {
                string responseBody = await response.Content.ReadAsStringAsync();

                resultado = JsonSerializer.Deserialize<UserResult>(responseBody, new JsonSerializerOptions { PropertyNameCaseInsensitive = true }) ?? new UserResult();
                if (!string.IsNullOrWhiteSpace(resultado.PayrollId))
                {
                    IsAuthenticated = true;
                    _application.SetVariable(Const.KEY_USERID, resultado.PkIdUsuario);
                    _application.SetVariable(Const.KEY_TOKEN, resultado.AccessToken);
                }
            }
            else
            {
                resultado.PayrollId = "0";
            }

            return resultado;
        }

        public Task Logout()
        {
            throw new NotImplementedException();
        }
    }
}