namespace EG.Common.Modules;

public static class RequisitionDateRules
{
    public static string? Validate(DateTime? requisitionDate, DateTime? supplyStart, DateTime? supplyEnd)
    {
        if (requisitionDate is null || requisitionDate.Value == default)
        {
            return "La fecha de requisicion es requerida.";
        }

        if (supplyStart is null || supplyStart.Value == default || supplyEnd is null || supplyEnd.Value == default)
        {
            return "Las fechas de inicio y fin de suministro son requeridas.";
        }

        var requestDay = requisitionDate.Value.Date;
        var startDay = supplyStart.Value.Date;
        var endDay = supplyEnd.Value.Date;

        if (startDay > endDay)
        {
            return "La fecha de inicio de suministro no puede ser posterior a la fecha fin.";
        }

        if (requestDay > startDay)
        {
            return "La fecha de requisicion no puede ser posterior al inicio de suministro.";
        }

        return null;
    }
}
