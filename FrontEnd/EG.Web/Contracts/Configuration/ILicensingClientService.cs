using EG.Contracts.Platform.Licensing;
using EG.Web.Models;

namespace EG.Web.Contracts.Configuration;

public interface ILicensingClientService
{
    Task<ApiResponse<LicenseSnapshotResponse>> GetSnapshotAsync();
    Task<ApiResponse<LicenseInstallationRequestResponse>> GetInstallationRequestAsync();
    Task<ApiResponse<LicenseSnapshotResponse>> ImportAsync(string signedLicense);
    Task<ApiResponse<LicenseSnapshotResponse>> SetModuleStateAsync(
        string moduleCode,
        bool active,
        string? reason);
}
