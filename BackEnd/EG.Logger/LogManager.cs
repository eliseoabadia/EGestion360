using EG.Common.Enums;

namespace EG.Logger;

public class Log4NetLogger
{
    private readonly log4net.ILog _log;

    public Log4NetLogger(Type type)
    {
        _log = log4net.LogManager.GetLogger(type);
    }

    public void LogMessage(LogLevelGRP enumLogLevel, string meg, byte typeInformation, string progName, string employeeNo, string ipClient)
    {
        log4net.LogicalThreadContext.Properties["_Type"] = typeInformation;
        log4net.LogicalThreadContext.Properties["ProgName"] = progName;
        log4net.LogicalThreadContext.Properties["EmployeeNo"] = employeeNo;
        log4net.LogicalThreadContext.Properties["IPClient"] = ipClient;

        switch (enumLogLevel)
        {
            case LogLevelGRP.Info:
                _log.Info(meg);
                break;
            case LogLevelGRP.Debug:
                _log.Debug(meg);
                break;
            case LogLevelGRP.Warn:
                _log.Warn(meg);
                break;
            case LogLevelGRP.Fatal:
                _log.Fatal(meg);
                break;
            case LogLevelGRP.Error:
                _log.Error(meg);
                break;
            default:
                // Code to be executed if expression doesn't match any case
                break;

        }
    }

    public void LogError(string message, Exception ex)
    {
        _log.Error(message, ex);
    }
}
