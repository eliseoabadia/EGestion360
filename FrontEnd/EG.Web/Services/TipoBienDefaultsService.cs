using System.Globalization;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Responses.Patrimonio;
using EG.Web.Contracts;

namespace EG.Web.Services;

public sealed class TipoBienDefaultsService
{
    private readonly IGenericCrudService<TipoBienResponse> _tipoBienService;

    public TipoBienDefaultsService(IGenericCrudService<TipoBienResponse> tipoBienService)
    {
        _tipoBienService = tipoBienService;
    }

    public async Task<LookupItem?> GetUnidadPrincipalAsync(int tipoBienId)
    {
        if (tipoBienId <= 0)
        {
            return null;
        }

        var response = await _tipoBienService.GetByIdAsync(tipoBienId);
        var tipoBien = response?.Success == true ? response.Data : null;
        if (tipoBien?.FkidUnidadesAlma is not > 0)
        {
            return null;
        }

        return new LookupItem
        {
            Id = tipoBien.FkidUnidadesAlma.Value,
            Text = string.IsNullOrWhiteSpace(tipoBien.UnidadMedida)
                ? tipoBien.FkidUnidadesAlma.Value.ToString(CultureInfo.InvariantCulture)
                : tipoBien.UnidadMedida
        };
    }
}
