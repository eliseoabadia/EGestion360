namespace EG.Application.CommonModel
{
    public class JwtSettings
    {
        public bool ValidateIssuerSigningKey { get; set; }
        public required string IssuerSigningKey { get; set; }
        public bool ValidateIssuer { get; set; } = true;
        public string? ValidIssuer { get; set; }
        public bool ValidateAudience { get; set; } = true;
        public string? ValidAudience { get; set; }
        public bool RequireExpirationTime { get; set; }
        public bool ValidateLifetime { get; set; } = true;
        public int ExpiryMinutes { get; set; }
    }
}