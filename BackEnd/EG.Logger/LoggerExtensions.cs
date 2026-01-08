using log4net.Repository;
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

        var BD_CON = configuration.GetConnectionString(Const.BD_CON);

        ILoggerRepository repository = log4net.LogManager.GetRepository(Assembly.GetCallingAssembly());

        log4net.Repository.Hierarchy.Hierarchy hier = log4net.LogManager.GetRepository(Assembly.GetCallingAssembly()) as log4net.Repository.Hierarchy.Hierarchy;

        if (hier != null)
        {
            var adoAppender = (Log4NetCore.SqlServer.Appenders.AdoNetAppender)hier.GetAppenders()
                                .Where(appender => appender.Name.Equals("AdoNetAppender", StringComparison.InvariantCultureIgnoreCase))
                                .FirstOrDefault();

            if (adoAppender != null)
            {
                adoAppender.ConnectionString = BD_CON;
                adoAppender.ActivateOptions(); //refresh settings of appender
            }
        }
    }
}