using EG.Common.Helper;
using EG.Contracts.Platform.Licensing;
using EG.Web.Contracts.Configuration;
using EG.Web.Models;
using Microsoft.JSInterop;

namespace EG.Web.Services.Configuration;

public sealed class LicensingClientService(
    IConfiguration configuration,
    HttpClient httpClient,
    IJSRuntime jsRuntime,
    ApplicationInstance application,
    ILogger<LicensingClientService> logger)
    : BaseService(httpClient, jsRuntime, application, configuration, logger), ILicensingClientService
{
    private const string Endpoint = "api/Licensing";

    public async Task<ApiResponse<LicenseSnapshotResponse>> GetSnapshotAsync() =>
        await GetAsync<ApiResponse<LicenseSnapshotResponse>>($"{Endpoint}/snapshot", useBaseUrl: false)
        ?? new ApiResponse<LicenseSnapshotResponse>();

    public async Task<ApiResponse<LicenseInstallationRequestResponse>> GetInstallationRequestAsync() =>
        await GetAsync<ApiResponse<LicenseInstallationRequestResponse>>($"{Endpoint}/installation-request", useBaseUrl: false)
        ?? new ApiResponse<LicenseInstallationRequestResponse>();

    public async Task<ApiResponse<LicenseSnapshotResponse>> ImportAsync(string signedLicense) =>
        await PostAsync<ApiResponse<LicenseSnapshotResponse>>(
            $"{Endpoint}/import",
            new ImportLicenseRequest { SignedLicense = signedLicense },
            useBaseUrl: false)
        ?? new ApiResponse<LicenseSnapshotResponse>();

    public async Task<ApiResponse<LicenseSnapshotResponse>> SetModuleStateAsync(
        string moduleCode,
        bool active,
        string? reason) =>
        await PutAsync<ApiResponse<LicenseSnapshotResponse>>(
            $"{Endpoint}/modules/{Uri.EscapeDataString(moduleCode)}",
            new SetLicenseModuleStateRequest { Active = active, Reason = reason },
            useBaseUrl: false)
        ?? new ApiResponse<LicenseSnapshotResponse>();
}
