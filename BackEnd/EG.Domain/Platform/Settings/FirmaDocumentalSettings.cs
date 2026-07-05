namespace EG.Domain.Platform.Settings
{
    public class FirmaDocumentalSettings
    {
        public string VaultPath { get; set; } = "FirmaDocumental";
        public string VaultKey { get; set; } = string.Empty;
        public int MaxCertificateSizeMB { get; set; } = 2;
        public string[] AllowedCertificateExtensions { get; set; } = [".pfx", ".p12"];
        public string[] EnabledProviders { get; set; } = ["SAT_PFX", "INTERNA"];
    }
}
