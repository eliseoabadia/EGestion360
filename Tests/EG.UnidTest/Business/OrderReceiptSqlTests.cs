using EG.Business.Services.Almacen;
using EG.Infraestructure.Models;
using EG.UnidTest.Support;
using Microsoft.Data.SqlClient;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Infrastructure;

namespace EG.UnidTest.Business;

public sealed class OrderReceiptSqlTests
{
    private const string Connection = "Data Source=.;Initial Catalog=GestionEmpresarial;Integrated Security=True;TrustServerCertificate=True;Application Name=EGestion360-Receipt-Test;Connect Timeout=5";
    private static readonly string Prefix = "EG_DEV_RECEIPT_" + Guid.NewGuid().ToString("N");

    [DevelopmentSqlFact]
    [Trait("Category", "DevelopmentSql")]
    public async Task SimultaneousReceiptsCannotExceedOrderAndRejectedOrRolledBackWritesLeaveNoEffect()
    {
        await using var connection = new SqlConnection(Connection);
        await connection.OpenAsync();
        try
        {
            await ExecuteAsync(connection, $"""
                CREATE TABLE dbo.[{Prefix}Req] (Id int PRIMARY KEY, YearId int NOT NULL);
                CREATE TABLE dbo.[{Prefix}Order] (Id int PRIMARY KEY, CompanyId int NOT NULL, ReqId int NOT NULL, StatusId int NOT NULL, Active bit NOT NULL);
                CREATE TABLE dbo.[{Prefix}Detail] (Id int PRIMARY KEY, OrderId int NOT NULL, Requested decimal(20,4) NOT NULL, Received decimal(20,4) NOT NULL, Active bit NOT NULL, ModifiedAt datetime2 NULL, ModifiedBy int NULL);
                INSERT dbo.[{Prefix}Req] VALUES (1,2026);
                INSERT dbo.[{Prefix}Order] VALUES (1,7,1,2,1);
                INSERT dbo.[{Prefix}Detail] VALUES (1,1,5,0,1,NULL,NULL);
                """);

            // Modelo y escritor reales; sólo se remapean tres tablas a fixtures
            // vacíos y propios. No se copian ni modifican documentos existentes.
            await using (var warmup = CreateContext()) { _ = warmup.Model; }
            var gate = new TaskCompletionSource(TaskCreationOptions.RunContinuationsAsynchronously);
            var attempts = Enumerable.Range(0, 16).Select(async _ =>
            {
                await using var context = CreateContext();
                await gate.Task;
                await using var transaction = await context.Database.BeginTransactionAsync();
                try
                {
                    await OrderReceiptWriter.ApplyAsync(context, new FixedUserContext(42, 7, 2026), 1, 1m, 42);
                    await transaction.CommitAsync();
                    return true;
                }
                catch (InvalidOperationException)
                {
                    await transaction.RollbackAsync();
                    return false;
                }
            }).ToArray();
            gate.SetResult();
            var results = await Task.WhenAll(attempts);
            Assert.Equal(5, results.Count(accepted => accepted));
            Assert.Equal(11, results.Count(accepted => !accepted));
            Assert.Equal(5m, await ReadReceivedAsync(connection));

            await ExecuteAsync(connection, $"UPDATE dbo.[{Prefix}Detail] SET Received=0;");
            await using (var context = CreateContext())
            {
                await using var transaction = await context.Database.BeginTransactionAsync();
                await OrderReceiptWriter.ApplyAsync(context, new FixedUserContext(42, 7, 2026), 1, 3m, 42);
                await transaction.RollbackAsync();
            }
            Assert.Equal(0m, await ReadReceivedAsync(connection));

            foreach (var scenario in new[] { (99, 2026, 1m), (7, 2030, 1m), (7, 2026, -1m), (7, 2026, 6m) })
            {
                await using var context = CreateContext();
                await using var transaction = await context.Database.BeginTransactionAsync();
                await Assert.ThrowsAsync<InvalidOperationException>(() => OrderReceiptWriter.ApplyAsync(
                    context, new FixedUserContext(42, scenario.Item1, scenario.Item2), 1, scenario.Item3, 42));
                await transaction.RollbackAsync();
                Assert.Equal(0m, await ReadReceivedAsync(connection));
            }
        }
        finally
        {
            await ExecuteAsync(connection, $"DROP TABLE IF EXISTS dbo.[{Prefix}Detail]; DROP TABLE IF EXISTS dbo.[{Prefix}Order]; DROP TABLE IF EXISTS dbo.[{Prefix}Req];");
        }
    }

    private static async Task ExecuteAsync(SqlConnection connection, string sql)
    {
        await using var command = new SqlCommand(sql, connection) { CommandTimeout = 15 };
        await command.ExecuteNonQueryAsync();
    }

    private static async Task<decimal> ReadReceivedAsync(SqlConnection connection)
    {
        await using var command = new SqlCommand($"SELECT Received FROM dbo.[{Prefix}Detail] WHERE Id=1", connection);
        return Convert.ToDecimal(await command.ExecuteScalarAsync());
    }

    private static FixtureContext CreateContext() => new(new DbContextOptionsBuilder<EGestionContext>()
        .UseSqlServer(Connection, sql => sql.CommandTimeout(15))
        .ReplaceService<IModelCacheKeyFactory, FixtureModelKey>().Options);

    private sealed class FixtureContext(DbContextOptions<EGestionContext> options) : EGestionContext(options)
    {
        protected override void OnModelCreating(ModelBuilder model)
        {
            base.OnModelCreating(model);
            foreach (var type in new[] { typeof(Requisicion), typeof(OrdenCompra), typeof(OrdenCompraDetalle) })
            {
                var entity = model.Entity(type).Metadata;
                foreach (var trigger in entity.GetDeclaredTriggers().ToArray())
                    entity.RemoveTrigger(trigger.ModelName);
            }
            model.Entity<Requisicion>(entity =>
            {
                entity.ToTable(Prefix + "Req", "dbo");
                entity.Property(x => x.PkidRequisicion).HasColumnName("Id");
                entity.Property(x => x.FkidAnioSis).HasColumnName("YearId");
            });
            model.Entity<OrdenCompra>(entity =>
            {
                entity.ToTable(Prefix + "Order", "dbo");
                entity.Property(x => x.PkidOrdenCompra).HasColumnName("Id");
                entity.Property(x => x.FkidEmpresaSis).HasColumnName("CompanyId");
                entity.Property(x => x.FkidRequisicionOrco).HasColumnName("ReqId");
                entity.Property(x => x.FkidEstatusOrdenCompraOrco).HasColumnName("StatusId");
                entity.Property(x => x.Activo).HasColumnName("Active");
            });
            model.Entity<OrdenCompraDetalle>(entity =>
            {
                entity.ToTable(Prefix + "Detail", "dbo");
                entity.Property(x => x.PkidOrdenCompraDetalle).HasColumnName("Id");
                entity.Property(x => x.FkidOrdenCompraOrco).HasColumnName("OrderId");
                entity.Property(x => x.CantidadSolicitada).HasColumnName("Requested");
                entity.Property(x => x.CantidadRecibida).HasColumnName("Received");
                entity.Property(x => x.Activo).HasColumnName("Active");
                entity.Property(x => x.FechaModificacion).HasColumnName("ModifiedAt");
                entity.Property(x => x.UsuarioModificacion).HasColumnName("ModifiedBy");
            });
        }
    }

    public sealed class FixtureModelKey : IModelCacheKeyFactory
    {
        public object Create(DbContext context, bool designTime) => (context.GetType(), Prefix, designTime);
    }
}
