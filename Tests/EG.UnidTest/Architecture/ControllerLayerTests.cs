using System.Reflection;
using EG.ApiCoreBS.Controllers;
using Microsoft.AspNetCore.Mvc;

namespace EG.UnidTest.Architecture;

public sealed class ControllerLayerTests
{
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
