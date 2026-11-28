using System.Reflection;
using EG.ApiCoreBS.Controllers;
using Microsoft.AspNetCore.Mvc;

namespace EG.UnidTest.Architecture;

public sealed class ControllerLayerTests
{
    [Fact]
    public void ApplicationAndBusinessDependenciesAreRegisteredInTheCompositionRoot()
    {
        var services = new Microsoft.Extensions.DependencyInjection.ServiceCollection();
        EG.ApiCoreBS.Extensions.ServiceCollectionExtensions.AddApplicationServices(
            services, typeof(EG.Application.Services.General.AreaAppService).Assembly);
        var registrations = services.Select(descriptor => descriptor.ServiceType).ToHashSet();
        var missing = services
            .Select(descriptor => descriptor.ImplementationType)
            .OfType<Type>()
            .Where(type => type.Namespace?.StartsWith("EG.Application", StringComparison.Ordinal) == true
                || type.Namespace?.StartsWith("EG.Business", StringComparison.Ordinal) == true)
            .SelectMany(type => type.GetConstructors().SelectMany(constructor => constructor.GetParameters())
                .Where(parameter => parameter.ParameterType.Namespace?.StartsWith("EG.Business", StringComparison.Ordinal) == true)
                .Where(parameter => !registrations.Contains(parameter.ParameterType)
                    && !(parameter.ParameterType.IsGenericType
                        && registrations.Contains(parameter.ParameterType.GetGenericTypeDefinition())))
                .Select(parameter => $"{type.FullName}: {parameter.ParameterType.FullName}"))
            .Distinct();
        Assert.Empty(missing);
    }

    [Fact]
    public void ApplicationServicesDoNotInjectSqlOrEntityFrameworkContexts()
    {
        var application = typeof(EG.Application.Services.General.AreaAppService).Assembly;
        var forbidden = application.GetTypes().Where(type => type.IsClass)
            .SelectMany(type => type.GetConstructors().SelectMany(constructor => constructor.GetParameters())
                .Where(parameter => typeof(Microsoft.EntityFrameworkCore.DbContext).IsAssignableFrom(parameter.ParameterType)
                    || parameter.ParameterType.Namespace?.StartsWith("Microsoft.Data.SqlClient", StringComparison.Ordinal) == true)
                .Select(parameter => $"{type.FullName}: {parameter.ParameterType.FullName}"));
        Assert.Empty(forbidden);
    }

    [Fact]
    public void BusinessProjectDoesNotReferenceApplication()
    {
        var references = typeof(EG.Business.Services.Almacen.OrderReceiptWriter).Assembly.GetReferencedAssemblies();
        Assert.DoesNotContain(references, reference => reference.Name == "EG.Application");
    }

    [Theory]
    [InlineData(typeof(EG.Application.Services.General.AreaAppService))]
    [InlineData(typeof(EG.Application.Services.General.DashboardAppService))]
    [InlineData(typeof(EG.Application.Services.General.EmpresaAppService))]
    [InlineData(typeof(EG.Application.Services.General.DepartamentoAppService))]
    [InlineData(typeof(EG.Application.Services.General.SucursalAppService))]
    public void GeneralApplicationFacadesUseBusinessContracts(Type service)
    {
        var parameters = service.GetConstructors().SelectMany(constructor => constructor.GetParameters()).ToArray();
        Assert.NotEmpty(parameters);
        Assert.All(parameters, parameter => Assert.Equal("EG.Business.Interfaces", parameter.ParameterType.Namespace));
    }

    [Fact]
    public void DocumentApplicationDoesNotDependOnPersistence()
    {
        var service = typeof(EG.Application.Services.SoporteDocumental.SoporteDocumentalAppService);
        var parameters = service.GetConstructors().SelectMany(constructor => constructor.GetParameters());
        Assert.DoesNotContain(parameters, parameter => typeof(Microsoft.EntityFrameworkCore.DbContext).IsAssignableFrom(parameter.ParameterType));
        Assert.Contains(parameters, parameter => parameter.ParameterType == typeof(EG.Business.Interfaces.ISoporteDocumentalService));
    }

    [Fact]
    public void ControllersDoNotInjectPersistenceOrBusinessServices()
    {
        var controllers = typeof(BaseApiController).Assembly.GetTypes()
            .Where(type => !type.IsAbstract && typeof(ControllerBase).IsAssignableFrom(type));
        var forbidden = new[] { "EG.Business", "EG.Infraestructure", "EG.Infrastructure", "Microsoft.EntityFrameworkCore", "Microsoft.Data.SqlClient" };
        var violations = controllers.SelectMany(type => type.GetConstructors()
            .SelectMany(constructor => constructor.GetParameters())
            .Where(parameter => forbidden.Any(prefix => parameter.ParameterType.Namespace?.StartsWith(prefix, StringComparison.Ordinal) == true))
            .Select(parameter => $"{type.Name}: {parameter.ParameterType.FullName}"));

        Assert.Empty(violations);
    }
}
