namespace EG.Common;

public static class UserFacingMessages
{
    public const string UnexpectedError =
        "No fue posible completar la operacion. Intenta nuevamente. Si el problema continua, el departamento de TI revisara el detalle registrado.";

    public static string OperationFailed(string operation) =>
        $"No fue posible {operation}. Intenta nuevamente. Si el problema continua, el departamento de TI revisara el detalle registrado.";
}
