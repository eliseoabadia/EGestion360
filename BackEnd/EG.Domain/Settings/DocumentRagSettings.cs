namespace EG.Domain.Settings
{
    public class DocumentRagSettings
    {
        public int MaxFileSizeMB { get; set; } = 50;
        public int MaxSessionDocuments { get; set; } = 12;
        public int MaxSessionTotalMB { get; set; } = 150;
        public int SessionTtlMinutes { get; set; } = 120;
        public int ChunkSize { get; set; } = 1400;
        public int ChunkOverlap { get; set; } = 180;
        public int TopK { get; set; } = 6;
        public double MinScore { get; set; } = 0.08d;
        public string[] AllowedExtensions { get; set; } =
        [
            ".pdf", ".doc", ".docx", ".xls", ".xlsx",
            ".txt", ".csv", ".md",
            ".png", ".jpg", ".jpeg", ".webp", ".tif", ".tiff", ".bmp"
        ];
        public string? TesseractExePath { get; set; }
        public string TesseractLanguage { get; set; } = "spa+eng";
        public string TempPath { get; set; } = "RagTemp";
    }
}
