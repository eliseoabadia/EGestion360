using EG.ApiCoreBS.Services;
using EG.Application.Interfaces.General;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.General;
using EG.Domain.DTOs.Responses;
using EG.Domain.DTOs.Responses.General;
using EG.Domain.Interfaces;
using EG.Domain.Platform.Settings;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Options;

namespace EG.ApiCoreBS.Controllers.General
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize]
    public class EmpresaController : ControllerBase
    {
        private const long MaxLogoSizeBytes = 5 * 1024 * 1024;
        private static readonly HashSet<string> AllowedLogoExtensions = new(StringComparer.OrdinalIgnoreCase)
        {
            ".png",
            ".jpg",
            ".jpeg",
            ".webp"
        };

        private readonly IEmpresaAppService _appService;
        private readonly IUserContextService _userContext;
        private readonly DocumentStorageSettings _storageSettings;
        private readonly IWebHostEnvironment _environment;
        private readonly IConfiguration _configuration;

        public EmpresaController(
            IEmpresaAppService appService,
            IUserContextService userContext,
            IOptions<DocumentStorageSettings> storageOptions,
            IWebHostEnvironment environment,
            IConfiguration configuration)
        {
            _appService = appService;
            _userContext = userContext;
            _storageSettings = storageOptions.Value;
            _environment = environment;
            _configuration = configuration;
        }

        [HttpGet]
        public async Task<ActionResult<PagedResult<EmpresaResponse>>> GetAll()
        {
            var result = await _appService.GetAllAsync();
            return Ok(result);
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<PagedResult<EmpresaResponse>>> GetById(int id)
        {
            var result = await _appService.GetByIdAsync(id);
            if (result == null)
                return NotFound(new PagedResult<EmpresaResponse>
                {
                    Success = false,
                    Message = "Empresa no encontrada",
                    Code = "NOTFOUND_COMPANY",
                    TotalCount = 0
                });

            return Ok(new PagedResult<EmpresaResponse>
            {
                Success = true,
                Message = "Empresa encontrada",
                Code = "SUCCESS",
                Data = result,
                Items = new List<EmpresaResponse> { result },
                TotalCount = 1
            });
        }

        [HttpPost]
        public async Task<ActionResult<PagedResult<EmpresaResponse>>> Create([FromBody] EmpresaDto dto)
        {
            try
            {
                var usuarioActual = _userContext.GetCurrentUserId();
                var result = await _appService.CreateAsync(dto, usuarioActual);
                return CreatedAtAction(nameof(GetById), new { id = result.PkidEmpresa }, Success("Empresa creada correctamente", result));
            }
            catch (ArgumentException ex)
            {
                return BadRequest(Failure(ex.Message, "INVALID_DATA"));
            }
            catch (InvalidOperationException ex)
            {
                return Conflict(Failure(ex.Message, "BUSINESS_RULE"));
            }
            catch (Exception ex)
            {
                return StatusCode(StatusCodes.Status500InternalServerError, Failure($"Error al crear empresa: {ex.Message}", "ERROR"));
            }
        }

        [HttpPut("{id}")]
        public async Task<ActionResult<PagedResult<EmpresaResponse>>> Update(int id, [FromBody] EmpresaDto dto)
        {
            try
            {
                var usuarioActual = _userContext.GetCurrentUserId();
                var result = await _appService.UpdateAsync(id, dto, usuarioActual);
                return Ok(Success("Empresa actualizada correctamente", result));
            }
            catch (ArgumentException ex)
            {
                return BadRequest(Failure(ex.Message, "INVALID_DATA"));
            }
            catch (InvalidOperationException ex)
            {
                return Conflict(Failure(ex.Message, "BUSINESS_RULE"));
            }
            catch (Exception ex)
            {
                return StatusCode(StatusCodes.Status500InternalServerError, Failure($"Error al actualizar empresa: {ex.Message}", "ERROR"));
            }
        }

        [HttpDelete("{id}")]
        public async Task<ActionResult<PagedResult<EmpresaResponse>>> Delete(int id)
        {
            try
            {
                var usuarioActual = _userContext.GetCurrentUserId();
                await _appService.DeleteAsync(id, usuarioActual);
                return Ok(new PagedResult<EmpresaResponse>
                {
                    Success = true,
                    Message = "Empresa eliminada correctamente",
                    Code = "SUCCESS",
                    TotalCount = 0
                });
            }
            catch (InvalidOperationException ex)
            {
                return Conflict(Failure(ex.Message, "BUSINESS_RULE"));
            }
            catch (ArgumentException ex)
            {
                return BadRequest(Failure(ex.Message, "INVALID_DATA"));
            }
            catch (Exception ex)
            {
                return StatusCode(StatusCodes.Status500InternalServerError, Failure($"Error al eliminar empresa: {ex.Message}", "ERROR"));
            }
        }

        [HttpPost("GetAllPaginado")]
        public async Task<ActionResult<PagedResult<EmpresaResponse>>> GetAllPaginado([FromBody] PagedRequest _params)
        {
            var result = await _appService.GetAllPaginadoAsync(_params);
            return Ok(result);
        }

        [HttpPost("buscar")]
        public async Task<ActionResult<PagedResult<EmpresaResponse>>> BuscarEmpresas([FromBody] BusquedaRequest request)
        {
            var result = await _appService.BuscarAsync(request);
            return Ok(result);
        }

        private static PagedResult<EmpresaResponse> Success(string message, EmpresaResponse result) =>
            new()
            {
                Success = true,
                Message = message,
                Code = "SUCCESS",
                Data = result,
                Items = [result],
                TotalCount = 1
            };

        private static PagedResult<EmpresaResponse> Failure(string message, string code) =>
            new()
            {
                Success = false,
                Message = message,
                Code = code,
                TotalCount = 0
            };

        [HttpPost("{id:int}/logo")]
        [RequestSizeLimit(MaxLogoSizeBytes)]
        public async Task<ActionResult<PagedResult<EmpresaResponse>>> UploadLogo(int id, [FromForm] EmpresaLogoUploadRequest request)
        {
            if (request.File == null || request.File.Length == 0)
            {
                return BadRequest(new PagedResult<EmpresaResponse>
                {
                    Success = false,
                    Message = "El archivo del logo es requerido.",
                    Code = "INVALID_FILE"
                });
            }

            if (request.File.Length > MaxLogoSizeBytes)
            {
                return BadRequest(new PagedResult<EmpresaResponse>
                {
                    Success = false,
                    Message = "El logo no puede exceder 5 MB.",
                    Code = "FILE_TOO_LARGE"
                });
            }

            var extension = Path.GetExtension(request.File.FileName);
            if (!AllowedLogoExtensions.Contains(extension))
            {
                return BadRequest(new PagedResult<EmpresaResponse>
                {
                    Success = false,
                    Message = "El logo debe ser PNG, JPG, JPEG o WEBP.",
                    Code = "INVALID_FILE_TYPE"
                });
            }

            await using var stream = request.File.OpenReadStream();
            using var memory = new MemoryStream();
            await stream.CopyToAsync(memory);
            var content = memory.ToArray();

            var mode = NormalizeStorageMode(_storageSettings.Mode);
            var logoUrl = string.Empty;
            var logoEmpresa = Array.Empty<byte>();

            if (mode == "FILESYSTEM")
            {
                var logoDirectory = ResolveLogoDirectory();
                Directory.CreateDirectory(logoDirectory);

                foreach (var previousLogo in Directory.EnumerateFiles(logoDirectory, $"logo_empresa_{id}_*"))
                {
                    System.IO.File.Delete(previousLogo);
                }

                var fileName = $"logo_empresa_{id}_{DateTime.UtcNow:yyyyMMddHHmmssfff}{extension.ToLowerInvariant()}";
                var physicalPath = Path.Combine(logoDirectory, fileName);
                await System.IO.File.WriteAllBytesAsync(physicalPath, content);
                logoUrl = $"/img/{fileName}";
            }
            else
            {
                logoEmpresa = content;
            }

            var result = await _appService.UpdateLogoAsync(id, logoUrl, logoEmpresa, _userContext.GetCurrentUserId());
            return Ok(new PagedResult<EmpresaResponse>
            {
                Success = true,
                Message = "Logo actualizado correctamente",
                Code = "SUCCESS",
                Data = result,
                Items = [result],
                TotalCount = 1
            });
        }

        private string ResolveLogoDirectory()
        {
            var configuredPath = _configuration["Empresa:LogoPath"];
            if (!string.IsNullOrWhiteSpace(configuredPath))
            {
                return ResolvePath(configuredPath);
            }

            configuredPath = _configuration["Reporting:LogoPath"];
            if (!string.IsNullOrWhiteSpace(configuredPath))
            {
                return ResolvePath(configuredPath);
            }

            foreach (var start in new[] { _environment.ContentRootPath, AppContext.BaseDirectory })
            {
                var directory = new DirectoryInfo(start);
                while (directory != null)
                {
                    var candidate = Path.Combine(directory.FullName, "FrontEnd", "EG.Web", "wwwroot", "img");
                    if (Directory.Exists(candidate))
                    {
                        return candidate;
                    }

                    directory = directory.Parent;
                }
            }

            return Path.Combine(_environment.ContentRootPath, "wwwroot", "img");
        }

        private string ResolvePath(string path)
        {
            return Path.IsPathRooted(path)
                ? Path.GetFullPath(path)
                : Path.GetFullPath(Path.Combine(_environment.ContentRootPath, path));
        }

        private static string NormalizeStorageMode(string? value)
        {
            var mode = (value ?? "DATABASE").Trim().ToUpperInvariant();
            return mode == "FILESYSTEM" ? "FILESYSTEM" : "DATABASE";
        }
    }

    public class EmpresaLogoUploadRequest
    {
        public IFormFile File { get; set; }
    }
}
