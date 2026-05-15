using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Logging;
using System.Reflection;
using Const = EG.Common.Constants;

namespace EG.Logger;

public static class LoggerExtensions
{
    public static void AddLoggerGRP(this IServiceCollection services, IConfiguration configuration)
    {
        services.AddLogging(loggingBuilder =>
        {
            loggingBuilder.AddLog4Net("log4net.config");
        });

        var connectionString = configuration.GetConnectionString(Const.BD_CON);
        var hierarchy = log4net.LogManager.GetRepository(Assembly.GetCallingAssembly()) as log4net.Repository.Hierarchy.Hierarchy;

        if (hierarchy == null)
        {
            return;
        }

        var adoAppender = hierarchy.GetAppenders()
            .OfType<Log4NetCore.SqlServer.Appenders.AdoNetAppender>()
            .FirstOrDefault(appender => appender.Name.Equals("AdoNetAppender", StringComparison.InvariantCultureIgnoreCase));

        if (adoAppender == null)
        {
            return;
        }

        adoAppender.ConnectionString = connectionString;
        adoAppender.ActivateOptions();
    }
}
