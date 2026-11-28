using EG.Common;

namespace EG.UnidTest.Business;

public sealed class StoredProcedureMessageTests
{
    [Theory]
    [InlineData("PortalDev\nError: El presupuesto es insuficiente.\nLinea: 98", "El presupuesto es insuficiente.")]
    [InlineData("Error: La solicitud está autorizada. Linea: 10", "La solicitud está autorizada.")]
    [InlineData("La solicitud está autorizada.", "La solicitud está autorizada.")]
    public void BusinessErrorsRemainUsefulWithoutSqlEnvelope(string source, string expected) =>
        Assert.Equal(expected, UserFacingMessageSanitizer.FromStoredProcedure(source));

    [Theory]
    [InlineData("PortalDev\nError: Invalid column name 'Secret'.\nLinea: 98")]
    [InlineData("String or binary data would be truncated in table 'GestionEmpresarial.ALMA.SolicitudSalida'.")]
    [InlineData("Error inesperado Linea: 42")]
    public void TechnicalDetailsNeverReachUser(string source) =>
        Assert.Equal(UserFacingMessages.UnexpectedError, UserFacingMessageSanitizer.FromStoredProcedure(source));
}
