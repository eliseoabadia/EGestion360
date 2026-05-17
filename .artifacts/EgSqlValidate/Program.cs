using Microsoft.Data.SqlClient;

var connectionString = "Data Source=DESKTOP-B2UQJB2;Initial Catalog=GestionEmpresarial;User ID=sa;Password=Sitio2010;TrustServerCertificate=True;MultipleActiveResultSets=True;Connect Timeout=10;Pooling=True;Encrypt=False;";

await using var connection = new SqlConnection(connectionString);
await connection.OpenAsync();

await using var command = connection.CreateCommand();
command.CommandText = """
    SET NOCOUNT ON;

    SELECT
        OBJECT_ID(N'PRES.Vw_EgresoProyectado', N'V') AS ViewId,
        OBJECT_ID(N'PRES.VwEgresoProyectado', N'V') AS OldViewId;

    SELECT c.name
    FROM sys.columns c
    WHERE c.object_id = OBJECT_ID(N'PRES.Vw_EgresoProyectado', N'V')
      AND c.name IN (N'FKIdAnio_SIS', N'AnioClave')
    ORDER BY c.name;

    SELECT TOP (1)
        [PKIdEgresoProyectado],
        [FKIdAnio_SIS],
        [AnioClave]
    FROM [PRES].[Vw_EgresoProyectado];
    """;

await using var reader = await command.ExecuteReaderAsync();

if (await reader.ReadAsync())
{
    Console.WriteLine($"ViewId={ValueOrNull(reader["ViewId"])} OldViewId={ValueOrNull(reader["OldViewId"])}");
}

await reader.NextResultAsync();
var columns = new List<string>();
while (await reader.ReadAsync())
{
    columns.Add(reader.GetString(0));
}

Console.WriteLine($"Columns={string.Join(",", columns)}");

await reader.NextResultAsync();
Console.WriteLine(await reader.ReadAsync()
    ? $"Sample PK={ValueOrNull(reader["PKIdEgresoProyectado"])} FKIdAnio_SIS={ValueOrNull(reader["FKIdAnio_SIS"])} AnioClave={ValueOrNull(reader["AnioClave"])}"
    : "Sample=<empty>");

static string ValueOrNull(object? value) => value is null or DBNull ? "NULL" : Convert.ToString(value) ?? "NULL";
