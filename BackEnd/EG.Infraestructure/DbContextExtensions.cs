
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

            services.AddDbContextPool<EGestionContext>(options =>
                options.UseSqlServer(BD_CON, sqlOptions =>
                    sqlOptions.EnableRetryOnFailure(
                        maxRetryCount: 3,
                        maxRetryDelay: TimeSpan.FromSeconds(5),
                        errorNumbersToAdd: null)));


            services.AddScoped<EGestionContextProcedures>(provider => new EGestionContextProcedures(provider.GetRequiredService<EGestionContext>()));

            return services;
        }


    }
}
