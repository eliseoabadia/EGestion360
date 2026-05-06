using EG.Common.Helper;
using EG.Domain.DTOs.Responses.Adquisicion;
using EG.Domain.DTOs.Responses.Almacen;
using EG.Domain.DTOs.Responses.Contabilidad;
using EG.Domain.DTOs.Responses.ConteoCiclico;
using EG.Domain.DTOs.Responses.General;
using EG.Domain.DTOs.Responses.Patrimonio;
using EG.Domain.DTOs.Responses.Presupuestales;
using EG.Domain.DTOs.Responses.Tesoreria;
using EG.Dommain.DTOs.Responses;
using EG.Web.Contracts;
using EG.Web.Models.ConteoCiclico;
using EG.Web.Models.Patrimonio;


//using EG.Web.Models.ConteoCiclico;

//using EG.Web.Models.Adquisicion;
//using EG.Web.Models.Almacen;
//using EG.Web.Models.Configuration;
//using EG.Web.Models.Configuration.Catalogo.ClavePrograma;
//using EG.Web.Models.ConteoCiclico;
//using EG.Web.Models.Patrimonio;
//using EG.Web.Models.Presupuestales;
//using EG.Web.Models.Tesoreria;
using EG.Web.Services;
using Microsoft.JSInterop;

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
        RegisterCrud<UnidadeResponse>(services, "api/Unidades");
        RegisterCrud<MotivoEsResponse>(services, "api/MotivoEs");
        RegisterCrud<EstatusSolicitudResponse>(services, "api/EstatusSol");
        // RegisterCrud<PeriodoConteoResponse>(services, "api/PeriodoConteo"); // Comentar para evitar ambigüedad

        // Catálogos de Tesorería
        RegisterCrud<TipoCambioResponse>(services, "api/TipoCambio");
        RegisterCrud<TipoInversionResponse>(services, "api/TipoInversion");
        RegisterCrud<TipoMonedaResponse>(services, "api/TipoMoneda");
        RegisterCrud<TipoPagoResponse>(services, "api/TipoPago");
        RegisterCrud<TipoPagoSFResponse>(services, "api/TipoPagoSF");
        RegisterCrud<TipoSolicitudCLCResponse>(services, "api/TipoSolicitudCLC");

        // Catálogos de Presupuestales
        RegisterCrud<GfResponse>(services, "api/Gf");
        RegisterCrud<FnResponse>(services, "api/Fn");

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

        RegisterCrud<MatrizConversionResponse>(services, "api/MatrizConversion");
        RegisterCrud<UnidadResponsableResponse>(services, "api/UnidadResponsable");
        RegisterCrud<GfResponse>(services, "api/Gf");
        RegisterCrud<FnResponse>(services, "api/Fn");
        RegisterCrud<SubFuncionResponse>(services, "api/SubFuncion");
        RegisterCrud<ActividadInstitucionalResponse>(services, "api/ActividadInstitucional");
        RegisterCrud<ProgramaPresupuestalResponse>(services, "api/ProgramaPresupuestal");
        RegisterCrud<AniosResponse>(services, "api/Anios");
        RegisterCrud<SectorResponse>(services, "api/Sector");
        RegisterCrud<TipoRecursoResponse>(services, "api/TipoRecurso");
        RegisterCrud<FuenteFinanciamientoResponse>(services, "api/FuenteFinanciamiento");
        RegisterCrud<PgResponse>(services, "api/Pg");
        RegisterCrud<RamoResponse>(services, "api/Ramo");
        RegisterCrud<ProyectoResponse>(services, "api/Proyecto");
        RegisterCrud<TipoPolizaResponse>(services, "api/TipoPoliza");
        RegisterCrud<TipoDetallePolizaResponse>(services, "api/TipoDetallePoliza");
        RegisterCrud<MatrizIngresoResponse>(services, "api/MatrizIngreso");
        RegisterCrud<ConceptoResponse>(services, "api/Concepto");
        RegisterCrud<CuentaContableResponse>(services, "api/CuentaContable");

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
