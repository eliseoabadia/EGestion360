using AutoMapper;
using EG.ApiCore.Services;
using EG.Application.CommonModel;
using EG.Business.Services;
using EG.Domain.DTOs.Requests.General;
using EG.Domain.DTOs.Responses;
using EG.Domain.Entities;
using EG.Dommain.DTOs.Responses;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace EG.ApiCore.Controllers.General
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize]
    public class MenuController : ControllerBase
    {
        private readonly IUserContextService _userContext;
        private readonly GenericService<Menu, MenuItemsDto, MenuItemsResponse> _service;
        private readonly GenericService<VwMenu, MenuItemsDto, MenuItemsResponse> _serviceView;
        private readonly IMapper _mapper;

        public MenuController(
            GenericService<Menu, MenuItemsDto, MenuItemsResponse> service,
            GenericService<VwMenu, MenuItemsDto, MenuItemsResponse> serviceView,
            IMapper mapper,
            IUserContextService userContext)
        {
            _service = service;
            _serviceView = serviceView;
            _mapper = mapper;
            _userContext = userContext;

            ConfigureService();
        }

        private void ConfigureService()
        {
            // Incluir la relación con el menú padre para obtener datos completos
            _service.AddInclude(m => m.FkidMenuSisNavigation);

            // Configurar propiedades para búsqueda
            _service.AddRelationFilter("MenuPadre", new List<string> { "Nombre" });
        }

        private void ConfigureValidations()
        {
            // REGLA 1: Validar nombre único por nivel (mismo padre)
            _service.AddValidationRule("UniqueMenuName", async (dto) =>
            {
                var menuDto = dto as MenuItemsDto;
                if (menuDto == null) return true;

                var exists = _service.GetQueryWithIncludes()
                    .Any(m => m.FkidMenuSis == menuDto.FkidMenuSis &&
                             m.Nombre.ToLower() == menuDto.Nombre.ToLower() &&
                             m.Activo);

                return !exists;
            });

            // REGLA 2: Validar nombre único por nivel para ACTUALIZACIÓN
            _service.AddValidationRuleWithId("UniqueMenuNameUpdate", async (dto, id) =>
            {
                var menuDto = dto as MenuItemsDto;
                if (menuDto == null || !id.HasValue) return true;

                var exists = _service.GetQueryWithIncludes()
                    .Any(m => m.FkidMenuSis == menuDto.FkidMenuSis &&
                             m.Nombre.ToLower() == menuDto.Nombre.ToLower() &&
                             m.PkidMenu != id.Value &&
                             m.Activo);

                return !exists;
            });

            // REGLA 3: Validar que el nombre no esté vacío
            _service.AddValidationRule("ValidNameLength", async (dto) =>
            {
                var menuDto = dto as MenuItemsDto;
                return !string.IsNullOrWhiteSpace(menuDto?.Nombre) && menuDto.Nombre.Length >= 2;
            });

            // REGLA 4: Validar que si es tipo 2 (item final), tenga ruta
            _service.AddValidationRule("ItemFinalRequiresRoute", async (dto) =>
            {
                var menuDto = dto as MenuItemsDto;
                if (menuDto?.Tipo == 2)
                {
                    return !string.IsNullOrWhiteSpace(menuDto.Ruta);
                }
                return true;
            });

            // REGLA 5: Validar que si es tipo 1 (contenedor) y tiene padre, el padre sea tipo 1
            _service.AddValidationRule("ParentMustBeContainer", async (dto) =>
            {
                var menuDto = dto as MenuItemsDto;
                if (menuDto?.FkidMenuSis.HasValue == true)
                {
                    var parent = await _service.GetByIdAsync(menuDto.FkidMenuSis.Value);
                    return parent?.Tipo == 1; // El padre debe ser tipo 1 (contenedor)
                }
                return true;
            });
        }

        [HttpGet]
        public async Task<ActionResult<PagedResult<MenuItemsResponse>>> GetAll()
        {
            var result = await _serviceView.GetAllAsync();

            // Construir estructura jerárquica
            var menuList = result.ToList();
            var menuDict = menuList.ToDictionary(m => m.PkidMenu);

            // Identificar raíces (sin padre)
            var rootMenus = menuList.Where(m => !m.FkidMenuSis.HasValue).ToList();

            // Construir árbol
            foreach (var menu in menuList)
            {
                if (menu.FkidMenuSis.HasValue && menuDict.ContainsKey(menu.FkidMenuSis.Value))
                {
                    var parent = menuDict[menu.FkidMenuSis.Value];
                    if (parent.Children == null)
                        parent.Children = new List<MenuItemsResponse>();
                    parent.Children.Add(menu);
                }
            }

            return Ok(new PagedResult<MenuItemsResponse>
            {
                Success = true,
                Message = "Menús obtenidos correctamente",
                Code = "SUCCESS",
                Items = rootMenus,
                TotalCount = rootMenus.Count
            });
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<PagedResult<MenuItemsResponse>>> GetById(int id)
        {
            var result = await _serviceView.GetByIdAsync(id, idPropertyName: "PkidMenu");

            if (result == null)
                return NotFound(new PagedResult<MenuItemsResponse>
                {
                    Success = false,
                    Message = "Menú no encontrado",
                    Code = "NOTFOUND_MENU",
                    TotalCount = 0
                });

            //// Cargar hijos si tiene
            //if (result.TieneSubmenus == 1)
            //{
            //    var hijos = await _serviceView.GetAllAsync(
            //        m => m.FkidMenuSis == id && m.Activo);
            //    result.Children = hijos.ToList();
            //}

            return Ok(new PagedResult<MenuItemsResponse>
            {
                Success = true,
                Message = "Menú encontrado",
                Code = "SUCCESS",
                Data = result,
                Items = new List<MenuItemsResponse> { result },
                TotalCount = 1
            });
        }

        //[HttpGet("padres")]
        //public async Task<ActionResult<PagedResult<MenuComboResponse>>> GetMenusPadre()
        //{
        //    var padres = await _service.GetAllAsync(m => m.Tipo == 1 && m.Activo);
        //    var result = _mapper.Map<List<MenuComboResponse>>(padres);

        //    return Ok(new PagedResult<MenuComboResponse>
        //    {
        //        Success = true,
        //        Message = "Menús padre obtenidos correctamente",
        //        Code = "SUCCESS",
        //        Items = result,
        //        TotalCount = result.Count
        //    });
        //}

        //[HttpGet("hijos/{padreId}")]
        //public async Task<ActionResult<PagedResult<MenuItemsResponse>>> GetHijosByPadreId(int padreId)
        //{
        //    var hijos = await _serviceView.GetAllAsync(m => m.FkidMenuSis == padreId && m.Activo);

        //    return Ok(new PagedResult<MenuItemsResponse>
        //    {
        //        Success = true,
        //        Message = "Hijos obtenidos correctamente",
        //        Code = "SUCCESS",
        //        Items = hijos.ToList(),
        //        TotalCount = hijos.Count()
        //    });
        //}

        //[HttpGet("arbol")]
        //public async Task<ActionResult<PagedResult<MenuItemsResponse>>> GetArbolCompleto()
        //{
        //    // Obtener todos los menús activos
        //    var todos = await _serviceView.GetAllAsync(m => m.Activo);
        //    var menuList = todos.ToList();
        //    var menuDict = menuList.ToDictionary(m => m.PkidMenu);

        //    // Construir árbol
        //    foreach (var menu in menuList)
        //    {
        //        if (menu.FkidMenuSis.HasValue && menuDict.ContainsKey(menu.FkidMenuSis.Value))
        //        {
        //            var parent = menuDict[menu.FkidMenuSis.Value];
        //            if (parent.Children == null)
        //                parent.Children = new List<MenuItemsResponse>();
        //            parent.Children.Add(menu);
        //        }
        //    }

        //    // Obtener raíces
        //    var raices = menuList.Where(m => !m.FkidMenuSis.HasValue).ToList();

        //    // Ordenar por orden
        //    foreach (var menu in menuList)
        //    {
        //        if (menu.Children?.Any() == true)
        //        {
        //            menu.Children = menu.Children.OrderBy(c => c.Orden).ToList();
        //        }
        //    }

        //    return Ok(new PagedResult<MenuItemsResponse>
        //    {
        //        Success = true,
        //        Message = "Árbol de menús obtenido correctamente",
        //        Code = "SUCCESS",
        //        Items = raices.OrderBy(r => r.Orden).ToList(),
        //        TotalCount = raices.Count
        //    });
        //}

        [HttpPost]
        public async Task<ActionResult<PagedResult<MenuItemsResponse>>> Add([FromBody] VwMenu viewDto)
        {
            try
            {
                ConfigureValidations();

                var dto = _mapper.Map<MenuItemsDto>(viewDto);

                dto.CreatedDateTime = DateTime.Now;
                dto.CreatedByOperatorId = _userContext.GetCurrentUserId();
                dto.LegacyName = dto.Nombre;
                dto.Lenguaje = "ESP";
                dto.Tipo = 2;

                //Poner al padre como Tipo = 1 Ruta = '/'
                if (dto.FkidMenuSis.HasValue)
                {
                    var _padre = await GetParentDtoAsync(dto.FkidMenuSis);
                    _padre.Tipo = 1;
                    _padre.Ruta = "/";
                    await _service.UpdateAsync(dto.FkidMenuSis.Value, _padre);
                }

                //var _dto = _mapper.Map<MenuItemsDto>(viewDto);

                await _service.AddAsync(dto);

                return CreatedAtAction(nameof(GetById), new { id = dto.PkidMenu },
                    new PagedResult<MenuItemsResponse>
                    {
                        Success = true,
                        Message = "Menú creado correctamente",
                        Code = "SUCCESS",
                        TotalCount = 1
                    });
            }
            catch (Exception ex)
            {
                return BadRequest(new PagedResult<MenuItemsResponse>
                {
                    Success = false,
                    Message = $"Error al crear menú: {ex.Message}",
                    Code = "ERROR",
                    TotalCount = 0
                });
            }
        }

        [HttpPut("{id}")]
        public async Task<ActionResult<PagedResult<MenuItemsResponse>>> Update(int id, [FromBody] VwMenu viewDto)
        {
            try
            {
                ConfigureValidations();
                //dto.PkidMenu = id;

                var dto = _mapper.Map<MenuItemsDto>(viewDto);

                dto.ModifiedDateTime = DateTime.Now;
                dto.ModifiedByOperatorId = _userContext.GetCurrentUserId();


                if (!await _service.CanUpdateAsync(id, dto))
                {
                    return Conflict(new PagedResult<MenuItemsResponse>
                    {
                        Success = false,
                        Message = "Ya existe otro menú activo con ese nombre en el mismo nivel",
                        Code = "DUPLICATE_MENU",
                        TotalCount = 0
                    });
                }

                await _service.UpdateAsync(id, dto);

                return Ok(new PagedResult<MenuItemsResponse>
                {
                    Success = true,
                    Message = "Menú actualizado correctamente",
                    Code = "SUCCESS",
                    TotalCount = 1
                });
            }
            catch (KeyNotFoundException)
            {
                return NotFound(new PagedResult<MenuItemsResponse>
                {
                    Success = false,
                    Message = $"Menú con ID {id} no encontrado",
                    Code = "NOTFOUND_MENU",
                    TotalCount = 0
                });
            }
            catch (Exception ex)
            {
                return BadRequest(new PagedResult<MenuItemsResponse>
                {
                    Success = false,
                    Message = $"Error al actualizar: {ex.Message}",
                    Code = "ERROR",
                    TotalCount = 0
                });
            }
        }

        [HttpDelete("{id}")]
        public async Task<ActionResult<PagedResult<MenuItemsResponse>>> Delete(int id)
        {
            try
            {
                // Verificar si tiene hijos antes de eliminar
                var tieneHijos = await _service.GetQueryWithIncludes()
                    .AnyAsync(m => m.FkidMenuSis == id && m.Activo);

                if (tieneHijos)
                {
                    return BadRequest(new PagedResult<MenuItemsResponse>
                    {
                        Success = false,
                        Message = "No se puede eliminar un menú que tiene hijos activos",
                        Code = "MENU_HAS_CHILDREN",
                        TotalCount = 0
                    });
                }

                await _service.DeleteAsync(id);

                return Ok(new PagedResult<MenuItemsResponse>
                {
                    Success = true,
                    Message = "Menú eliminado correctamente",
                    Code = "SUCCESS",
                    TotalCount = 0
                });
            }
            catch (KeyNotFoundException)
            {
                return NotFound(new PagedResult<MenuItemsResponse>
                {
                    Success = false,
                    Message = $"Menú con ID {id} no encontrado",
                    Code = "NOTFOUND_MENU",
                    TotalCount = 0
                });
            }
            catch (Exception ex)
            {
                return BadRequest(new PagedResult<MenuItemsResponse>
                {
                    Success = false,
                    Message = $"Error al eliminar: {ex.Message}",
                    Code = "ERROR",
                    TotalCount = 0
                });
            }
        }

        [HttpPost("GetAllMenusPaginado")]
        public async Task<ActionResult<PagedResult<MenuItemsResponse>>> GetAllMenusPaginado([FromBody] PagedRequest _params)
        {
            _serviceView.ClearConfiguration();
            ConfigureService();

            var result = await _serviceView.GetAllPaginadoAsync(_params);

            // Construir estructura jerárquica para la respuesta paginada
            if (result.Items?.Any() == true)
            {
                var menuList = result.Items.ToList();
                var menuDict = menuList.ToDictionary(m => m.PkidMenu);

                // Limpiar hijos previos
                foreach (var menu in menuList)
                {
                    menu.Children = new List<MenuItemsResponse>();
                }

                // Construir árbol
                foreach (var menu in menuList)
                {
                    if (menu.FkidMenuSis.HasValue && menuDict.ContainsKey(menu.FkidMenuSis.Value))
                    {
                        var parent = menuDict[menu.FkidMenuSis.Value];
                        parent.Children.Add(menu);
                    }
                }

                // Solo devolver raíces en el resultado paginado
                result.Items = menuList.Where(m => !m.FkidMenuSis.HasValue).ToList();
            }

            return Ok(new PagedResult<MenuItemsResponse>
            {
                Success = true,
                Message = "Menús obtenidos correctamente",
                Code = "SUCCESS",
                Items = result.Items,
                TotalCount = result.TotalCount
            });
        }

        [HttpPost("GetAllPaginado")]
        public async Task<ActionResult<PagedResult<MenuItemsResponse>>> GetAllPaginado([FromBody] PagedRequest _params)
        {
            _serviceView.ClearConfiguration();
            ConfigureService();

            var result = await _serviceView.GetAllPaginadoAsync(_params);

            // Construir estructura jerárquica para la respuesta paginada
            //if (result.Items?.Any() == true)
            //{
            //    var menuList = result.Items.ToList();
            //    var menuDict = menuList.ToDictionary(m => m.PkidMenu);

            //    // Limpiar hijos previos
            //    foreach (var menu in menuList)
            //    {
            //        menu.Children = new List<MenuItemsResponse>();
            //    }

            //    // Construir árbol
            //    foreach (var menu in menuList)
            //    {
            //        if (menu.FkidMenuSis.HasValue && menuDict.ContainsKey(menu.FkidMenuSis.Value))
            //        {
            //            var parent = menuDict[menu.FkidMenuSis.Value];
            //            parent.Children.Add(menu);
            //        }
            //    }

            //    // Solo devolver raíces en el resultado paginado
            //    result.Items = menuList.Where(m => !m.FkidMenuSis.HasValue).ToList();
            //}

            return Ok(new PagedResult<MenuItemsResponse>
            {
                Success = true,
                Message = "Menús obtenidos correctamente",
                Code = "SUCCESS",
                Items = result.Items,
                TotalCount = result.TotalCount
            });
        }

        [HttpPost("buscar")]
        public async Task<ActionResult<PagedResult<MenuItemsResponse>>> BuscarMenus([FromBody] BusquedaRequest request)
        {
            _service.ClearConfiguration();
            ConfigureService();

            var pagedRequest = new PagedRequest
            {
                Page = request.Page,
                PageSize = request.PageSize,
                Filtro = request.TerminoBusqueda,
                SortLabel = request.SortLabel,
                SortDirection = request.SortDirection
            };

            var result = await _service.GetAllPaginadoAsync(pagedRequest);

            return Ok(new PagedResult<MenuItemsResponse>
            {
                Success = true,
                Message = "Menús filtrados correctamente",
                Code = "SUCCESS",
                Items = result.Items,
                TotalCount = result.TotalCount
            });
        }

        [HttpPost("validar")]
        public async Task<ActionResult<PagedResult<MenuItemsResponse>>> ValidarMenu([FromBody] MenuItemsDto dto)
        {
            ConfigureValidations();
            var isValid = await _service.CanAddAsync(dto);

            if (!isValid)
            {
                return Ok(new PagedResult<MenuItemsResponse>
                {
                    Success = false,
                    Message = "Ya existe un menú activo con ese nombre en el mismo nivel o no cumple las validaciones",
                    Code = "DUPLICATE_OR_INVALID_MENU",
                    TotalCount = 0
                });
            }

            return Ok(new PagedResult<MenuItemsResponse>
            {
                Success = true,
                Message = "El menú es válido",
                Code = "SUCCESS",
                TotalCount = 0
            });
        }

        [HttpPost("reordenar")]
        public async Task<ActionResult<PagedResult<MenuItemsResponse>>> ReordenarMenus([FromBody] List<MenuItemsDto> menus)
        {
            try
            {
                foreach (var menu in menus)
                {
                    var entity = await _service.GetByIdAsync(menu.PkidMenu);
                    if (entity != null)
                    {
                        entity.Orden = menu.Orden.Value;
                        await _service.UpdateAsync(menu.PkidMenu, menu);
                    }
                }

                return Ok(new PagedResult<MenuItemsResponse>
                {
                    Success = true,
                    Message = "Menús reordenados correctamente",
                    Code = "SUCCESS",
                    TotalCount = menus.Count
                });
            }
            catch (Exception ex)
            {
                return BadRequest(new PagedResult<MenuItemsResponse>
                {
                    Success = false,
                    Message = $"Error al reordenar: {ex.Message}",
                    Code = "ERROR",
                    TotalCount = 0
                });
            }
        }

        private async Task<MenuItemsDto?> GetParentDtoAsync(int? parentId)
        {
            if (!parentId.HasValue)
                return null;

            var parentEntity = await _service.GetQueryWithIncludes()
                .FirstOrDefaultAsync(m => m.PkidMenu == parentId.Value && m.Activo);

            return parentEntity is null ? null : _mapper.Map<MenuItemsDto>(parentEntity);
        }
    }
}