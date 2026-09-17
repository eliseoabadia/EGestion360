using EG.Contracts.Platform.Licensing;
using EG.Domain.Platform.Licensing;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Controllers;
using Microsoft.AspNetCore.Mvc.Filters;

namespace EG.ApiCoreBS.Filters;

public sealed class ModuleLicenseFilter(
    ILicenseRuntimeState licensing,
    ILogger<ModuleLicenseFilter> logger) : IAsyncActionFilter
{
    public async Task OnActionExecutionAsync(
        ActionExecutingContext context,
        ActionExecutionDelegate next)
    {
        var descriptor = context.ActionDescriptor as ControllerActionDescriptor;
        var controllerNamespace = descriptor?.ControllerTypeInfo.Namespace;
        var moduleCode = LicenseModuleResolver.ResolveControllerModule(controllerNamespace);

        if (moduleCode is null && IsReportingExport(descriptor))
        {
            var reportName = context.ActionArguments.TryGetValue("report", out var value)
                ? value?.ToString()
                : context.HttpContext.Request.Query["report"].FirstOrDefault();
            moduleCode = LicenseModuleResolver.ResolveReportModule(reportName);
        }

        if (moduleCode is null && !LicenseModuleResolver.IsCoreControllerNamespace(controllerNamespace))
        {
            Deny(
                context,
                "LIC_MODULE_UNMAPPED",
                "La operación no tiene una clasificación de licencia configurada.",
                controllerNamespace);
            return;
        }

        if (moduleCode is null)
        {
            await next();
            return;
        }

        var requiredModules = new[] { moduleCode }
            .Concat(LicenseModuleResolver.ResolveAdditionalControllerModules(
                descriptor?.ControllerName,
                descriptor?.ActionName))
            .Distinct(StringComparer.OrdinalIgnoreCase);

        foreach (var requiredModule in requiredModules)
        {
            var decision = licensing.Evaluate(requiredModule);
            if (!decision.Allowed)
            {
                var message = requiredModule == moduleCode
                    ? decision.Message
                    : $"La integración requiere el módulo {LicenseModuleCodes.Find(requiredModule)?.Name ?? requiredModule}. {decision.Message}";
                Deny(context, decision.Code, message, requiredModule);
                return;
            }
        }

        await next();
    }

    private void Deny(ActionExecutingContext context, string code, string message, string? module)
    {
        logger.LogWarning(
            "Operación bloqueada por licencia. Code={Code}; Module={Module}; Path={Path}; User={User}",
            code,
            module,
            context.HttpContext.Request.Path,
            context.HttpContext.User.Identity?.Name ?? "unknown");

        context.Result = new ObjectResult(new
        {
            success = false,
            code,
            message,
            traceId = context.HttpContext.TraceIdentifier
        })
        {
            StatusCode = StatusCodes.Status403Forbidden
        };
    }

    private static bool IsReportingExport(ControllerActionDescriptor? descriptor) =>
        descriptor is not null &&
        string.Equals(descriptor.ControllerName, "ReportingExport", StringComparison.Ordinal) &&
        string.Equals(descriptor.ActionName, "ExportPdf", StringComparison.Ordinal);
}
