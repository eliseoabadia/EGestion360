namespace EG.Domain.Platform.Settings
{
    public class DocumentRagSettings
    {
        public int MaxFileSizeMB { get; set; } = 50;
        public int MaxSessionDocuments { get; set; } = 12;
        public int MaxSessionTotalMB { get; set; } = 150;
        public int MaxGlobalMemoryMB { get; set; } = 512;
        public int MaxSessionsPerUser { get; set; } = 4;
        public int SessionTtlMinutes { get; set; } = 120;
        public int CleanupIntervalSeconds { get; set; } = 300;
        public int MaxHistoryItems { get; set; } = 50;
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
        public string? TessdataPrefixPath { get; set; }
        public string TesseractLanguage { get; set; } = "spa+eng";
        public string TempPath { get; set; } = "RagTemp";
        public DocumentRagEmbeddingsSettings Embeddings { get; set; } = new();
    }

    public class DocumentRagEmbeddingsSettings
    {
        public bool Enabled { get; set; }
        public string? Endpoint { get; set; }
        public string? ApiKey { get; set; }
        public string Model { get; set; } = "text-embedding-3-small";
        public int BatchSize { get; set; } = 32;
        public double LexicalWeight { get; set; } = 0.45d;
        public double SemanticWeight { get; set; } = 0.55d;
    }
}
