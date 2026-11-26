using EG.Application.Services.PresupuestoModificado;
using EG.Common.GenericModel;
using EG.Common.Exceptions;
using EG.Domain.DTOs.Responses.PresupuestoModificado;
using EG.UnidTest.Support;

namespace EG.UnidTest.Application;

public sealed class IncomeCaptureRulesTests
{
    [Fact]
    public void CreateCannotSubmitApprovalOrWorkflowDates()
    {
        var request = new IngreAdecuacionResponse
        {
            Autorizado = true, FkidAccionAdecuacionMasterPres = 3,
            FechaSolicitud = DateTime.Today, FechaAutorizacion = DateTime.Today
        };
        IncomeCaptureRules.PrepareCreate(request);
        Assert.False(request.Autorizado);
        Assert.Equal(1, request.FkidAccionAdecuacionMasterPres);
        Assert.Null(request.FechaSolicitud);
        Assert.Null(request.FechaAutorizacion);
    }

    [Fact]
    public void OrdinaryEditPreservesWorkflowAndCreationMetadata()
    {
        var current = new IngreAdecuacionResponse
        {
            PkidIngreAdecuacion = 1, Clave = "Existing", FkidAnioSis = 7, FkidPolizaConta = 12,
            FkidAccionAdecuacionMasterPres = 4, FechaSolicitud = new(2026, 1, 1),
            UsuarioCreacion = 9, FechaCreacion = new(2025, 12, 1), Activo = true
        };
        var request = new IngreAdecuacionResponse
        {
            Autorizado = true, FkidAccionAdecuacionMasterPres = 3, FechaAutorizacion = DateTime.Today,
            UsuarioCreacion = 100, Activo = false, Justificacion = "Nueva justificación"
        };
        IncomeCaptureRules.PreserveServerState(request, current);
        Assert.False(request.Autorizado);
        Assert.Equal(4, request.FkidAccionAdecuacionMasterPres);
        Assert.Equal(current.FechaSolicitud, request.FechaSolicitud);
        Assert.Null(request.FechaAutorizacion);
        Assert.Equal(9, request.UsuarioCreacion);
        Assert.Equal(current.FechaCreacion, request.FechaCreacion);
        Assert.Equal(7, request.FkidAnioSis);
        Assert.Equal(12, request.FkidPolizaConta);
        Assert.Equal("Existing", request.Clave);
        Assert.True(request.Activo);
        Assert.Equal("Nueva justificación", request.Justificacion);
    }

    [Theory]
    [InlineData(true, 1)]
    [InlineData(false, 2)]
    public async Task LockedHeaderRejectsOrdinaryUpdateBeforePersistence(bool approved, int action)
    {
        var service = new Header(new() { Autorizado = approved, FkidAccionAdecuacionMasterPres = action });
        var result = await service.UpdateAsync(1, new(), 7);
        Assert.False(result.Success);
        Assert.Equal("VALIDATION", result.Code);
    }

    [Fact]
    public async Task ChangingExerciseIsRejectedBeforePersistence()
    {
        var service = new Header(new() { FkidAnioSis = 1 });
        var result = await service.UpdateAsync(1, new() { FkidAnioSis = 2 }, 7);
        Assert.False(result.Success);
        Assert.Equal("VALIDATION", result.Code);
    }

    [Fact]
    public async Task DetailCannotBeMovedToAnUnlockedParent()
    {
        var service = new Detail();
        var result = await service.UpdateAsync(1, new() { FkidIngreAdecuacionPres = 2 }, 7);
        Assert.False(result.Success);
        Assert.Equal("VALIDATION", result.Code);
        Assert.Contains("otra adecuacion", result.Message);
    }

    // Persistence is intentionally absent: these rejection paths must finish before any DB call.
    [Fact]
    public async Task UpdateGuardRechecksWorkflowStateBeforeProcedureExecution()
    {
        var current = new IngreAdecuacionResponse { FkidAnioSis = 1 };
        var service = new Header(current);
        var request = new IngreAdecuacionResponse { FkidAnioSis = 1, Fecha = new(2026, 1, 1) };
        await service.ValidateBeforeProcedureAsync(request);
        current.FkidAccionAdecuacionMasterPres = 2;
        await Assert.ThrowsAsync<UserVisibleException>(() => service.ValidateBeforeProcedureAsync(request));
    }

    [Fact]
    public async Task DetailUpdateGuardRejectsReparentingBeforeProcedureExecution()
    {
        await Assert.ThrowsAsync<UserVisibleException>(() => new Detail().ValidateBeforeProcedureAsync(
            new() { FkidIngreAdecuacionPres = 2 }));
    }

    private sealed class Header(IngreAdecuacionResponse current)
        : IngreAdecuacionAppService(null!, null!, null!, new FixedUserContext(7, 3))
    {
        public Task ValidateBeforeProcedureAsync(IngreAdecuacionResponse response) => ValidateUpdateAsync(1, response, default);
        public override Task<PagedResult<IngreAdecuacionResponse>> GetByIdAsync(int id) =>
            Task.FromResult(new PagedResult<IngreAdecuacionResponse> { Success = true, Data = current });
    }

    private sealed class Detail() : IngreAdecuacionDetalleAppService(null!, null!, null!, new FixedUserContext(7, 3))
    {
        public Task ValidateBeforeProcedureAsync(IngreAdecuacionDetalleResponse response) => ValidateUpdateAsync(1, response, default);
        public override Task<PagedResult<IngreAdecuacionDetalleResponse>> GetByIdAsync(int id) =>
            Task.FromResult(new PagedResult<IngreAdecuacionDetalleResponse>
            {
                Success = true, Data = new() { FkidIngreAdecuacionPres = 1 }
            });
    }
}
