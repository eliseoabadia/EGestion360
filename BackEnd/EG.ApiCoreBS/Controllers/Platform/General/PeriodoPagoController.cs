using EG.Common.GenericModel;
using EG.Domain.DTOs.Responses.General;
using EG.Infraestructure.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace EG.ApiCoreBS.Controllers.General
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize]
    public class PeriodoPagoController(EGestionContext context) : ControllerBase
    {
        [HttpGet]
        public async Task<ActionResult<PagedResult<PeriodoPagoResponse>>> GetAll()
        {
            var items = await context.VwPeriodoPagos
                .AsNoTracking()
                .Where(item => item.Activo)
                .OrderBy(item => item.Orden ?? item.LegacyId ?? item.PkidCatalogoSimple)
                .Select(item => new PeriodoPagoResponse
                {
                    PkidCatalogoSimple = item.PkidCatalogoSimple,
                    LegacyId = item.LegacyId,
                    Descripcion = item.Descripcion,
                    DescripcionCorta = item.DescripcionCorta,
                    Orden = item.Orden,
                    Activo = item.Activo
                })
                .ToListAsync();

            return Ok(new PagedResult<PeriodoPagoResponse>
            {
                Success = true,
                Message = "Periodos de pago obtenidos correctamente",
                Code = "SUCCESS",
                Items = items,
                TotalCount = items.Count
            });
        }
    }
}
