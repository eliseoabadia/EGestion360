using System.Net.Http.Headers;
using System.Text;
using System.Text.Json;
using EG.Web.Models;
using EG.Common;
using Microsoft.AspNetCore.Components.Forms;
using Microsoft.Extensions.Logging;

namespace EG.Web.Services.Shared
{
    public static class MultipartApiHelper
    {
        private const string DefaultContentType = "application/octet-stream";

        public static void AddString(MultipartFormDataContent form, string name, string? value)
        {
            if (!string.IsNullOrWhiteSpace(value))
                form.Add(new StringContent(value, Encoding.UTF8), name);
        }

        public static void AddFile(MultipartFormDataContent form, string name, IBrowserFile file, long maxFileSize)
        {
            var fileContent = new StreamContent(file.OpenReadStream(maxFileSize));
            fileContent.Headers.ContentType = new MediaTypeHeaderValue(string.IsNullOrWhiteSpace(file.ContentType)
                ? DefaultContentType
                : file.ContentType);

            form.Add(fileContent, name, file.Name);
        }

        public static async Task<ApiResponse<TResponse>> SendAsync<TResponse>(
            HttpClient httpClient,
            HttpRequestMessage request,
            JsonSerializerOptions jsonOptions,
            ILogger logger)
            where TResponse : class
        {
            var response = await httpClient.SendAsync(request);
            var body = await response.Content.ReadAsStringAsync();
            var result = JsonSerializer.Deserialize<ApiResponse<TResponse>>(body, jsonOptions)
                ?? new ApiResponse<TResponse>();

            if (!response.IsSuccessStatusCode)
            {
                logger.LogWarning(
                    "Carga multipart rechazada. Method={Method}; Uri={Uri}; Status={StatusCode}; Response={Response}",
                    request.Method,
                    request.RequestUri,
                    (int)response.StatusCode,
                    body.Length <= 2000 ? body : $"{body[..2000]}...");

                result.Success = false;
                var fallback = response.StatusCode switch
                {
                    System.Net.HttpStatusCode.BadRequest =>
                        "El archivo o la informacion enviada no son validos. Revisa los datos e intenta nuevamente.",
                    System.Net.HttpStatusCode.Unauthorized =>
                        "Tu sesion ya no esta disponible. Inicia sesion nuevamente.",
                    System.Net.HttpStatusCode.Forbidden =>
                        "No tienes permisos para realizar esta operacion.",
                    System.Net.HttpStatusCode.RequestEntityTooLarge =>
                        "El archivo excede el tamano permitido.",
                    _ => UserFacingMessages.OperationFailed("cargar el archivo")
                };

                result.Message = (int)response.StatusCode >= 500
                    ? UserFacingMessages.UnexpectedError
                    : UserFacingMessageSanitizer.SafeOrFallback(result.Message, fallback);
            }

            return result;
        }

        public static ApiResponse<TResponse> Failure<TResponse>(Exception ex, ILogger logger)
            where TResponse : class
        {
            logger.LogError(ex, "No se pudo completar una carga multipart.");
            return new()
            {
                Success = false,
                Message = UserFacingMessages.OperationFailed("cargar el archivo")
            };
        }
    }
}
