using EG.ApiCoreBS.Extensions;
using EG.ApiCoreBS.Auth;
using EG.ApiCoreBS.Filters;
using EG.ApiCoreBS.Middleware;
using EG.ApiCoreBS.Reporting;
using EG.Business.Mapping.General;
using EG.Common.GenericModel;
using EG.Domain.Platform.Settings;
using EG.Domain.Settings;
using EG.Infrastructure;
using EG.Logger;
using DevExpress.AspNetCore;
using DevExpress.AspNetCore.Reporting;
using DevExpress.XtraReports.Services;
using DevExpress.XtraReports.Web.Extensions;
using Mapster;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.RateLimiting;
using Microsoft.AspNetCore.ResponseCompression;
using Microsoft.IdentityModel.Tokens;
using System.IO.Compression;
using System.Threading.RateLimiting;
using System.Text;

var logger = LoggerFactory.Create(config =>
{
    config.AddConsole();
    config.AddDebug();
}).CreateLogger("Startup");

try
{
    logger.LogInformation("=== INICIANDO APLICACION ===");

    var builder = WebApplication.CreateBuilder(args);

    TypeAdapterConfig.GlobalSettings.Scan(typeof(EmpresaMappingProfile).Assembly);

    var corsOrigins = builder.Configuration.GetSection("CorsSettings:AllowOrigins").Get<string[]>() ?? [];
    builder.Services.AddCors(options =>
    {
        options.AddPolicy("AllowFrontend", policy =>
        {
            if (corsOrigins.Length == 0 || corsOrigins.Contains("*"))
            {
                policy.AllowAnyOrigin()
                      .AllowAnyMethod()
                      .AllowAnyHeader();
            }
            else
            {
                policy.WithOrigins(corsOrigins)
                      .AllowAnyMethod()
                      .AllowAnyHeader();
            }
        });
    });

    logger.LogInformation("Configuracion CORS cargada. Origenes permitidos: {Origins}", string.Join(", ", corsOrigins));

    builder.Services.Configure<JwtSettings>(builder.Configuration.GetSection("JsonWebTokenKeys"));
    builder.Services.Configure<EmailSettings>(builder.Configuration.GetSection("EmailSettings"));
    builder.Services.Configure<DocumentStorageSettings>(builder.Configuration.GetSection("DocumentStorage"));
    builder.Services.Configure<DocumentRagSettings>(builder.Configuration.GetSection("DocumentRag"));
    builder.Services.AddHttpClient();
    builder.Services.Configure<FirmaDocumentalSettings>(builder.Configuration.GetSection("FirmaDocumental"));
    builder.Services.AddLoggerGRP(builder.Configuration);
    builder.Services.AddDbContextGRP(builder.Configuration);
    builder.Services.AddApplicationServices(typeof(Program).Assembly);
    builder.Services.AddDevExpressControls();
    builder.Services.ConfigureReportingServices(configurator =>
    {
        configurator.ConfigureReportDesigner(designer =>
        {
            designer.RegisterDataSourceWizardConfigFileConnectionStringsProvider();
        });
    });
    builder.Services.AddScoped<IReportProvider, GenericReportProvider>();
    builder.Services.AddSingleton<ReportConnectionConfigurator>();
    builder.Services.AddScoped<ReportContextParameterConfigurator>();
    builder.Services.AddSingleton<StoredProcedureReportRegistry>();
    builder.Services.AddSingleton<StoredProcedureReportFactory>();
    builder.Services.AddScoped<ReportLogoConfigurator>();
    builder.Services.AddScoped<ReportCompanyHeaderConfigurator>();
    builder.Services.AddSingleton<InMemoryReportStorageWebExtension>();
    builder.Services.AddSingleton<ReportStorageWebExtension>(serviceProvider =>
        serviceProvider.GetRequiredService<InMemoryReportStorageWebExtension>());

    builder.Services.AddScoped<ApiResultSanitizationFilter>();
    builder.Services.AddControllers(options =>
        {
            options.Filters.AddService<ApiResultSanitizationFilter>();
        })
        .AddJsonOptions(options =>
        {
            options.JsonSerializerOptions.PropertyNamingPolicy = null;
            options.JsonSerializerOptions.PropertyNameCaseInsensitive = true;
        })
        .ConfigureApiBehaviorOptions(options =>
        {
            options.SuppressModelStateInvalidFilter = true;
        });

    builder.Services.AddSwaggerGen(c =>
    {
        // Existen DTO con el mismo nombre en modulos distintos (por ejemplo,
        // Patrimonio.BienResponse y ConteoCiclico.BienResponse). Usar solo
        // Type.Name provoca colisiones y hace que /swagger/v1/swagger.json
        // responda 500. El identificador incluye namespace y argumentos
        // genericos de forma recursiva para mantenerlo estable y unico.
        c.CustomSchemaIds(GetSwaggerSchemaId);
    });

    var key = builder.Configuration["JsonWebTokenKeys:IssuerSigningKey"];
    var issuer = builder.Configuration["JsonWebTokenKeys:ValidIssuer"];
    var audience = builder.Configuration["JsonWebTokenKeys:ValidAudience"];
    var clockSkewMinutes = builder.Configuration.GetValue<double?>("JsonWebTokenKeys:ClockSkewMinutes") ?? 1d;
    clockSkewMinutes = Math.Clamp(clockSkewMinutes, 0d, 5d);

    builder.Services.AddAuthentication(x =>
    {
        x.DefaultAuthenticateScheme = JwtBearerDefaults.AuthenticationScheme;
        x.DefaultChallengeScheme = JwtBearerDefaults.AuthenticationScheme;
        x.DefaultScheme = JwtBearerDefaults.AuthenticationScheme;
    }).AddJwtBearer(x =>
    {
        x.RequireHttpsMetadata = !builder.Environment.IsDevelopment();
        x.SaveToken = true;
        x.TokenValidationParameters = new TokenValidationParameters
        {
            ValidateIssuer = true,
            ValidateAudience = true,
            ValidateLifetime = true,
            ValidateIssuerSigningKey = true,
            ValidAudience = audience,
            ValidIssuer = issuer,
            IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(key)),
            // La tolerancia de reloj no debe reutilizar la vigencia del token: hacerlo
            // prolonga accidentalmente sesiones que ya expiraron.
            ClockSkew = TimeSpan.FromMinutes(clockSkewMinutes)
        };
    });

    builder.Services.AddMemoryCache();
    builder.Services.AddRateLimiter(options =>
    {
        options.RejectionStatusCode = StatusCodes.Status429TooManyRequests;
        options.AddPolicy("login", context =>
            RateLimitPartition.GetFixedWindowLimiter(
                partitionKey: context.Connection.RemoteIpAddress?.ToString() ?? "unknown",
                factory: _ => new FixedWindowRateLimiterOptions
                {
                    PermitLimit = 10,
                    Window = TimeSpan.FromMinutes(1),
                    QueueLimit = 0,
                    AutoReplenishment = true
                }));
        options.OnRejected = async (context, cancellationToken) =>
        {
            var rateLimitLogger = context.HttpContext.RequestServices
                .GetRequiredService<ILoggerFactory>()
                .CreateLogger("LoginRateLimit");
            rateLimitLogger.LogWarning(
                "Solicitud limitada. TraceId={TraceId}; Path={Path}; ClientIp={ClientIp}",
                context.HttpContext.TraceIdentifier,
                context.HttpContext.Request.Path,
                context.HttpContext.Connection.RemoteIpAddress?.ToString() ?? "unknown");

            context.HttpContext.Response.ContentType = "application/problem+json";
            await context.HttpContext.Response.WriteAsJsonAsync(new
            {
                success = false,
                code = "RATE_LIMITED",
                message = "Demasiados intentos. Intente nuevamente más tarde.",
                traceId = context.HttpContext.TraceIdentifier
            }, cancellationToken);
        };
    });
    builder.Services.AddResponseCompression(options =>
    {
        options.EnableForHttps = true;
        options.Providers.Add<BrotliCompressionProvider>();
        options.Providers.Add<GzipCompressionProvider>();
        options.MimeTypes = ResponseCompressionDefaults.MimeTypes.Concat(
        [
            "application/json",
            "application/problem+json"
        ]);
    });
    builder.Services.Configure<BrotliCompressionProviderOptions>(options =>
        options.Level = CompressionLevel.Fastest);
    builder.Services.Configure<GzipCompressionProviderOptions>(options =>
        options.Level = CompressionLevel.Fastest);
    builder.Services.AddAuthorization(options =>
    {
        // Denegación por defecto: todo endpoint requiere identidad autenticada,
        // salvo que declare explícitamente [AllowAnonymous].
        options.FallbackPolicy = new AuthorizationPolicyBuilder()
            .RequireAuthenticatedUser()
            .Build();
    });
    builder.Services.AddSingleton<IAuthorizationPolicyProvider, PermissionPolicyProvider>();
    builder.Services.AddScoped<IAuthorizationHandler, PermissionAuthorizationHandler>();
    builder.Services.AddOpenApi();

    var app = builder.Build();

    if (app.Environment.IsDevelopment())
    {
        app.UseSwagger();
        app.UseSwaggerUI();
    }

    if (!app.Environment.IsDevelopment())
    {
        app.UseHsts();
        app.UseHttpsRedirection();
    }

    app.Use(async (context, next) =>
    {
        context.Response.OnStarting(() =>
        {
            var headers = context.Response.Headers;
            headers["X-Content-Type-Options"] = "nosniff";
            headers["X-Frame-Options"] = "DENY";
            headers["Referrer-Policy"] = "no-referrer";
            headers["Permissions-Policy"] = "camera=(), microphone=(), geolocation=(), payment=()";
            headers["Content-Security-Policy"] = "default-src 'none'; frame-ancestors 'none'; base-uri 'none'; form-action 'none'";
            headers["Cache-Control"] = "no-store";
            return Task.CompletedTask;
        });

        await next(context);
    });

    app.UseResponseCompression();
    app.UseCors("AllowFrontend");
    app.UseMiddleware<ApiExceptionMiddleware>();
    app.UseMiddleware<RequestPerformanceMiddleware>();
    app.UseRateLimiter();
    app.UseDevExpressControls();
    app.UseAuthentication();
    app.UseAuthorization();
    app.MapMethods("/api/Navigate/ping", ["GET", "POST"], () =>
        Results.Ok(new { success = true, message = "pong" })).AllowAnonymous();
    app.MapGet("/api/Navigate/version", (IConfiguration configuration) =>
        Results.Ok(new
        {
            success = true,
            version = configuration["ApplicationVersion"] ?? "1.0.0"
        })).AllowAnonymous();
    app.MapControllers();

    logger.LogInformation("Aplicacion iniciada correctamente en {Urls}", string.Join(", ", app.Urls));
    app.Run();
}
catch (Exception ex)
{
    logger.LogCritical(ex, "ERROR FATAL al iniciar la aplicacion: {Mensaje}", ex.Message);
    throw;
}

static string GetSwaggerSchemaId(Type type)
{
    if (!type.IsGenericType)
    {
        return (type.FullName ?? type.Name)
            .Replace('.', '_')
            .Replace('+', '_');
    }

    var definition = type.GetGenericTypeDefinition();
    var definitionName = definition.Name;
    var tickIndex = definitionName.IndexOf('`');
    if (tickIndex >= 0)
    {
        definitionName = definitionName[..tickIndex];
    }

    var namespacePrefix = string.IsNullOrWhiteSpace(definition.Namespace)
        ? string.Empty
        : definition.Namespace.Replace('.', '_') + "_";
    var arguments = string.Join("_", type.GetGenericArguments().Select(GetSwaggerSchemaId));
    return $"{namespacePrefix}{definitionName}_{arguments}";
}
