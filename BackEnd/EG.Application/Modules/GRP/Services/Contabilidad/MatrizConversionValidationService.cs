using EG.Application.Interfaces.Contabilidad;
using EG.Domain.DTOs.Responses.Contabilidad;
using EG.Domain.Interfaces;

namespace EG.Application.Services.Contabilidad;

public sealed class MatrizConversionValidationService(IMatrizConversionReferences references) : IMatrizConversionValidationService
{
    public async Task<string?> ValidateAsync(MatrizConversionResponse request)
    {
        if (!await references.ProgramaMatchesExerciseAsync(request.FkidProgramaPres, request.FkidAnioSis))
        {
            return "El programa no pertenece al ejercicio seleccionado o esta inactivo.";
        }
        if (!await references.PartidaActiveAsync(request.FkidPartidaSis))
        {
            return "La partida seleccionada no existe o esta inactiva.";
        }
        if (!await references.TipoGastoActiveAsync(request.FkidTipoGastoPres))
        {
            return "El tipo de gasto seleccionado no existe o esta inactivo.";
        }
        var rules = new[]
        {
            (Id: request.FkidCuentaContableAprobado, Prefix: "8 2 1"),
            (Id: request.FkidCuentaContablePorEjercer, Prefix: "8 2 2"),
            (Id: request.FkidCuentaContableModificado, Prefix: "8 2 3"),
            (Id: request.FkidCuentaContableComprometido, Prefix: "8 2 4"),
            (Id: request.FkidCuentaContableDevengado, Prefix: "8 2 5"),
            (Id: request.FkidCuentaContableEjercido, Prefix: "8 2 6"),
            (Id: request.FkidCuentaContablePagado, Prefix: "8 2 7"),
            (Id: request.FkidCuentaContableGasto, Prefix: "5")
        };
        var accounts = (await references.CuentasAsync(rules.Select(rule => rule.Id))).ToDictionary(account => account.Id);
        foreach (var rule in rules)
        {
            if (!accounts.TryGetValue(rule.Id, out var account) || !account.Activo || account.Nivel != 7 ||
                string.IsNullOrWhiteSpace(account.Clave) || !account.Clave.StartsWith(rule.Prefix))
            {
                return $"La cuenta {rule.Id} no cumple la naturaleza {rule.Prefix} de nivel 7.";
            }
        }
        return null;
    }
}
