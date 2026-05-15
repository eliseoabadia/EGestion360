using EG.ApiCoreBS.Extensions;
using EG.Business.Mapping.General;
using EG.Common.GenericModel;
using EG.Infrastructure;
using EG.Logger;
using Mapster;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.IdentityModel.Tokens;
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
    builder.Services.AddLoggerGRP(builder.Configuration);
    builder.Services.AddDbContextGRP(builder.Configuration);
    builder.Services.AddApplicationServices(typeof(Program).Assembly);

    builder.Services.AddControllers()
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
        c.CustomSchemaIds(type =>
        {
            if (type.IsGenericType)
            {
                var genericTypeName = type.GetGenericTypeDefinition().Name;
                genericTypeName = genericTypeName.Contains('`')
                    ? genericTypeName[..genericTypeName.IndexOf('`')]
                    : genericTypeName;
                var genericArgs = string.Join("_", type.GetGenericArguments().Select(t => t.Name));
                return $"{genericTypeName}_{genericArgs}";
            }

            return type.Name;
        });
    });

    var key = builder.Configuration["JsonWebTokenKeys:IssuerSigningKey"];
    var issuer = builder.Configuration["JsonWebTokenKeys:ValidIssuer"];
    var audience = builder.Configuration["JsonWebTokenKeys:ValidAudience"];
    var expiryMinutes = builder.Configuration["JsonWebTokenKeys:ExpiryMinutes"];

    builder.Services.AddAuthentication(x =>
    {
        x.DefaultAuthenticateScheme = JwtBearerDefaults.AuthenticationScheme;
        x.DefaultChallengeScheme = JwtBearerDefaults.AuthenticationScheme;
        x.DefaultScheme = JwtBearerDefaults.AuthenticationScheme;
    }).AddJwtBearer(x =>
    {
        x.RequireHttpsMetadata = false;
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
            ClockSkew = TimeSpan.FromMinutes(Convert.ToDouble(expiryMinutes))
        };
    });

    builder.Services.AddMemoryCache();
    builder.Services.AddOpenApi();

    var app = builder.Build();

    if (app.Environment.IsDevelopment())
    {
        app.UseSwagger();
        app.UseSwaggerUI();
    }

    app.UseHttpsRedirection();
    app.UseCors("AllowFrontend");
    app.UseAuthentication();
    app.UseAuthorization();
    app.MapControllers();

    logger.LogInformation("Aplicacion iniciada correctamente en {Urls}", string.Join(", ", app.Urls));
    app.Run();
}
catch (Exception ex)
{
    logger.LogCritical(ex, "ERROR FATAL al iniciar la aplicacion: {Mensaje}", ex.Message);
    throw;
}
