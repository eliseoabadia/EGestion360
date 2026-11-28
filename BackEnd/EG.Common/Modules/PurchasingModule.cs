namespace EG.Common.Modules;

public static class PurchasingModule
{
    public const string RequestersAction = "Solicitantes";
    public const string RequestersEndpoint = "api/Requisicion/" + RequestersAction;
    public const string CommitmentGuidance = "La orden requiere suficiencia y compromiso presupuestal autorizados. El contrato jurídico es un trámite distinto según el procedimiento.";
    public const string AuthorizedOrderRequirements = "Suficiencia y compromiso presupuestal autorizados para el proveedor seleccionado.";
}
