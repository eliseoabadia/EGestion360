namespace EG.Domain.Platform.Settings
{
    public class DocumentStorageSettings
    {
        public string Mode { get; set; } = "DATABASE";
        public string BasePath { get; set; } = "Documentos";
        public int MaxFileSizeMB { get; set; } = 10;
        public string[] AllowedExtensions { get; set; } = [".pdf", ".png", ".jpg", ".jpeg", ".webp"];
    }
}
