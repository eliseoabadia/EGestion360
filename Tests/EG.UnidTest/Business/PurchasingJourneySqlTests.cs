using System.Security.Claims;
using EG.ApiCoreBS.Extensions;
using EG.Application.Interfaces.Adquisicion;
using EG.Application.Interfaces.Contratos;
using EG.Business.Interfaces;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.Adquisicion;
using EG.Domain.DTOs.Requests.General;
using EG.Domain.DTOs.Responses.Adquisicion;
using EG.Domain.DTOs.Responses.General;
using EG.Domain.DTOs.Responses.Contratos;
using EG.Domain.DTOs.Responses.Almacen;
using EG.Domain.DTOs.Responses.PresupuestoComprometido;
using EG.Domain.Interfaces;
using EG.Domain.Platform.Licensing;
using EG.Contracts.Platform.Licensing;
using EG.Infraestructure.Models;
using EG.UnidTest.Support;
using Microsoft.AspNetCore.DataProtection;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;

namespace EG.UnidTest.Business;

public sealed class PurchasingJourneySqlTests
{
    private const string Connection = "Data Source=.;Initial Catalog=GestionEmpresarial;Integrated Security=True;TrustServerCertificate=True;Application Name=EGestion360-Purchase-Journey-Test;Connect Timeout=5";

