using EG.Domain.DTOs.Responses.PBR;
using EG.Infraestructure.Models;
using Microsoft.EntityFrameworkCore;
using System.Globalization;
using System.Text;

namespace EG.Application.Services.PBR
{
    public interface IPbrDashboardAppService
    {
        Task<PbrDashboardResponse> GetAsync(int anio);
    }

    public class PbrDashboardAppService : IPbrDashboardAppService
    {
        private readonly EGestionContext _context;

        public PbrDashboardAppService(EGestionContext context)
        {
            _context = context;
        }

        public async Task<PbrDashboardResponse> GetAsync(int anio)
        {
            var programas = await _context.VwProgramas
                .AsNoTracking()
                .Where(x => x.Activo)
                .Select(x => new ProgramaInfo(
                    x.PkidPrograma,
                    x.Clave ?? string.Empty,
                    x.Descripcion ?? string.Empty,
                    x.UrclaveNombre ?? x.Urdescripcion ?? string.Empty))
                .ToListAsync();

            var programaIds = programas.Select(x => x.Id).ToHashSet();

            var presupuestos = await _context.VwPresupuestoProgramas
                .AsNoTracking()
                .Where(x => x.Anio == anio && x.Activo)
                .ToListAsync();

            var indicadores = await _context.VwIndicadors
                .AsNoTracking()
                .Where(x => x.FkidProgramaPres.HasValue && programaIds.Contains(x.FkidProgramaPres.Value))
                .ToListAsync();

            var indicadorIds = indicadores.Select(x => x.PkidIndicador).ToHashSet();

            var avances = await _context.VwAvanceIndicadors
                .AsNoTracking()
                .Where(x => x.Anio == anio && indicadorIds.Contains(x.FkidIndicadorPbr))
                .ToListAsync();

            var ultimosAvances = avances
                .GroupBy(x => x.FkidIndicadorPbr)
                .ToDictionary(
                    x => x.Key,
                    x => x.OrderByDescending(a => a.Trimestre)
                        .ThenByDescending(a => a.FechaReporte)
                        .First());

            var semaforo = indicadores
                .Select(indicador =>
                {
                    ultimosAvances.TryGetValue(indicador.PkidIndicador, out var avance);
                    var porcentaje = CalcularPorcentaje(avance?.ValorAlcanzado, avance?.ValorProgramado);
                    var programa = programas.FirstOrDefault(x => x.Id == indicador.FkidProgramaPres);

                    return new PbrSemaforoIndicadorResponse
                    {
                        PkidIndicador = indicador.PkidIndicador,
                        Nombre = indicador.Nombre ?? string.Empty,
                        Programa = programa?.ClaveNombre ?? indicador.ProgramaDescripcion ?? string.Empty,
                        Nivel = indicador.Nivel ?? string.Empty,
                        Programado = avance?.ValorProgramado,
                        Alcanzado = avance?.ValorAlcanzado,
                        Porcentaje = porcentaje,
                        Estado = ObtenerEstado(porcentaje)
                    };
                })
                .OrderBy(x => OrdenEstado(x.Estado))
                .ThenByDescending(x => x.Porcentaje ?? -1)
                .ToList();

            var conteo = new PbrSemaforoConteoResponse
            {
                Verde = semaforo.Count(x => x.Estado == "verde"),
                Amarillo = semaforo.Count(x => x.Estado == "amarillo"),
                Rojo = semaforo.Count(x => x.Estado == "rojo"),
                SinDatos = semaforo.Count(x => x.Estado == "sin_datos")
            };

            var nivelesMir = await _context.VwMirNivels
                .AsNoTracking()
                .Where(x => x.FkidProgramaPres.HasValue && programaIds.Contains(x.FkidProgramaPres.Value))
                .ToListAsync();

            var ranking = programas
                .Select(programa =>
                {
                    var indicadoresPrograma = indicadores
                        .Where(x => x.FkidProgramaPres == programa.Id)
                        .Select(x => semaforo.FirstOrDefault(s => s.PkidIndicador == x.PkidIndicador))
                        .Where(x => x != null)
                        .Cast<PbrSemaforoIndicadorResponse>()
                        .ToList();

                    var conAvance = indicadoresPrograma.Count(x => x.Porcentaje.HasValue);
                    var cumplimiento = indicadoresPrograma.Count == 0
                        ? 0
                        : Redondear(indicadoresPrograma.Where(x => x.Porcentaje.HasValue).Select(x => x.Porcentaje!.Value).DefaultIfEmpty(0).Average());

                    return new PbrRankingProgramaResponse
                    {
                        PkidPrograma = programa.Id,
                        Clave = programa.Clave,
                        Nombre = programa.Nombre,
                        Dependencia = programa.Dependencia,
                        TotalIndicadores = indicadoresPrograma.Count,
                        IndicadoresConAvance = conAvance,
                        IndicadoresCumpliendo = indicadoresPrograma.Count(x => x.Estado == "verde"),
                        Cumplimiento = cumplimiento,
                        Presupuesto = presupuestos
                            .Where(x => x.FkidProgramaPres == programa.Id)
                            .Sum(x => x.PresupuestoModificado ?? x.PresupuestoAnual)
                    };
                })
                .Where(x => x.TotalIndicadores > 0 || x.Presupuesto > 0)
                .OrderByDescending(x => x.Cumplimiento)
                .ThenByDescending(x => x.Presupuesto)
                .Take(20)
                .ToList();

            var coberturaMir = programas
                .Select(programa =>
                {
                    var niveles = nivelesMir
                        .Where(x => x.FkidProgramaPres == programa.Id)
                        .Select(x => NormalizarNivel(x.Nivel))
                        .ToHashSet();

                    var tieneFin = niveles.Contains("fin");
                    var tieneProposito = niveles.Contains("proposito");
                    var tieneComponente = niveles.Contains("componente");
                    var tieneActividad = niveles.Contains("actividad");

                    return new PbrCoberturaMirResponse
                    {
                        PkidPrograma = programa.Id,
                        Clave = programa.Clave,
                        Nombre = programa.Nombre,
                        TieneFin = tieneFin,
                        TieneProposito = tieneProposito,
                        TieneComponente = tieneComponente,
                        TieneActividad = tieneActividad,
                        Completa = tieneFin && tieneProposito && tieneComponente && tieneActividad,
                        TotalIndicadores = indicadores.Count(x => x.FkidProgramaPres == programa.Id)
                    };
                })
                .Where(x => x.TotalIndicadores > 0 || x.TieneFin || x.TieneProposito || x.TieneComponente || x.TieneActividad)
                .OrderByDescending(x => x.Completa)
                .ThenBy(x => x.Clave)
                .ToList();

            var topPresupuestos = presupuestos
                .OrderByDescending(x => x.PresupuestoModificado ?? x.PresupuestoAnual)
                .Take(10)
                .Select(x => new PbrTopPresupuestoResponse
                {
                    PkidPresupuestoPrograma = x.PkidPresupuestoPrograma,
                    PkidPrograma = x.FkidProgramaPres,
                    ProgramaClave = x.ProgramaClave ?? string.Empty,
                    Programa = x.ProgramaDescripcion ?? string.Empty,
                    PresupuestoAnual = x.PresupuestoAnual,
                    PresupuestoModificado = x.PresupuestoModificado ?? x.PresupuestoAnual
                })
                .ToList();

            var evaluaciones = await _context.VwEvaluacions
                .AsNoTracking()
                .CountAsync(x => x.EjercicioFiscal == anio);

            var asmActivos = await _context.VwAsms
                .AsNoTracking()
                .CountAsync(x => x.EjercicioFiscal == anio && x.Estado != null && x.Estado.ToUpper() == "ABIERTO");

            var cumplimientoPromedio = semaforo.Where(x => x.Porcentaje.HasValue)
                .Select(x => x.Porcentaje!.Value)
                .DefaultIfEmpty(0)
                .Average();

            return new PbrDashboardResponse
            {
                Anio = anio,
                Generado = DateTime.Now,
                Resumen = new PbrDashboardResumenResponse
                {
                    TotalProgramas = programas.Count,
                    TotalIndicadores = indicadores.Count,
                    TotalEvaluaciones = evaluaciones,
                    AsmActivos = asmActivos,
                    IndicadoresCumpliendo = conteo.Verde,
                    CumplimientoPromedio = Redondear(cumplimientoPromedio),
                    PresupuestoAnual = presupuestos.Sum(x => x.PresupuestoAnual),
                    PresupuestoModificado = presupuestos.Sum(x => x.PresupuestoModificado ?? x.PresupuestoAnual),
                    ProgramasConMirCompleta = coberturaMir.Count(x => x.Completa),
                    CoberturaMirPorcentaje = coberturaMir.Count == 0
                        ? 0
                        : Redondear((decimal)coberturaMir.Count(x => x.Completa) / coberturaMir.Count * 100)
                },
                Semaforo = semaforo.Take(30).ToList(),
                SemaforoConteo = conteo,
                RankingProgramas = ranking,
                CoberturaMir = coberturaMir.Take(20).ToList(),
                TopPresupuestos = topPresupuestos
            };
        }

