using AutoMapper;
using EG.ApiCore.Services;
using EG.Business.Interfaces;
using EG.Business.Mapping.General;
using EG.Business.Services;
using EG.Common.GenericModel;
using EG.Common.Util;
using EG.Domain.Interfaces;
using EG.Logger;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.IdentityModel.Tokens;
using System.Text;
using EG.Infrastructure;
using EG.Infraestructure.Models;
using EG.Application.Interfaces.Account;
using EG.Application.Services.Account;
using EG.Application.Interfaces.General;
using EG.Application.Services.General;
using EG.Application.Interfaces.ConteoCiclico;
using EG.Application.Services.ConteoCiclico;
using EG.Application.Interfaces;
using EG.Application.Services;

public partial class Program
{
    private static void Main(string[] args)
    {
        var builder = WebApplication.CreateBuilder(args);

        ////automapper
        ////builder.Services.AddAutoMapper(cfg => cfg.AddProfile<MappingProfile>());
        //builder.Services.AddAutoMapper(cfg =>
        //{
        //    cfg.AddProfile<EmpresaMappingProfile>();
        //    cfg.AddProfile<DepartamentoMappingProfile>();
        //    cfg.AddProfile<GeneralMappingProfile>();
        //    cfg.AddProfile<UsuarioMappingProfile>();
        //    cfg.AddProfile<SucursalMappingProfile>();
        //    cfg.AddProfile<MenuMappingProfile>();
        //    cfg.AddProfile<AspNetRoleMappingProfile>();
        //    cfg.AddProfile<UsuarioSucursalMappingProfile>();
        //    cfg.AddProfile<PeriodoConteoMappingProfile>();



        //}, typeof(Program).Assembly);

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


        // ===== REPOSITORIES (IRepositorySP) =====
        builder.Services.AddScoped<IRepositorySP<LoginInformationEmployeeResult>, RepositorySP<LoginInformationEmployeeResult>>();
        builder.Services.AddScoped<IRepositorySP<spGetClaimsByUserResult>, RepositorySP<spGetClaimsByUserResult>>();  // ✅ AGREGADO
        builder.Services.AddScoped<IRepositorySP<spEliminarUsuarioSucursalResult>, RepositorySP<spEliminarUsuarioSucursalResult>>();
        builder.Services.AddScoped<IRepositorySP<spNodeMenuResult>, RepositorySP<spNodeMenuResult>>();
        builder.Services.AddScoped<IRepositorySP<sp_RegistrarConteoResult>, RepositorySP<sp_RegistrarConteoResult>>();
        builder.Services.AddScoped<IRepository<PerfilUsuario>, Repository<PerfilUsuario>>();

        // ===== SERVICIOS DE APLICACIÓN - ACCOUNT =====
        builder.Services.AddScoped<IAuthAppService, AuthAppService>();
        builder.Services.AddScoped<INavigateAppService, NavigateAppService>();

        // ===== SERVICIOS DE APLICACIÓN - GENERAL =====
        builder.Services.AddScoped<IEmpresaAppService, EmpresaAppService>();
        builder.Services.AddScoped<IDepartamentoAppService, DepartamentoAppService>();

        // ===== SERVICIOS DE APLICACIÓN - CONTEO CÍCLICO =====
        builder.Services.AddScoped<IPeriodoConteoAppService, PeriodoConteoAppService>();
        builder.Services.AddScoped<IArticuloConteoAppService, ArticuloConteoAppService>();
        builder.Services.AddScoped<IRegistroConteoAppService, RegistroConteoAppService>();

        // ===== SERVICIOS GENERALES =====
        builder.Services.AddHttpContextAccessor();
        builder.Services.AddScoped<IUserContextService, UserContextService>();

        // ===== SERVICIOS DE NEGOCIO =====
        builder.Services.AddScoped<IAuthService, AuthService>();
        builder.Services.AddScoped<ITokenService, TokenService>();
        builder.Services.AddScoped<INavigateService, NavigateService>();
        builder.Services.AddScoped<IUserIpService, UserIpService>();
        builder.Services.AddScoped<IUserProfileService, UserProfileService>();
        builder.Services.AddScoped<IEmployeeService, EmployeeService>();

        // ===== SERVICIOS GENÉRICOS =====
        builder.Services.AddScoped(typeof(GenericService<,,>));
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

        //builder.Services.AddScoped<InitializeUserFilter>();

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