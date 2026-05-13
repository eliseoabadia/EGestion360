using AutoMapper;
using EG.ApiCoreBS.Extensions;
using EG.Business.Mapping.General;
using EG.Common.GenericModel;
using EG.Infrastructure;
using EG.Logger;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.IdentityModel.Tokens;
using System.Text;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.

builder.Services.AddAutoMapper(cfg =>
{
    var businessAssembly = typeof(EmpresaMappingProfile).Assembly;

    var profiles = businessAssembly.GetTypes()
                                   .Where(t => typeof(Profile).IsAssignableFrom(t) &&
                                               !t.IsAbstract &&
                                               t.Namespace != null &&
                                               t.Namespace.Contains("EG.Business.Mapping"));

    foreach (var profile in profiles)
    {
        cfg.AddProfile(profile);
    }
});

builder.WebHost.ConfigureKestrel(options =>
{
    //options.Limits.MaxRequestHeadersTotalSize = 262144; // 256KB
    //options.Limits.MaxRequestHeadersTotalSize = 524288; // 512KB
    //options.Limits.MaxRequestHeadersTotalSize = 1048576; // 1024KB (1MB)
});

builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowFrontend", policy =>
    {
        policy.WithOrigins("https://localhost:7279", "http://localhost:5242") // tus frontends
              .AllowAnyMethod()
              .AllowAnyHeader()
              .AllowCredentials(); // solo si usas cookies/JWT en header
    });
});



builder.Services.Configure<JwtSettings>(builder.Configuration.GetSection("JsonWebTokenKeys"));

//contexto de datos
var environmentName = Environment.GetEnvironmentVariable("ASPNETCORE_ENVIRONMENT") ?? "Development";

var configuration = new ConfigurationBuilder()
    .SetBasePath(AppContext.BaseDirectory)
    .AddJsonFile("appsettings.json", optional: true, reloadOnChange: true)
    .AddJsonFile($"appsettings.{environmentName}.json", optional: true, reloadOnChange: true)
    .Build();

builder.Services.AddLoggerGRP(configuration);

builder.Services.AddDbContextGRP(configuration);

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
    // Evita colisiones de tipos genéricos en Swagger
    c.CustomSchemaIds(type =>
    {
        if (type.IsGenericType)
        {
            var genericTypeName = type.GetGenericTypeDefinition().Name;
            genericTypeName = genericTypeName.Contains('`') ? genericTypeName.Substring(0, genericTypeName.IndexOf('`')) : genericTypeName;
            var genericArgs = string.Join("_", type.GetGenericArguments().Select(t => t.Name));
            return $"{genericTypeName}_{genericArgs}";
        }
        return type.Name;
    });
});

// For authentication
var _key = builder.Configuration["JsonWebTokenKeys:IssuerSigningKey"];
var _issuer = builder.Configuration["JsonWebTokenKeys:ValidIssuer"];
var _audience = builder.Configuration["JsonWebTokenKeys:ValidAudience"];
var _expirtyMinutes = builder.Configuration["JsonWebTokenKeys:ExpiryMinutes"];
// Configuration for token
builder.Services.AddAuthentication(x =>
{
    x.DefaultAuthenticateScheme = JwtBearerDefaults.AuthenticationScheme;
    x.DefaultChallengeScheme = JwtBearerDefaults.AuthenticationScheme;
    x.DefaultScheme = JwtBearerDefaults.AuthenticationScheme;
}).AddJwtBearer(x =>
{
    x.RequireHttpsMetadata = false;
    x.SaveToken = true;
    x.TokenValidationParameters = new TokenValidationParameters()
    {
        ValidateIssuer = true,
        ValidateAudience = true,
        ValidateLifetime = true,
        ValidateIssuerSigningKey = true,
        ValidAudience = _audience,
        ValidIssuer = _issuer,
        IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(_key)),
        ClockSkew = TimeSpan.FromMinutes(Convert.ToDouble(_expirtyMinutes))

    };
});

//builder.Services.AddScoped<InitializeUserFilter>();

builder.Services.AddMemoryCache();

builder.Services.AddOpenApi();

var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();

// Habilitar CORS antes de enrutar controladores para que las preflight requests reciban
// los encabezados Access-Control-Allow-*
app.UseCors("AllowFrontend");

// Habilitar autenticación antes de autorización
app.UseAuthentication();
app.UseAuthorization();

app.MapControllers();

app.Run();