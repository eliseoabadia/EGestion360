using Microsoft.AspNetCore.Components.Forms;

namespace EG.Web.Helpers
{
    public class UploadFiles
    {
        public static async Task<string> UploadImagesAsync(IBrowserFile file)
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
                return $"Error al cargar el archivo: {ex.Message}";
            }
        }
    }
}