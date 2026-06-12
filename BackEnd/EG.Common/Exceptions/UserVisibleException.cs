namespace EG.Common.Exceptions;

public class UserVisibleException : Exception
{
    public UserVisibleException(string message, string code = "VALIDATION")
        : base(message)
    {
        UserMessage = string.IsNullOrWhiteSpace(message)
            ? UserFacingMessages.UnexpectedError
            : message;
        Code = string.IsNullOrWhiteSpace(code) ? "VALIDATION" : code;
    }

    public string UserMessage { get; }
    public string Code { get; }
}
