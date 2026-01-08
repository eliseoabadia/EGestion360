
using EG.Infraestructure.Models;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;


using Const = EG.Common.Constants;

namespace EG.Infrastructure
{
    public static class DbContextExtensions
    {
        public static IServiceCollection AddDbContextGRP(this IServiceCollection services, IConfiguration configuration)
        {

            var BD_CON = configuration.GetConnectionString(Const.BD_CON);

            services.AddDbContext<EGestionContext>(option => option.UseSqlServer(BD_CON));


            services.AddScoped<EGestionContextProcedures>(provider => new EGestionContextProcedures(provider.GetRequiredService<EGestionContext>()));

            return services;
        }


    }
}