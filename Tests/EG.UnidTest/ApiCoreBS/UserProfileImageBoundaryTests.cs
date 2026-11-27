using EG.ApiCoreBS.Controllers.General;
using EG.Application.Interfaces.General;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.General;
using EG.Domain.Interfaces;
using EG.Dommain.DTOs.Responses;
using Microsoft.AspNetCore.Mvc;

namespace EG.UnidTest.ApiCoreBS;

public sealed class UserProfileImageBoundaryTests
{
    [Fact]
    public async Task MissingPhotoReturnsNoContentForCurrentUser()
    {
        var service = new ProfileServiceFake();
        var controller = new UserProfileController(service, new UserContextFake(1));

        var result = await controller.GetProfileImage(1);

        Assert.IsType<NoContentResult>(result.Result);
        Assert.Equal(1, service.RequestedUserId);
    }

    [Fact]
    public async Task CannotReadAnotherUsersPhoto()
    {
        var service = new ProfileServiceFake();
        var controller = new UserProfileController(service, new UserContextFake(1));

        var result = await controller.GetProfileImage(2);

        Assert.IsType<ForbidResult>(result.Result);
        Assert.Null(service.RequestedUserId);
    }

    [Fact]
    public async Task ExistingPhotoReturnsImageForCurrentUser()
    {
        var service = new ProfileServiceFake
        {
            Image = new PerfilUsuarioResponse { FkidUsuarioSis = 1, Fotografia = [1, 2, 3] }
        };
        var controller = new UserProfileController(service, new UserContextFake(1));

        var result = await controller.GetProfileImage(1);

        var response = Assert.IsType<OkObjectResult>(result.Result);
        Assert.Same(service.Image, response.Value);
    }

    private sealed class ProfileServiceFake : IUserProfileAppService
    {
        public PerfilUsuarioResponse? Image { get; init; }
        public int? RequestedUserId { get; private set; }

        public Task<PerfilUsuarioResponse> GetProfileImageAsync(int id)
        {
            RequestedUserId = id;
            return Task.FromResult(Image!);
        }

        public Task<bool> CreateProfileAsync(UsuarioDto user) => Task.FromResult(false);
        public Task<bool> SetProfileAsync(int id, UsuarioDto user) => Task.FromResult(false);
        public Task<bool> DeleteProfileAsync(int id) => Task.FromResult(false);
        public Task<UsuarioResponse> GetProfileUserAsync(int id) => Task.FromResult<UsuarioResponse>(null!);
        public Task<IList<UsuarioResponse>> GetAllUsersAsync() => Task.FromResult<IList<UsuarioResponse>>([]);
        public Task<PagedResult<UsuarioResponse>> GetAllUsersPaginadoAsync(PagedRequest request) =>
            Task.FromResult(new PagedResult<UsuarioResponse>());
        public Task UploadImageAsync(PerfilUsuarioResponse fotografia) => Task.CompletedTask;
        public Task<PagedResult<bool>> ChangePasswordAsync(int id, ChangePasswordDto request, int currentUserId) =>
            Task.FromResult(new PagedResult<bool>());
    }

    private sealed class UserContextFake(int userId) : IUserContextService
    {
        public int GetCurrentUserId() => userId;
        public int? TryGetCurrentUserId() => userId;
        public int GetCurrentEmpresaId() => 1;
        public int? TryGetCurrentEmpresaId() => 1;
        public int GetCurrentAnioPresupuestalId() => 1;
        public int? TryGetCurrentAnioPresupuestalId() => 1;
        public System.Security.Claims.ClaimsPrincipal? GetUserPrincipal() => null;
    }
}
