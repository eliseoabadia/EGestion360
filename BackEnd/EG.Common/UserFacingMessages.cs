namespace EG.Common;

public static class UserFacingMessages
{
    public const string UnexpectedError =
        "Ocurrio un error inesperado. El departamento de TI revisara el detalle registrado.";

    public static string OperationFailed(string operation) =>
        $"No fue posible {operation}. El departamento de TI revisara el detalle registrado.";
}
