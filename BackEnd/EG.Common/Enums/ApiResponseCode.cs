namespace EG.Common.Enums
{
    public enum ApiResponseCode
    {
        Success,
        Error,
        InvalidData,
        InvalidModel,
        MissingRequiredFields,
        Duplicated,
        NotFound,
        Unauthorized,
        Forbidden,
        InvalidId
    }

    public static class ApiResponseCodeExtensions
    {
        public static string ToCode(this ApiResponseCode code) => code.ToString();
    }
}