    [DevelopmentSqlFact]
    [Trait("Category", "DevelopmentSql")]
    public async Task PurchaseJourneyUsesApplicationAndRealDatabaseInsideRollbackTransaction()
    {
        Mapster.TypeAdapterConfig.GlobalSettings.Scan(typeof(EG.Business.Mapping.General.EmpresaMappingProfile).Assembly);
        var diagnosticLog = new log4net.Appender.MemoryAppender();
        log4net.Config.BasicConfigurator.Configure(diagnosticLog);
        var services = new ServiceCollection();
        services.AddLogging();
        services.AddOptions();
        services.AddMemoryCache();
        services.AddHttpContextAccessor();
        services.AddHttpClient();
        services.AddSingleton<IConfiguration>(new ConfigurationBuilder().Build());
        services.AddSingleton<IDataProtectionProvider>(new EphemeralDataProtectionProvider());
        services.AddDbContext<EGestionContext>(options => options.UseSqlServer(Connection,
            sql => sql.CommandTimeout(15)));
        services.AddApplicationServices(typeof(EG.Application.Services.General.AreaAppService).Assembly);
        services.AddScoped<IUserContextService, DevelopmentAdministrator>();
        services.AddScoped<IEmailOperations, NoExternalEmail>();
        services.AddSingleton<ILicenseRuntimeState, UnlicensedFixture>();
        await using var provider = services.BuildServiceProvider();
        await using var scope = provider.CreateAsyncScope();
        var context = scope.ServiceProvider.GetRequiredService<EGestionContext>();
        var run = "DEVTEST-" + Guid.NewGuid().ToString("N");
        await using (var transaction = await context.Database.BeginTransactionAsync())
        {
            // Select legitimate catalog relationships. No existing business document is cloned.
            var fixture = await (
                from position in context.VwEgresoDisponibles
                join person in context.PersonaAreas on position.FkidAreaSis equals person.FkidAreaSis
                join item in context.TipoBiens on position.FkidPartidaConta equals item.FkidPartidaConta
                where position.FkidEmpresaSis == 1 && position.FkidAnioSis == 2026
                    && position.Total >= 100 && person.Activo && person.EsSolicitante == true
                    && person.FkidPersonaNom > 1 && person.FkidPersonaNomNavigation.Activo
                    && item.Activo && item.FkidUnidadesAlma != null
                select new { Position = position, PersonId = person.FkidPersonaNom, Item = item })
                .FirstAsync();
            var budget = fixture.Position;
            var monthlyBalances = new[] { budget.Enero, budget.Febrero, budget.Marzo, budget.Abril, budget.Mayo, budget.Junio, budget.Julio, budget.Agosto, budget.Septiembre, budget.Octubre, budget.Noviembre, budget.Diciembre };
            var month = Array.FindIndex(monthlyBalances, balance => balance >= 100m) + 1;
            Assert.InRange(month, 1, 12);
            var date = new DateTime(2026, month, 15);
            var requisitions = scope.ServiceProvider.GetRequiredService<IRequisicionAppService>();
            var requesterContext = (DevelopmentAdministrator)scope.ServiceProvider.GetRequiredService<IUserContextService>();
            var requesters = await requisitions.GetRequestersAsync();
            Assert.True(requesters.Success);
            Assert.NotEmpty(requesters.Items);
            Assert.Contains(requesters.Items, item => item.PkidPersona == fixture.PersonId && item.PkidArea == budget.FkidAreaSis);
            var technicalPerson = await context.Usuarios.Where(item => item.PkIdUsuario == 1)
                .Select(item => item.FkidPersonaNom).SingleAsync();
            Assert.DoesNotContain(requesters.Items, item => item.PkidPersona == technicalPerson);
            requesterContext.Administrator = false;
            var regularRequesters = await requisitions.GetRequestersAsync();
            var allowedAssignments = await context.VwUsuarioPersonaAreas
                .Where(item => item.PkIdUsuario == 1 && item.UsuarioActivo && item.PersonaActivo == true
                    && item.AreaActivo == true && item.EsSolicitante == true)
                .Select(item => new { item.PkidPersona, item.PkidArea }).ToListAsync();
            Assert.All(regularRequesters.Items, item => Assert.Contains(allowedAssignments,
                access => access.PkidPersona == item.PkidPersona && access.PkidArea == item.PkidArea));
            requesterContext.Administrator = true;
            requesterContext.CompanyId = int.MaxValue;
            Assert.Empty((await requisitions.GetRequestersAsync()).Items);
            requesterContext.CompanyId = 1;
            var requisition = One(await requisitions.CreateAsync(new RequisicionResponse
            {
                FkidEmpresaSis = 1, FkidAnioSis = 2026, FkidPersonaNom = fixture.PersonId,
                FkidAreaSis = budget.FkidAreaSis, Descripcion = run, Observaciones = run,
                FechaRequisicion = date, FechaOficio = date, Oficio = run,
                FechaRequiereInicio = date, FechaRequiereFin = date.AddDays(1),
                FkidProgramaPres = budget.FkidProgramaPres,
                FkidProyectoOrco = budget.FkidPyPres,
                FkidFuenteFinanciamientoPres = budget.FkidFuenteFinanciamientoPres,
                FkidTipoGastoPres = budget.FkidTipoGastoPres,
                FkidDigitoIdentificadorPres = budget.FkidDigitoIdentificadorPres,
                FkidDestinoGastoPres = budget.FkidDestinoGastoPres,
                FkidEgresoAutorizadoPres = budget.PkidEgresoAutorizado,
                Importe = 10m, CompraDirecta = false, Activo = true
            }, 1), "requisition");
            Accepted(await scope.ServiceProvider.GetRequiredService<IRequisicionPartidaOperations>().CreateAsync(
                new RequisicionPartidaResponse
                {
                    FkidEmpresaSis = 1, FkidRequisicionOrco = requisition.PkidRequisicion,
                    FkidPartidaConta = budget.FkidPartidaConta,
                    FkidEgresoAutorizadoPres = budget.PkidEgresoAutorizado, Monto = 10m, Activo = true
                }, 1), "budget line");
            Accepted(await scope.ServiceProvider.GetRequiredService<IRequisicionDetalleOperations>().CreateAsync(
                new RequisicionDetalleResponse
                {
                    FkidEmpresaSis = 1, FkidRequisicionOrco = requisition.PkidRequisicion,
                    FkidTipoBienAlma = fixture.Item.PkidTipoBien,
                    FkidUnidadesAlma = fixture.Item.FkidUnidadesAlma, Cantidad = 1m, Activo = true
                }, 1), "requested item");

            var providers = await context.Proveedors.Where(item => item.Activo).Take(3)
                .Select(item => item.PkidProveedor).ToArrayAsync();
            Assert.Equal(3, providers.Length);
            var quotations = scope.ServiceProvider.GetRequiredService<ICotizacionAppService>();
            var quotes = new List<CotizacionResponse>();
            foreach (var supplier in providers)
            {
                var quote = One(await quotations.CreateAsync(new CotizacionResponse
                {
                    FkidRequisicionOrco = requisition.PkidRequisicion, FkidProveedorSis = supplier,
                    FechaSolicitud = date, FechaProveedorCotiza = date, Activo = true
                }, 1), "quotation");
                Assert.True(quote.PkidCotizacion > 0);
                quotes.Add(quote);
                var line = await context.CotizacionDetalles.AsNoTracking().SingleAsync(
                    item => item.FkidCotizacionOrco == quote.PkidCotizacion && item.Activo);
                Accepted(await quotations.SaveRecepcionCotizacionAsync(new CotizacionRecepcionRequest
                {
                    FkidCotizacionOrco = quote.PkidCotizacion,
                    Items = [new() { PkidCotizacionDetalle = line.PkidCotizacionDetalle, PrecioUnitario = 10m }]
                }, 1), "quotation prices");
            }
            var sufficiency = One(await scope.ServiceProvider.GetRequiredService<ISolicitudSuficienciaAppService>()
                .GenerarDesdeRequisicionAsync(new SolicitudSuficienciaGenerarRequest
                {
                    FkidRequisicionOrco = requisition.PkidRequisicion,
                    FechaSolicitud = DateOnly.FromDateTime(date), Justificacion = run
                }, 1), "sufficiency request");
            var authorization = One(await scope.ServiceProvider
                .GetRequiredService<IAdquisicionCrudAppService<AutorizacionSuficienciaResponse>>()
                .CreateAsync(new AutorizacionSuficienciaResponse
                {
                    FkidEmpresaSis = 1, FkidAnioSis = 2026,
                    FkidSolicitudSuficienciaPres = sufficiency.PkidSolicitudSuficiencia,
                    FkidRequisicionOrco = requisition.PkidRequisicion,
                    FechaSolicitud = DateOnly.FromDateTime(date), FechaAutorizacion = DateOnly.FromDateTime(date),
                    AutorizadoPorNom = fixture.PersonId, Justificacion = run, Activo = true
                }, 1), "sufficiency authorization");
            var amount = await context.SolicitudSuficienciaDetalles.AsNoTracking()
                .Where(item => item.FkidSolicitudSuficienciaPres == sufficiency.PkidSolicitudSuficiencia)
                .SumAsync(item => item.Total ?? 0m);
            var commitments = scope.ServiceProvider.GetRequiredService<IEstadoContratoAppService>();
            var commitment = One(await commitments.CreateAsync(new EstadoContratoResponse
            {
                FkidEmpresaSis = 1, FkidAnioSis = 2026,
                FkidAutorizacionSuficienciaPres = authorization.PkidAutorizacionSuficiencia,
                FkidSolicitudSuficienciaPres = sufficiency.PkidSolicitudSuficiencia,
                FkidRequisicionOrco = requisition.PkidRequisicion, FkidProveedorSis = providers[0],
                NumeroContrato = run, Descripcion = run, FechaContrato = DateOnly.FromDateTime(date),
                MontoTotal = amount, Activo = true
            }, 1), "budget commitment");
            One(await commitments.AutorizarAsync(commitment.PkidContrato, 1), "commitment authorization");
            var orders = scope.ServiceProvider.GetRequiredService<IOrdenCompraAppService>();
            var order = One(await orders.CreateAsync(new OrdenCompraResponse
            {
                FkidEmpresaSis = 1, FkidRequisicionOrco = requisition.PkidRequisicion,
                FkidCotizacionOrco = quotes[0].PkidCotizacion, FkidProveedorSis = providers[0],
                Descripcion = run, FechaOrdenCompra = date, Activo = true
            }, 1), "purchase order");
            var selectedQuoteLine = await context.CotizacionDetalles.AsNoTracking()
                .SingleAsync(item => item.FkidCotizacionOrco == quotes[0].PkidCotizacion && item.Activo);
            Accepted(await scope.ServiceProvider.GetRequiredService<IOrdenCompraDetalleOperations>()
                .CreateAsync(new OrdenCompraDetalleResponse
                {
                    FkidOrdenCompraOrco = order.PkidOrdenCompra,
                    FkidRequisicionDetalleOrco = selectedQuoteLine.FkidRequisicionDetalleOrco,
                    FkidCotizacionDetalleOrco = selectedQuoteLine.PkidCotizacionDetalle,
                    FkidTipoBienAlma = fixture.Item.PkidTipoBien,
                    FkidUnidadesAlma = fixture.Item.FkidUnidadesAlma!.Value,
                    CantidadSolicitada = 1m, PrecioUnitario = 10m, Activo = true
                }, 1), "order item");
            Accepted(await scope.ServiceProvider.GetRequiredService<IOrdenCompraPartidaOperations>()
                .CreateAsync(new OrdenCompraPartidaResponse
                {
                    FkidOrdenCompraOrco = order.PkidOrdenCompra, FkidPartidaConta = budget.FkidPartidaConta,
                    FkidFuenteFinanciamientoPres = budget.FkidFuenteFinanciamientoPres,
                    Importe = 10m, Activo = true
                }, 1), "order budget line");
            One(await orders.AutorizarAsync(order.PkidOrdenCompra, 1), "order authorization");
            var orderLine = await context.OrdenCompraDetalles.AsNoTracking()
                .SingleAsync(item => item.FkidOrdenCompraOrco == order.PkidOrdenCompra && item.Activo);
            var receipt = One(await scope.ServiceProvider.GetRequiredService<IAlmacenOperations>()
                .CreateAsync(new AlmacenResponse
                {
                    FkidEmpresaSis = 1, FkidAnioSis = 2026, FkidAreaSis = budget.FkidAreaSis,
                    FkidTipoBienAlma = fixture.Item.PkidTipoBien,
                    FkidUnidadesAlma = fixture.Item.FkidUnidadesAlma,
                    FkidDetalleOrdenCompraOrco = orderLine.PkidOrdenCompraDetalle,
                    Cantidad = 1m, CostoUnitario = 10m, FechaEntrada = date, Activo = true,
                    Factura = run, AplicaAlmacen = true
                }, 1), "warehouse receipt");
            Assert.True(receipt.PkidAlmacen > 0);
            Assert.Equal(1m, await context.OrdenCompraDetalles.AsNoTracking()
                .Where(item => item.PkidOrdenCompraDetalle == orderLine.PkidOrdenCompraDetalle)
                .Select(item => item.CantidadRecibida).SingleAsync());
            var outboundRequests = scope.ServiceProvider.GetRequiredService<ISolicitudSalidaOperations>();
            var rejectedFolio = await outboundRequests.CreateAsync(new SolicitudSalidaResponse
            {
                FkidEmpresaSis = 1, FkidAnioSis = 2026,
                FkidAreaSolicitaSis = budget.FkidAreaSis, FkidAreaEntregaSis = budget.FkidAreaSis,
                Folio = run, FechaSolicitud = date, Solicitante = run, Justificacion = run, Activo = true
            }, 1);
            Assert.False(rejectedFolio.Success);
            Assert.Equal("VALIDATION", rejectedFolio.Code);
            Assert.DoesNotContain("GestionEmpresarial", rejectedFolio.Message);
            var outbound = One(await outboundRequests.CreateAsync(new SolicitudSalidaResponse
            {
                FkidEmpresaSis = 1, FkidAnioSis = 2026,
                FkidAreaSolicitaSis = budget.FkidAreaSis, FkidAreaEntregaSis = budget.FkidAreaSis,
                Folio = string.Empty, FechaSolicitud = date, Solicitante = run, Justificacion = run, Activo = true
            }, 1), "warehouse outbound request");
            var outboundItems = scope.ServiceProvider.GetRequiredService<IDetalleSolicitudSalidaOperations>();
            var outboundItem = One(await outboundItems.CreateAsync(new DetalleSolicitudSalidaResponse
            {
                FkidSolicitudSalidaAlma = outbound.PkidSolicitudSalida, FkidAlmacenAlma = receipt.PkidAlmacen,
                FkidTipoBienAlma = fixture.Item.PkidTipoBien, FkidUnidadesAlma = fixture.Item.FkidUnidadesAlma,
                CantidadSolicitada = 1m, CantidadAutorizada = 1m, Activo = true
            }, 1), "outbound requested item");
            One(await outboundRequests.AutorizarAsync(outbound.PkidSolicitudSalida, 1), "outbound authorization");
            outboundItem.CantidadEntregada = 1m;
            One(await outboundItems.ActualizarEntregaAsync(outboundItem.PkidDetalleSolicitudSalida, outboundItem, 1),
                "delivery and accounting");
            var ledgerId = await context.SolicitudSalida.AsNoTracking()
                .Where(item => item.PkidSolicitudSalida == outbound.PkidSolicitudSalida)
                .Select(item => item.FkidPolizaConta).SingleAsync();
            Assert.True(ledgerId > 0, "Completed delivery must persist its accounting document.");
            var ledgerLines = await context.PolizaDetalles.AsNoTracking()
                .Where(item => item.FkidPolizaConta == ledgerId && item.Activo).ToListAsync();
            Assert.NotEmpty(ledgerLines);
            Assert.True(ledgerLines.Sum(item => item.ImporteDebe ?? 0m) > 0m);
            Assert.Equal(ledgerLines.Sum(item => item.ImporteDebe ?? 0m),
                ledgerLines.Sum(item => item.ImporteHaber ?? 0m));
            await transaction.RollbackAsync();
        }
        context.ChangeTracker.Clear();
        Assert.False(await context.Requisicions.AnyAsync(item => item.Descripcion == run));
        Assert.False(await context.OrdenCompras.AnyAsync(item => item.Descripcion == run));
        Assert.False(await context.SolicitudSalida.AnyAsync(item => item.Justificacion == run));
        Assert.False(await context.Almacens.AnyAsync(item => item.Factura == run));
    }

