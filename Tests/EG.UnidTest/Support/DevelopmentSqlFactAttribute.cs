namespace EG.UnidTest.Support;

public sealed class DevelopmentSqlFactAttribute : FactAttribute
{
    public DevelopmentSqlFactAttribute()
    {
        if (Environment.GetEnvironmentVariable("EG_RUN_DEV_SQL_TESTS") != "1")
            Skip = "Requiere ejecución explícita contra SQL Server local de desarrollo.";
    }
}
