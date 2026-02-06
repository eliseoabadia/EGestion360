using EG.Application.CommonModel;
using EG.Application.Interfaces;
using EG.Application.Services;
using EG.Business.Interfaces;
using EG.Business.Mapping;
using EG.Business.Services;
using EG.Common.Util;
using EG.Domain.DTOs.Responses.General;
using EG.Domain.Entities;
using EG.Domain.Interfaces;
using EG.Filters;
using EG.Infrastructure;
using EG.Logger;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using System.Text;

public partial class Program
{
    private static void Main(string[] args)
    {
        var builder = WebApplication.CreateBuilder(args);

        //automapper
        builder.Services.AddAutoMapper(cfg => cfg.AddProfile<MappingProfile>());

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
        //builder.Services.AddDbContextGRP(configuration);

        //repositories
        builder.Services.AddScoped<IRepository<Usuario>, Repository<Usuario>>();
        builder.Services.AddScoped<IRepositorySP<LoginInformationEmployeeResult>, RepositorySP<LoginInformationEmployeeResult>>();
        builder.Services.AddScoped<IRepositorySP<spNodeMenuResult>, RepositorySP<spNodeMenuResult>>();
        builder.Services.AddScoped<IRepository<PerfilUsuario>, Repository<PerfilUsuario>>();
        //builder.Services.AddScoped<IRepository<Empresa>, Repository<Empresa>>();


        builder.Services.AddScoped<IRepository<Departamento>, Repository<Departamento>>();
       


        //services (business / application)
        builder.Services.AddScoped<IAuthService, AuthService>();
        builder.Services.AddScoped<ITokenService, TokenService>();
        //builder.Services.AddScoped<IEmpresaService, EmpresaService>();
        builder.Services.AddScoped<INavigateService, NavigateService>();
        builder.Services.AddScoped<IUserIpService, UserIpService>();
        builder.Services.AddScoped<IUserProfileService, UserProfileService>();
        builder.Services.AddScoped<IEmployeeService, EmployeeService>();


        // Registrar GenericService abierto (open generic)
        builder.Services.AddScoped(typeof(GenericService<,,>));

        // Registrar repositorios genéricos
        builder.Services.AddScoped(typeof(IRepository<>), typeof(Repository<>));

        builder.Services.AddControllers().AddJsonOptions(options =>
        {
            options.JsonSerializerOptions.PropertyNamingPolicy = null;
        });
        // Learn more about configuring OpenAPI at https://aka.ms/aspnet/openapi
        builder.Services.AddOpenApi();

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

        builder.Services.AddScoped<InitializeUserFilter>();

        builder.Services.AddMemoryCache();

        builder.Services.AddControllers();
        // Learn more about configuring OpenAPI at https://aka.ms/aspnet/openapi
        builder.Services.AddOpenApi();

        //CORS
        builder.Services.AddCors(options =>
        {
            options.AddPolicy("AllowAllOrigins", policy =>
            {
                policy.WithOrigins("https://localhost:7279") // origen del WASM/DevServer
              .AllowAnyMethod()
              .AllowAnyHeader()
              .AllowCredentials(); // si usas credenciales; si no, quitar
            });
        });

        var app = builder.Build();

        // Configure the HTTP request pipeline.
        if (app.Environment.IsDevelopment())
        {
            app.MapOpenApi();
            //app.UseSwagger();
            //app.UseSwaggerUI();
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
    }
}