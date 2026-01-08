
namespace EG.Common.Enums
{
    [Flags]
    public enum SystemLogTypes : byte
    {
        General = 1, 
        Information = 2, 
        Warning = 3, 
        Error = 4
    }

    [Flags]
    public enum LogLevelGRP
    {
        Debug,
        Info,
        Warn,
        Error,
        Fatal
    }

}
