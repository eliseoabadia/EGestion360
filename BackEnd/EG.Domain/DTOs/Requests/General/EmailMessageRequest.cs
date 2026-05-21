namespace EG.Domain.DTOs.Requests.General
{
    public class EmailMessageRequest
    {
        public List<string> To { get; set; } = new();
        public List<string> Cc { get; set; } = new();
        public List<string> Bcc { get; set; } = new();
        public string Subject { get; set; } = string.Empty;
        public string Body { get; set; } = string.Empty;
        public bool IsHtml { get; set; } = true;
        public List<EmailAttachmentRequest> Attachments { get; set; } = new();
    }

    public class EmailAttachmentRequest
    {
        public string FileName { get; set; } = string.Empty;
        public string ContentBase64 { get; set; } = string.Empty;
        public string ContentType { get; set; } = "application/octet-stream";
    }
}
