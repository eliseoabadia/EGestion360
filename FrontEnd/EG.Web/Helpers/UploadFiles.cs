using Microsoft.AspNetCore.Components.Forms;

using EG.Common;
using Microsoft.Extensions.Logging;

namespace EG.Web.Helpers
{
    public class UploadFiles
    {
        public static async Task<string> UploadImagesAsync(IBrowserFile file, ILogger logger)
        {
            try
            {
                using var memoryStream = new MemoryStream();
                await file.OpenReadStream().CopyToAsync(memoryStream);
                var base64String = Convert.ToBase64String(memoryStream.ToArray());
                var imageUrl = $"data:{file.ContentType};base64,{base64String}";
                return imageUrl;
            }
            catch (Exception ex)
            {
                logger.LogError(ex, "No se pudo convertir el archivo {FileName} a una imagen local.", file.Name);
                return UserFacingMessages.OperationFailed("cargar el archivo");
            }
        }
    }
}
