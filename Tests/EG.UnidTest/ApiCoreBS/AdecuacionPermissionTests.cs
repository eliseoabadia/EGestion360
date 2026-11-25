using System.Security.Claims;
using EG.ApiCoreBS.Controllers.PresupuestoModificado;
using EG.Application.Interfaces.Adquisicion;
using EG.Application.Interfaces.PresupuestoModificado;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Responses.PresupuestoModificado;
using EG.UnidTest.Support;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;

namespace EG.UnidTest.ApiCoreBS;

public sealed class AdecuacionPermissionTests
{
    [Theory]
    [InlineData("view", false)]
    [InlineData("update", false)]
    [InlineData("new", true)]
    public async Task CreateRequiresTheNewAction(string allowed, bool succeeds)
    {
        var service = new Headers();
        var controller = Controller(service, $"Presupuesto_Modificado|Reducciones|{allowed}");

        var result = await controller.Create(new() { FkidTipoAdecuacionPres = 2 });

        Assert.Equal(succeeds ? 1 : 0, service.Writes);
        Assert.Equal(succeeds, result.Result is OkObjectResult);
    }

    [Theory]
    [InlineData(2, 3)]
    [InlineData(3, 2)]
    public async Task UpdateChecksBothPersistedAndSubmittedType(int stored, int submitted)
    {
        var service = new Headers { Current = new() { FkidTipoAdecuacionPres = stored } };
        var controller = Controller(service, "Presupuesto_Modificado|Ampliaciones|update");

        var result = await controller.Update(10, new() { FkidTipoAdecuacionPres = submitted });

        Assert.IsType<ForbidResult>(result.Result);
        Assert.Equal(0, service.Writes);
    }

    [Theory]
    [InlineData("delete", true)]
    [InlineData("update", false)]
    public async Task DeleteUsesTheSavedTypeAndDeleteAction(string action, bool succeeds)
    {
        var service = new Headers { Current = new() { FkidTipoAdecuacionPres = 2 } };
        var controller = Controller(service, $"Presupuesto_Modificado|Reducciones|{action}");

        var result = await controller.Delete(10);

        Assert.Equal(succeeds, result.Result is OkObjectResult);
        Assert.Equal(succeeds ? 1 : 0, service.Writes);
    }

    [Theory]
    [InlineData(2, true)]
    [InlineData(3, false)]
    [InlineData(0, false)]
    public async Task PagedQueryRequiresPermissionForItsExactType(int type, bool succeeds)
    {
        var service = new Headers();
        var controller = Controller(service, "Presupuesto_Modificado|Reducciones|view");
        var request = new PagedRequest { AdditionalFilters = new() { ["FkidTipoAdecuacionPres"] = type } };

        var result = await controller.GetAllPaginado(request);

        Assert.Equal(succeeds, result.Result is OkObjectResult);
        Assert.Equal(succeeds ? 1 : 0, service.Pages);
        if (succeeds)
            Assert.Same(request, service.LastRequest);
    }

    [Fact]
    public async Task UnfilteredQueryCannotExposeOtherTypes()
    {
        var service = new Headers();
        var controller = Controller(service, "Presupuesto_Modificado|Reducciones|view");
        Assert.IsType<ForbidResult>((await controller.GetAllPaginado(new())).Result);
        Assert.Equal(0, service.Pages);
    }

    [Fact]
    public async Task DetailCannotMoveToAParentWithoutUpdatePermission()
    {
        var service = new Crud<EgreAdecuacionDetalleResponse> { Current = new() { FkidEgreAdecuacionPres = 2 } };
        var controller = WithContext(new EgreAdecuacionDetalleController(
            service, new FixedUserContext(7, 3), new Permissions("Presupuesto_Modificado|Reducciones|update"), new Headers()));

        var result = await controller.Update(10, new() { FkidEgreAdecuacionPres = 3 });

        Assert.IsType<ForbidResult>(result.Result);
        Assert.Equal(0, service.Writes);
    }

    [Fact]
    public async Task DetailCannotUseMissingOrOutOfScopeParent()
    {
        var service = new Crud<EgreAdecuacionDetalleResponse>();
        var controller = WithContext(new EgreAdecuacionDetalleController(
            service, new FixedUserContext(7, 3), new Permissions("Presupuesto_Modificado|Reducciones|new"), new Headers()));

        var result = await controller.Create(new() { FkidEgreAdecuacionPres = 99 });

        Assert.IsType<ForbidResult>(result.Result);
        Assert.Equal(0, service.Writes);
    }

