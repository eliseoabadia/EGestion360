using EG.Common.Helper;
using EG.Web.Contracts;
using EG.Web.Models.Adquisicion;
using EG.Web.Models.Configuration;
using EG.Web.Models.ConteoCiclico;
using EG.Web.Models.Patrimonio;
using EG.Web.Services;
using Microsoft.JSInterop;
using EG.Domain.DTOs.Responses.Contabilidad;
using EG.Domain.DTOs.Responses.Nomina;

namespace EG.Web.Extensions;

public static class ApiServiceExtensions
{
    public static IServiceCollection AddApiServices(this IServiceCollection services)
    {
        // Registro de dependencias base necesarias
        // services.AddHttpClient(); 

        // Registro de los CRUDs específicos
        RegisterCrud<DepartamentoResponse>(services, "api/Departamento");
        RegisterCrud<UsuarioResponse>(services, "api/Usuario");
        RegisterCrud<EstadoResponse>(services, "api/Estado");
        RegisterCrud<EmpresaResponse>(services, "api/Empresa");
        RegisterCrud<MenuItemsResponse>(services, "api/Menu");
        RegisterCrud<UsuarioSucursalResponse>(services, "api/UsuarioSucursal");
        RegisterCrud<SucursalResponse>(services, "api/Sucursal");

        RegisterCrud<PeriodoConteoResponse>(services, "api/PeriodoConteo");
        RegisterCrud<ConteoResponse>(services, "api/Conteo");
        RegisterCrud<ConteoDetalleEscaneoResponse>(services, "api/ConteoDetalleEscaneo");
        RegisterCrud<ConteoDetalleResponse>(services, "api/ConteoDetalle");
        RegisterCrud<BienBusquedaResponse>(services, "api/ConteoDetalle");
   
        //RegisterCrud<ArticuloConteoResponse>(services, "api/ArticuloConteo");
        //RegisterCrud<RegistroConteoResponse>(services, "api/RegistroConteo");
        //RegisterCrud<EstatusPeriodoResponse>(services, "api/EstatusPeriodo");
        //RegisterCrud<EstatusArticuloConteoResponse>(services, "api/EstatusArticuloConteo");
        //RegisterCrud<TipoConteoResponse>(services, "api/TipoConteo");

RegisterCrud<FamiliaResponse>(services, "api/Familia");
//RegisterCrud<UnidadResponse>(services, "api/Unidad");
//RegisterCrud<TipoBienResponse>(services, "api/TipoBien");
//RegisterCrud<BienResponse>(services, "api/Bien");

        // Catálogos de Adquisiciones
        RegisterCrud<ModalidadResponse>(services, "api/Modalidad");
        RegisterCrud<TipoContratoResponse>(services, "api/TipoContrato");
        RegisterCrud<TipoDocumentoResponse>(services, "api/TipoDocumento");
        RegisterCrud<TipoGarantiaResponse>(services, "api/TipoGarantia");
        RegisterCrud<ProcedimientoContratacionResponse>(services, "api/ProcedimientoContratacion");
        RegisterCrud<EstatusRequisicionResponse>(services, "api/EstatusRequisicion");
        RegisterCrud<ArticuloResponse>(services, "api/Articulo");
        RegisterCrud<FraccionResponse>(services, "api/Fraccion");
        RegisterCrud<ProveedorResponse>(services, "api/Proveedor");
        
        // Catálogos de Contabilidad
        RegisterCrud<ContaTipoDoctoPagoResponse>(services, "api/ContaTipoDoctoPago");
        
        // Catálogos de Patrimonio
        RegisterCrud<GrupoBienResponse>(services, "api/GrupoBien");
        RegisterCrud<TipoPatrimonioResponse>(services, "api/TipoPatrimonio");
        RegisterCrud<TipoAdquisicionResponse>(services, "api/TipoAdquisicion");
        RegisterCrud<MarcaResponse>(services, "api/Marca");
        RegisterCrud<PersonaResponse>(services, "api/Persona");

        return services;
    }

    private static void RegisterCrud<TResponse>(IServiceCollection services, string endpoint)
        where TResponse : class
    {
        services.AddScoped<IGenericCrudService<TResponse>>(sp =>
            new GenericCrudService<TResponse>(
                sp.GetRequiredService<IConfiguration>(),
                sp.GetRequiredService<HttpClient>(),
                sp.GetRequiredService<IJSRuntime>(),
                sp.GetRequiredService<ApplicationInstance>(),
                endpoint
            ));
    }
}
