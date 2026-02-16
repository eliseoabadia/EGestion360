//using EG.Common;
//using EG.Common.Util;
//using EG.Domain.Entities;
//using Microsoft.AspNetCore.Authorization;
//using Microsoft.AspNetCore.Mvc;
//using Microsoft.AspNetCore.Mvc.Controllers;
//using Microsoft.AspNetCore.Mvc.Filters;
//using System.Security.Claims;
//using static Dapper.SqlMapper;

//namespace EG.Filters;

//public class InitializeUserFilter : IAsyncActionFilter
//{
//    private readonly IUserIpService _userIpService;
//    //private readonly IUserData _userData;
//    //private readonly IPrivilegiosXRol _privilegiosXRol;

//    public InitializeUserFilter(IUserIpService userIpService/*, IUserData userData, IPrivilegiosXRol privilegiosXRol*/)
//    {
//        _userIpService = userIpService;
//        //_userData = userData;
//        //_privilegiosXRol = privilegiosXRol;
//    }

//    public async Task OnActionExecuting(ActionExecutingContext context)
//    {

//        if (context.Controller is BaseController controller)
//        {
//            var httpContext = context.HttpContext;
//            var claimsIdentity = httpContext.User?.Identity as ClaimsIdentity ?? throw new InvalidOperationException("User identity is not available.");
//            string IdUsuario = string.Empty;
//            if (!claimsIdentity.IsAuthenticated)
//                IdUsuario = "0";
//            else
//                IdUsuario = claimsIdentity is not null && claimsIdentity.IsAuthenticated
//                ? claimsIdentity.FindFirst(Constants.FK_IDUSUARIO)?.Value ?? ""
//                : "";


//            var ipAddress = _userIpService.GetUserIpAddress(httpContext);
//            //var (lectura, escritura) = _privilegiosXRol.GetPrivilegiosXRol(_userData.GetIdRol(claimsIdentity), controller.ControllerName);

//            controller.UserId = int.Parse(IdUsuario);
//            //controller.Lectura = lectura;
//            //controller.Escritura = escritura;
//            controller.IpAddress = ipAddress;

//            var actionName = context.ActionDescriptor.RouteValues["action"];

//            //var excludedControllers = new HashSet<string>
//            //    {
//            //        "Det",
//            //        "SICOPTB_Especificacion",
//            //        "SICOPTB_Imagen",
//            //        "PRESAdecuacionReduccion",
//            //        "PRESAdecuacionAmpliacion",
//            //        "ORCORequisicionFide",
//            //        "ORCOCotizacionFide",
//            //        "PRESVW_SolicitudSuficienciaFide",
//            //        "PRESVW_AutorizacionSuficienciaFide",
//            //        "PRESContratoFide",
//            //        "SICOPTB_Normatecnica",
//            //        "PRESFacturaFide",
//            //        "PRESVW_ClcFide",
//            //        "PRESVW_ChequeFide",
//            //        "SISVW_NotificacionesByUser",
//            //        "TESInteres",
//            //        "TESRetiro",
//            //        "TESInteresSimulador",
//            //    };

//            //if (actionName == "GetData" && !lectura && !excludedControllers.Any(controller.ControllerName.Contains))
//            //{
//            //    context.Result = new BadRequestObjectResult("NO TIENE PERMISOS PARA VISUALIZAR LA INFORMACIÓN");
//            //    return;
//            //}
            
//        }
//    }

//    public void OnActionExecuted(ActionExecutedContext context)
//    {
//        // Do nothing
//    }

//    public Task OnActionExecutionAsync(ActionExecutingContext context, ActionExecutionDelegate next)
//    {
//        // Si la acción u endpoint permite Anonymous, omitir inicialización
//        var endpoint = context.HttpContext.GetEndpoint();
//        if (endpoint != null)
//        {
//            var allowAnon = endpoint.Metadata.GetMetadata<IAllowAnonymous>();
//            if (allowAnon != null)
//            {
//                await next();
//                return;
//            }
//        }

//        // También comprobar atributos en descriptor (fallback)
//        if (context.ActionDescriptor is ControllerActionDescriptor cad)
//        {
//            if (cad.MethodInfo.GetCustomAttributes(typeof(AllowAnonymousAttribute), true).Any()
//                || cad.ControllerTypeInfo.GetCustomAttributes(typeof(AllowAnonymousAttribute), true).Any())
//            {
//                await next();
//                return;
//            }
//        }

//        // Si no hay usuario autenticado, simplemente continuar (no romper login)
//        var user = context.HttpContext.User;
//        if (user == null || !user.Identity?.IsAuthenticated == true)
//        {
//            // no inicializar cosas que dependen del usuario
//            await next();
//            return;
//        }

//        if (context.Controller is BaseController controller)
//        {
//            var httpContext = context.HttpContext;
//            var claimsIdentity = httpContext.User?.Identity as ClaimsIdentity ?? throw new InvalidOperationException("User identity is not available.");
//            string IdUsuario = string.Empty;
//            if (!claimsIdentity.IsAuthenticated)
//                IdUsuario = "0";
//            else
//                IdUsuario = claimsIdentity is not null && claimsIdentity.IsAuthenticated
//                ? claimsIdentity.FindFirst(Constants.FK_IDUSUARIO)?.Value ?? ""
//                : "";


//            var ipAddress = _userIpService.GetUserIpAddress(httpContext);
//            //var (lectura, escritura) = _privilegiosXRol.GetPrivilegiosXRol(_userData.GetIdRol(claimsIdentity), controller.ControllerName);

//            controller.UserId = int.Parse(IdUsuario);
//            //controller.Lectura = lectura;
//            //controller.Escritura = escritura;
//            controller.IpAddress = ipAddress;

//            var actionName = context.ActionDescriptor.RouteValues["action"];

//            //var excludedControllers = new HashSet<string>
//            //    {
//            //        "Det",
//            //        "SICOPTB_Especificacion",
//            //        "SICOPTB_Imagen",
//            //        "PRESAdecuacionReduccion",
//            //        "PRESAdecuacionAmpliacion",
//            //        "ORCORequisicionFide",
//            //        "ORCOCotizacionFide",
//            //        "PRESVW_SolicitudSuficienciaFide",
//            //        "PRESVW_AutorizacionSuficienciaFide",
//            //        "PRESContratoFide",
//            //        "SICOPTB_Normatecnica",
//            //        "PRESFacturaFide",
//            //        "PRESVW_ClcFide",
//            //        "PRESVW_ChequeFide",
//            //        "SISVW_NotificacionesByUser",
//            //        "TESInteres",
//            //        "TESRetiro",
//            //        "TESInteresSimulador",
//            //    };

//            //if (actionName == "GetData" && !lectura && !excludedControllers.Any(controller.ControllerName.Contains))
//            //{
//            //    context.Result = new BadRequestObjectResult("NO TIENE PERMISOS PARA VISUALIZAR LA INFORMACIÓN");
//            //    return;
//            //}

//        }
//    }
//}
