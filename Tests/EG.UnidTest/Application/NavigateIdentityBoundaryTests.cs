using EG.Application.Services.Account;
using EG.ApiCoreBS.Services.Licensing;
using EG.Business.Interfaces;
using EG.Dommain.DTOs.Responses;
using EG.Infraestructure.Models;
using EG.UnidTest.Support;

namespace EG.UnidTest.Application;

public sealed class NavigateIdentityBoundaryTests
{
    [Theory]
    [InlineData(false)]
    [InlineData(true)]
    public async Task AnotherUsersMenuOrClaimsAreRejectedBeforeDatabaseAccess(bool claims)
    {
        var store = new RecordingNavigateService();
        var service = new NavigateAppService(store, new LicenseRuntimeState(), new FixedUserContext(42, 7));

        await Assert.ThrowsAsync<UnauthorizedAccessException>(async () =>
        {
            if (claims) await service.GetAllClaimsByUser(43);
            else await service.GetMenuAsync(43);
        });

        Assert.Equal(0, store.ReadCount);
    }

    [Theory]
    [InlineData(false)]
    [InlineData(true)]
    public async Task CurrentUserCanReadTheirOwnMenuAndClaims(bool claims)
    {
        var store = new RecordingNavigateService();
        var service = new NavigateAppService(store, new LicenseRuntimeState(), new FixedUserContext(42, 7));

        if (claims) await service.GetAllClaimsByUser(42);
        else await service.GetMenuAsync(42);

        Assert.Equal(1, store.ReadCount);
        Assert.Equal(42, store.LastUserId);
    }

    private sealed class RecordingNavigateService : INavigateService
    {
        public int ReadCount { get; private set; }
        public int LastUserId { get; private set; }

        public Task<IEnumerable<spNodeMenuResponse>> GetMenuAsync(int empId)
        {
            ReadCount++;
            LastUserId = empId;
            return Task.FromResult<IEnumerable<spNodeMenuResponse>>([]);
        }

        public Task<List<spGetClaimsByUserResult>> ObtenerClaimsUsuarioAsync(int usuarioId)
        {
            ReadCount++;
            LastUserId = usuarioId;
            return Task.FromResult(new List<spGetClaimsByUserResult>());
        }
    }
}
