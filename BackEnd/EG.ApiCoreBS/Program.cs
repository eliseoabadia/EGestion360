using AutoMapper;
using EG.ApiCoreBS.Extensions;
using EG.Business.Mapping.General;
using EG.Business.Services;
using EG.Common.GenericModel;
using EG.Domain.Interfaces;
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

//// ===== SERVICIOS GENÉRICOS =====
builder.Services.AddScoped(typeof(GenericService<,,>));
builder.Services.AddScoped(typeof(IRepository<>), typeof(Repository<>));


builder.Services.AddControllers().AddJsonOptions(options =>
{
    options.JsonSerializerOptions.PropertyNamingPolicy = null;
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

// No duplicar AddControllers ni AddOpenApi

//CORS
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowAllOrigins", policy =>
    {
        policy
            .AllowAnyOrigin() // Si necesitas credenciales, usa .WithOrigins("https://tudominio.com") y .AllowCredentials()
            .AllowAnyMethod()
            .AllowAnyHeader();
        // .AllowCredentials(); // Solo si usas orígenes explícitos
    });
});

builder.Services.AddControllers();
// Learn more about configuring OpenAPI at https://aka.ms/aspnet/openapi
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
app.UseCors("AllowAllOrigins");

// Habilitar autenticación antes de autorización
app.UseAuthentication();
app.UseAuthorization();

app.MapControllers();

app.Run();