    private static void Accepted<T>(PagedResult<T> result, string stage) => Assert.True(result.Success, $"{stage}: {result.Code} {result.Message}");

    private static T One<T>(PagedResult<T> result, string stage) where T : class
    {
        var diagnostics = result.Success ? string.Empty : string.Join("\n", log4net.LogManager.GetRepository()
            .GetAppenders().OfType<log4net.Appender.MemoryAppender>()
            .SelectMany(appender => appender.GetEvents()).Select(item => item.RenderedMessage));
        Assert.True(result.Success, $"{stage}: {result.Code} {result.Message}\n{diagnostics}");
        return result.Data ?? Assert.Single(result.Items);
    }

    private sealed class NoExternalEmail : IEmailOperations
    {
        public Task<PagedResult<EmailSendResponse>> SendAsync(EmailMessageRequest request,
            CancellationToken cancellationToken = default) =>
            throw new InvalidOperationException("This database test must never send external email.");
    }

    private sealed class UnlicensedFixture : ILicenseRuntimeState
    {
        public LicenseDecision Evaluate(string moduleCode, DateTimeOffset? utcNow = null) =>
            new(false, moduleCode, "TEST", "No activation is performed by this test.");
        public void Replace(LicenseRuntimeSnapshot snapshot) => throw new NotSupportedException();
        public LicenseSnapshotResponse GetSnapshot(DateTimeOffset? utcNow = null) => throw new NotSupportedException();
        public LicenseRuntimeSnapshot GetRuntimeSnapshot() => throw new NotSupportedException();
    }

    private sealed class DevelopmentAdministrator : IUserContextService
    {
        public bool Administrator { get; set; } = true;
        public int CompanyId { get; set; } = 1;
        public int GetCurrentUserId() => 1;
        public int? TryGetCurrentUserId() => 1;
        public int GetCurrentEmpresaId() => CompanyId;
        public int? TryGetCurrentEmpresaId() => CompanyId;
        public int GetCurrentAnioPresupuestalId() => 2026;
        public int? TryGetCurrentAnioPresupuestalId() => 2026;
        public ClaimsPrincipal GetUserPrincipal() => new(new ClaimsIdentity([
            new Claim(ClaimTypes.NameIdentifier, "1"), new Claim(ClaimTypes.Role, Administrator ? "SuperAdmin" : "User")], "DevelopmentTest"));
    }
}
