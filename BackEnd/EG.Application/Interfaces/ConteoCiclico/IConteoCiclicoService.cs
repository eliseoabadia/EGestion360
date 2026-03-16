using EG.Domain.DTOs.Requests.ConteoCiclico.EG.Domain.DTOs.ConteoCiclico;
using System;
using System.Collections.Generic;
using System.Text;

namespace EG.Application.Interfaces.ConteoCiclico
{
    public interface IConteoCiclicoService
    {
        // Generación de conteo
        Task<ConteoResult> GenerarConteoAsync(GenerarConteoRequest request, int usuarioActual);

        // Iniciar conteo de un artículo
        Task<ConteoResult> IniciarConteoAsync(int articuloConteoId, int usuarioActual);

        // Registrar un conteo (primer, segundo, tercero)
        Task<ConteoResult> RegistrarConteoAsync(RegistrarConteoRequest request, int usuarioActual);

        // Cerrar conteo de un artículo (forzar cierre)
        Task<ConteoResult> CerrarConteoAsync(CerrarConteoRequest request, int usuarioActual);

        // Dashboard
        Task<DashboardResponse> GetDashboardAsync(int? sucursalId = null);
    }
}
