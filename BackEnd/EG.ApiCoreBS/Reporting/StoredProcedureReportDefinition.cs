namespace EG.ApiCoreBS.Reporting;

public sealed record StoredProcedureReportDefinition(
    string ReportName,
    string DisplayName,
    string StoredProcedureName,
    IReadOnlyList<StoredProcedureReportParameter> Parameters,
    IReadOnlyList<StoredProcedureReportField> Fields,
    string ConnectionName,
    string QueryName = "Result");

public sealed record StoredProcedureReportParameter(
    string StoredProcedureParameterName,
    string ReportParameterName,
    Type Type,
    string RequestParameterName,
    object? DefaultValue = null);

public sealed record StoredProcedureReportField(
    string FieldName,
    string Caption,
    float Width);
