namespace EG.Builder.Templates;
public static class TemplateService
{
    public static string Controller =
@"using EG.Common.Helper;
using EG.WebApp.Contracs.Configuration;
using EG.WebApp.Models.Configuration;
using Microsoft.AspNetCore.Components.Forms;
using Microsoft.JSInterop;
using MudBlazor;
using System.Net.Http.Headers;
using System.Text;
using System.Text.Json;


namespace EG.WebApp.Services
{
    public class test
    {
        private readonly Logger.Log4NetLogger _logger = new Logger.Log4NetLogger(typeof(ProfileService));
        private readonly IJSRuntime _jsRuntime;

        private static string _baseUrl;
        public bool IsAuthenticated { get; private set; } = false;

        public ProfileService(IJSRuntime jsRuntime)
        {

            var builder = new ConfigurationBuilder().SetBasePath(Directory.GetCurrentDirectory()).AddJsonFile(""appsettings.json"").Build();

            _baseUrl = builder.GetSection(""ApiSetting:baseUrl"").Value;

            this._jsRuntime = jsRuntime;
        }

        private bool IsClientSide()
        {
            try
            {
                var _ = _jsRuntime.GetType();
                return true;
            }
            catch
            {
                return false;
            }
        }

        public async Task<IList<TABLENAMEResponse>> GetAllTABLENAMEAsync()
        {
            IList<TABLENAMEResponse> resultado = new List<TABLENAMEResponse>();
            using HttpClient client = new HttpClient();
            try
            {
                if (!IsClientSide())
                {
                    return new List<TABLENAMEResponse>();
                }

                // Cargar estado desde localStorage al iniciar
                var Token = await _jsRuntime.InvokeAsync<string>(""localStoraEG.getItem"", ""authToken"");
                var payRollId = await _jsRuntime.InvokeAsync<string>(""localStoraEG.getItem"", ""userId"");

                if (string.IsNullOrEmpty(Token) || string.IsNullOrEmpty(payRollId))
                {
                    await _jsRuntime.InvokeVoidAsync(""localStoraEG.setItem"", ""authToken"", string.Empty);
                    await _jsRuntime.InvokeVoidAsync(""localStoraEG.setItem"", ""userId"", string.Empty);
                    return resultado;
                }

                // Agrega el token Bearer al encabezado
                client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue(""Bearer"", Token);

                // Cuerpo de la solicitud (si estás usando POST)
                int userId = int.Parse(payRollId);
                var json = System.Text.Json.JsonSerializer.Serialize(new { userId });
                var content = new StringContent(json, Encoding.UTF8, ""application/json"");

                // Enviar la solicitud POST
                HttpResponseMessage response = await client.GetAsync($""{_baseUrl}api/TABLENAME/"");

                if (response.IsSuccessStatusCode)
                {
                    string responseBody = await response.Content.ReadAsStringAsync();

                    // Deserializamos directamente a una lista
                    resultado = System.Text.Json.JsonSerializer.Deserialize<IList<TABLENAMEResponse>>(responseBody, new JsonSerializerOptions
                    {
                        PropertyNameCaseInsensitive = true
                    });



                    return resultado;

                }
                else
                {
                    Console.WriteLine($""Error de autenticación: {response.StatusCode}"");
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine($""Error de autenticación: {ex}"");
            }

            return resultado;

        }

        public async Task<(IList<TABLENAMEResponse> Item, int Res)> GetAllTABLENAMEsPaginadoAsync(int page = 1,
                    int pageSize = 10,
                    string filtro = """",
                    string sortLabel = """",
                    SortDirection _sortDirection = SortDirection.Ascending)
        {
            IList<TABLENAMEResponse> resultado = new List<TABLENAMEResponse>();
            using HttpClient client = new HttpClient();
            try
            {

                if (!IsClientSide())
                {
                    return (new List<TABLENAMEResponse>(), 0);
                }

                // Cargar estado desde localStorage al iniciar
                var Token = await _jsRuntime.InvokeAsync<string>(""localStoraEG.getItem"", ""authToken"");
                var payRollId = await _jsRuntime.InvokeAsync<string>(""localStoraEG.getItem"", ""userId"");

                if (string.IsNullOrEmpty(Token) || string.IsNullOrEmpty(payRollId))
                {
                    await _jsRuntime.InvokeVoidAsync(""localStoraEG.setItem"", ""authToken"", string.Empty);
                    await _jsRuntime.InvokeVoidAsync(""localStoraEG.setItem"", ""userId"", string.Empty);
                    return (new List<TABLENAMEResponse>(), 0);
                }

                // Agrega el token Bearer al encabezado
                client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue(""Bearer"", Token);

                // Cuerpo de la solicitud (si estás usando POST)
                int userId = int.Parse(payRollId);


                string sortDirection = _sortDirection.ToString().Contains(""Descending"") ? ""Descending"" : ""Ascending"";
                var json = System.Text.Json.JsonSerializer.Serialize(new { pageSize, filtro, sortLabel, sortDirection });
                var content = new StringContent(json, Encoding.UTF8, ""application/json"");

                // Enviar la solicitud POST
                HttpResponseMessage response = await client.GetAsync($""{_baseUrl}api/TABLENAME/GetAllTABLENAMEsPaginadoAsync?page={page}&pageSize={pageSize}&filtro={filtro}&sortLabel={sortLabel}&sortDirection={sortDirection}"");

                if (response.IsSuccessStatusCode)
                {
                    string responseBody = await response.Content.ReadAsStringAsync();

                    // Deserializamos directamente a una lista
                    var _resultado = System.Text.Json.JsonSerializer.Deserialize<PagedResult<TABLENAMEResponse>>(responseBody, new JsonSerializerOptions
                    {
                        PropertyNameCaseInsensitive = true
                    });

                    resultado = _resultado.Items;

                    return (resultado, _resultado.TotalCount);

                }
                else
                {
                    Console.WriteLine($""Error de autenticación: {response.StatusCode}"");
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine($""Error de autenticación: {ex}"");
            }

            return (new List<TABLENAMEResponse>(), 0);

        }


        public async Task<TABLENAMEResponse> GetTABLENAMEByIdAsync(int itemId)
        {
            TABLENAMEResponse resultado = new TABLENAMEResponse();
            using HttpClient client = new HttpClient();
            try
            {
                if (!IsClientSide())
                {
                    return new TABLENAMEResponse();
                }
                // Cargar estado desde localStorage al iniciar
                var Token = await _jsRuntime.InvokeAsync<string>(""localStoraEG.getItem"", ""authToken"");
                var payRollId = await _jsRuntime.InvokeAsync<string>(""localStoraEG.getItem"", ""userId"");

                if (string.IsNullOrEmpty(Token) || string.IsNullOrEmpty(payRollId))
                {
                    await _jsRuntime.InvokeVoidAsync(""localStoraEG.setItem"", ""authToken"", string.Empty);
                    await _jsRuntime.InvokeVoidAsync(""localStoraEG.setItem"", ""userId"", string.Empty);
                    return resultado;
                }

                // Agrega el token Bearer al encabezado
                client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue(""Bearer"", Token);

                // Cuerpo de la solicitud (si estás usando POST)
                var json = System.Text.Json.JsonSerializer.Serialize(new { itemId });
                var content = new StringContent(json, Encoding.UTF8, ""application/json"");

                // Enviar la solicitud POST
                HttpResponseMessage response = await client.GetAsync($""{_baseUrl}api/GetTABLENAMEByIdAsync/{itemId}"");

                if (response.IsSuccessStatusCode)
                {
                    string responseBody = await response.Content.ReadAsStringAsync();

                    resultado = System.Text.Json.JsonSerializer.Deserialize<TABLENAMEResponse>(responseBody, new JsonSerializerOptions
                    {
                        PropertyNameCaseInsensitive = true
                    });
                    return resultado;
                }
                else
                {
                    Console.WriteLine($""Error de autenticación: {response.StatusCode}"");
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine($""Error de autenticación: {ex}"");
            }
            return resultado;
        }


        public async Task<(bool resultado, string mensaje)> CreateTABLENAME(TABLENAMEResponse item)
        {
            bool resultado = false;
            string mensaje = string.Empty;

            try
            {
                if (!IsClientSide())
                {
                    return (resultado, mensaje);
                }
                var token = await _jsRuntime.InvokeAsync<string>(""localStoraEG.getItem"", ""authToken"");
                var payRollId = await _jsRuntime.InvokeAsync<string>(""localStoraEG.getItem"", ""userId"");

                if (string.IsNullOrEmpty(token) || string.IsNullOrEmpty(payRollId))
                {
                    await _jsRuntime.InvokeVoidAsync(""localStoraEG.setItem"", ""authToken"", string.Empty);
                    await _jsRuntime.InvokeVoidAsync(""localStoraEG.setItem"", ""userId"", string.Empty);
                    mensaje = ""Token o ID de usuario no disponible."";
                    return (false, mensaje);
                }

                using var client = new HttpClient();
                client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue(""Bearer"", token);

                string jsonString = JsonSerializer.Serialize(item);
                var content = new StringContent(jsonString, Encoding.UTF8, ""application/json"");

                var response = await client.PostAsync($""{_baseUrl}api/TABLENAME/CreateTABLENAME/"", content);

                if (response.IsSuccessStatusCode)
                {
                    var responseBody = await response.Content.ReadAsStringAsync();
                    resultado = JsonSerializer.Deserialize<bool>(responseBody, new JsonSerializerOptions { PropertyNameCaseInsensitive = true });

                    mensaje = ""TABLENAME Creado correctamente"";
                }
                else
                {
                    mensaje = $""Error: {response.StatusCode} - {response.ReasonPhrase}"";
                }
            }
            catch (Exception ex)
            {
                mensaje = $""Excepción: {ex.Message}"";
            }

            return (resultado, mensaje);
        }

        public async Task<(bool resultado, string mensaje)> SetTABLENAME(int userId, TABLENAMEResponse item)
        {
            bool resultado = false;
            string mensaje = string.Empty;

            try
            {
                if (!IsClientSide())
                {
                    return (resultado, mensaje);
                }
                var token = await _jsRuntime.InvokeAsync<string>(""localStoraEG.getItem"", ""authToken"");
                var payRollId = await _jsRuntime.InvokeAsync<string>(""localStoraEG.getItem"", ""userId"");

                if (string.IsNullOrEmpty(token) || string.IsNullOrEmpty(payRollId))
                {
                    await _jsRuntime.InvokeVoidAsync(""localStoraEG.setItem"", ""authToken"", string.Empty);
                    await _jsRuntime.InvokeVoidAsync(""localStoraEG.setItem"", ""userId"", string.Empty);
                    mensaje = ""Token o ID de usuario no disponible."";
                    return (false, mensaje);
                }

                using var client = new HttpClient();
                client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue(""Bearer"", token);

                string jsonString = JsonSerializer.Serialize(item);
                var content = new StringContent(jsonString, Encoding.UTF8, ""application/json"");

                var response = await client.PostAsync($""{_baseUrl}api/TABLENAME/SetTABLENAME/{userId}/"", content);

                if (response.IsSuccessStatusCode)
                {
                    var responseBody = await response.Content.ReadAsStringAsync();
                    resultado = JsonSerializer.Deserialize<bool>(responseBody, new JsonSerializerOptions { PropertyNameCaseInsensitive = true });

                    mensaje = ""TABLENAME actualizado correctamente"";
                }
                else
                {
                    mensaje = $""Error: {response.StatusCode} - {response.ReasonPhrase}"";
                }
            }
            catch (Exception ex)
            {
                mensaje = $""Excepción: {ex.Message}"";
            }

            return (resultado, mensaje);
        }

        public async Task<(bool resultado, string mensaje)> DeleteTABLENAME(int itemId)
        {
            bool resultado = false;
            string mensaje = string.Empty;

            try
            {
                if (!IsClientSide())
                {
                    return (resultado, mensaje);
                }
                var token = await _jsRuntime.InvokeAsync<string>(""localStoraEG.getItem"", ""authToken"");
                var payRollId = await _jsRuntime.InvokeAsync<string>(""localStoraEG.getItem"", ""userId"");

                if (string.IsNullOrEmpty(token) || string.IsNullOrEmpty(payRollId))
                {
                    await _jsRuntime.InvokeVoidAsync(""localStoraEG.setItem"", ""authToken"", string.Empty);
                    await _jsRuntime.InvokeVoidAsync(""localStoraEG.setItem"", ""userId"", string.Empty);
                    mensaje = ""Token o ID de usuario no disponible."";
                    return (false, mensaje);
                }

                using var client = new HttpClient();
                client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue(""Bearer"", token);

                string jsonString = JsonSerializer.Serialize(itemId);
                var content = new StringContent(jsonString, Encoding.UTF8, ""application/json"");

                var response = await client.PostAsync($""{_baseUrl}api/TABLENAME/DeleteTABLENAME/{itemId}/"", content);

                if (response.IsSuccessStatusCode)
                {
                    var responseBody = await response.Content.ReadAsStringAsync();
                    resultado = JsonSerializer.Deserialize<bool>(responseBody, new JsonSerializerOptions { PropertyNameCaseInsensitive = true });

                    mensaje = ""TABLENAME dado de baja correctamente"";
                }
                else
                {
                    mensaje = $""Error: {response.StatusCode} - {response.ReasonPhrase}"";
                }
            }
            catch (Exception ex)
            {
                mensaje = $""Excepción: {ex.Message}"";
            }

            return (resultado, mensaje);
        }





    }
}


";
}