        private static decimal? CalcularPorcentaje(decimal? alcanzado, decimal? programado)
        {
            if (!alcanzado.HasValue || !programado.HasValue || programado.Value == 0)
            {
                return null;
            }

            return Redondear(alcanzado.Value / programado.Value * 100);
        }

        private static decimal Redondear(decimal value) => Math.Round(value, 2, MidpointRounding.AwayFromZero);

        private static string ObtenerEstado(decimal? porcentaje)
        {
            if (!porcentaje.HasValue)
            {
                return "sin_datos";
            }

            if (porcentaje.Value >= 90)
            {
                return "verde";
            }

            return porcentaje.Value >= 70 ? "amarillo" : "rojo";
        }

        private static int OrdenEstado(string estado) => estado switch
        {
            "rojo" => 0,
            "amarillo" => 1,
            "sin_datos" => 2,
            _ => 3
        };

        private static string NormalizarNivel(string? nivel)
        {
            var normalized = (nivel ?? string.Empty).Trim().ToLowerInvariant().Normalize(NormalizationForm.FormD);
            var builder = new StringBuilder(normalized.Length);

            foreach (var character in normalized)
            {
                if (CharUnicodeInfo.GetUnicodeCategory(character) != UnicodeCategory.NonSpacingMark)
                {
                    builder.Append(character);
                }
            }

            return builder.ToString().Normalize(NormalizationForm.FormC);
        }

        private sealed record ProgramaInfo(int Id, string Clave, string Nombre, string Dependencia)
        {
            public string ClaveNombre => string.IsNullOrWhiteSpace(Clave) ? Nombre : $"{Clave} - {Nombre}";
        }
    }
}
