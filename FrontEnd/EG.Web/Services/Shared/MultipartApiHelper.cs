using System.Net.Http.Headers;
using System.Text;
using System.Text.Json;
using EG.Web.Models;
using Microsoft.AspNetCore.Components.Forms;

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
            JsonSerializerOptions jsonOptions)
            where TResponse : class
        {
            var response = await httpClient.SendAsync(request);
            var body = await response.Content.ReadAsStringAsync();
            var result = JsonSerializer.Deserialize<ApiResponse<TResponse>>(body, jsonOptions)
                ?? new ApiResponse<TResponse>();

            if (!response.IsSuccessStatusCode)
            {
                result.Success = false;
                if (string.IsNullOrWhiteSpace(result.Message))
                    result.Message = body;
            }

            return result;
        }

        public static ApiResponse<TResponse> Failure<TResponse>(Exception ex)
            where TResponse : class
            => new()
            {
                Success = false,
                Message = ex.Message
            };
    }
}
