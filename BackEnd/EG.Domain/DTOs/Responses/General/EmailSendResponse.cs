namespace EG.Domain.DTOs.Responses.General
{
    public class EmailSendResponse
    {
        public bool Sent { get; set; }
        public List<string> Recipients { get; set; } = new();
        public DateTime SentAt { get; set; }
    }
}
