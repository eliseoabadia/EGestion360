using EG.Business.Interfaces;
using EG.Common;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.General;
using EG.Domain.DTOs.Responses.General;

namespace EG.Business.Services.General;

public static class WorkflowEmailDelivery
{
    public static async Task<PagedResult<EmailSendResponse>> SendClaimedAsync(
        IEmailOperations emailService, IEnvioWorkflowOperations workflow, string process,
        long entityId, Guid operationToken, EmailMessageRequest message)
    {
        if (operationToken == Guid.Empty)
            throw new ArgumentException("El envío debe conservar su identificador de operación.", nameof(operationToken));

        var result = await emailService.SendAsync(message);
        if (!result.Success)
        {
            // Sólo VALIDATION garantiza que el proveedor no recibió el mensaje.
            if (result.Code == "VALIDATION")
            {
                await workflow.CancelAsync(process, entityId, operationToken);
                return result;
            }
            return new()
            {
                Success = false,
                Code = ApplicationText.Workflow.DeliveryUnconfirmedCode,
                Message = ApplicationText.Workflow.DeliveryUnconfirmed
            };
        }

        // Un fallo posterior a la entrega conserva PROCESANDO: liberar el token
        // aquí permitiría duplicar un correo que el proveedor ya pudo aceptar.
        await workflow.CompleteAsync(process, entityId, operationToken);
        return result;
    }
}