    [Fact]
    public async Task IncomeSendDoesNotAcceptOnlyAuthorizationPermission()
    {
        var service = new IncomeHeaders { Current = new() { FkidTipoAdecuacionPres = 2 } };
        var controller = WithContext(new IngreAdecuacionController(service, new FixedUserContext(7, 3),
            new Permissions("Presupuesto_Modificado|Reducciones|authorize")));

        Assert.IsType<ForbidResult>((await controller.EnviarSolicitud(2)).Result);
        Assert.Equal(0, service.Writes);
    }

    [Fact]
    public async Task HeaderApprovalCannotBorrowPermissionFromAnotherType()
    {
        var service = new Headers { Current = new() { FkidTipoAdecuacionPres = 2 } };
        var controller = Controller(service, "Presupuesto_Modificado|Ampliaciones|authorize");
        Assert.IsType<ForbidResult>((await controller.Autorizar(2)).Result);
        Assert.Equal(0, service.Writes);
    }

    private static EgreAdecuacionController Controller(Headers service, string policy) => WithContext(
        new EgreAdecuacionController(service, new FixedUserContext(7, 3), new Permissions(policy)));

    private static T WithContext<T>(T controller) where T : ControllerBase
    {
        controller.ControllerContext = new() { HttpContext = new DefaultHttpContext() };
        return controller;
    }

    private sealed class Permissions(string allowed) : IAuthorizationService
    {
        public Task<AuthorizationResult> AuthorizeAsync(ClaimsPrincipal user, object? resource, string policyName) =>
            Task.FromResult(policyName == allowed ? AuthorizationResult.Success() : AuthorizationResult.Failed());
        public Task<AuthorizationResult> AuthorizeAsync(ClaimsPrincipal user, object? resource, IEnumerable<IAuthorizationRequirement> requirements) =>
            Task.FromResult(AuthorizationResult.Failed());
    }

    private class Crud<T> : IAdquisicionCrudAppService<T> where T : class, new()
    {
        public T? Current { get; init; }
        public int Writes { get; protected set; }
        public int Pages { get; private set; }
        public PagedRequest? LastRequest { get; private set; }
        public Task<PagedResult<T>> GetAllAsync() => Task.FromResult(new PagedResult<T> { Success = true });
        public virtual Task<PagedResult<T>> GetByIdAsync(int id) => Task.FromResult(new PagedResult<T> { Success = Current != null, Data = Current! });
        public Task<PagedResult<T>> CreateAsync(T response, int user) => Write(response);
        public Task<PagedResult<T>> UpdateAsync(int id, T response, int user) => Write(response);
        public Task<PagedResult<bool>> DeleteAsync(int id)
        {
            Writes++;
            return Task.FromResult(new PagedResult<bool> { Success = true });
        }
        public Task<PagedResult<T>> GetAllPaginadoAsync(PagedRequest request)
        {
            Pages++;
            LastRequest = request;
            return GetAllAsync();
        }
        protected Task<PagedResult<T>> Write(T response)
        {
            Writes++;
            return Task.FromResult(new PagedResult<T> { Success = true, Data = response });
        }
    }

    private sealed class Headers : Crud<EgreAdecuacionResponse>, IPresupuestoModificadoAppService
    {
        public override Task<PagedResult<EgreAdecuacionResponse>> GetByIdAsync(int id) => Current != null
            ? base.GetByIdAsync(id)
            : Task.FromResult(new PagedResult<EgreAdecuacionResponse>
            {
                Success = id is >= 1 and <= 3,
                Data = new() { FkidTipoAdecuacionPres = id }
            });
        public Task<PagedResult<EgreAdecuacionResponse>> EnviarSolicitudAsync(int id, int user) => Write(new());
        public Task<PagedResult<EgreAdecuacionResponse>> AutorizarAsync(int id, int user) => Write(new());
        public Task<PagedResult<EgreAdecuacionResponse>> RechazarAsync(int id, int user) => Write(new());
        public Task<PagedResult<EgreAdecuacionResponse>> CancelarSolicitudAsync(int id, int user) => Write(new());
    }

    private sealed class IncomeHeaders : Crud<IngreAdecuacionResponse>, IIngresoAdecuacionAppService
    {
        public Task<PagedResult<IngreAdecuacionResponse>> EnviarSolicitudAsync(int id, int user) => Write(new());
        public Task<PagedResult<IngreAdecuacionResponse>> AutorizarAsync(int id, int user) => Write(new());
        public Task<PagedResult<IngreAdecuacionResponse>> RechazarAsync(int id, int user) => Write(new());
    }
}
