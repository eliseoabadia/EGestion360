using AutoMapper;
using EG.Business.Extensions;
using EG.Business.Interfaces;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.General;
using EG.Domain.Interfaces;
using EG.Dommain.DTOs.Responses;
using EG.Infraestructure.Models;



namespace EG.Business.Services
{
    public class EmployeeService(IRepository<Usuario> repositorySP,
                IMapper mapper) : IEmployeeService
    {
        private readonly IRepository<Usuario> _repository = repositorySP;
        private readonly IMapper _mapper = mapper;


        public async Task<IList<UsuarioResponse?>> GetAllUsersAsync()
        {
            var items = await _repository.GetAllWithIncludes2Async(
                u => u.Activo,
                u => u.FkidPersonaNomNavigation,
                u => u.FkidEmpresaSisNavigation
            );
            return items != null ? _mapper.Map<IList<UsuarioResponse?>>(items) : null;
        }

        public async Task<PagedResult<UsuarioResponse>> GetAllUsuariosPaginadoAsync(PagedRequest _params)
        {
            // Obtener IQueryable directamente
            var query = _repository.QueryWithIncludes(
                u => u.Activo,
                u => u.FkidPersonaNomNavigation,
                u => u.FkidEmpresaSisNavigation);

            // Aplicar filtro si existe
            if (!string.IsNullOrWhiteSpace(_params.Filtro))
            {
                var filtro = _params.Filtro.Trim();
                query = query.Where(u => u.PkIdUsuario.ToString().Contains(filtro) ||
                            ((u.FkidPersonaNomNavigation.Nombre ?? string.Empty) + " " +
                             (u.FkidPersonaNomNavigation.Paterno ?? string.Empty) + " " +
                             (u.FkidPersonaNomNavigation.Materno ?? string.Empty)).Contains(filtro) ||
                            (u.FkidPersonaNomNavigation.CorreoElectronico ?? string.Empty).Contains(filtro) ||
                            (u.FkidPersonaNomNavigation.TelefonoParticular ?? string.Empty).Contains(filtro) ||
                            (u.FkidPersonaNomNavigation.TelefonoMovil ?? string.Empty).Contains(filtro) ||
                            (u.FkidPersonaNomNavigation.Gafete ?? string.Empty).Contains(filtro));
            }

            if (_params.SortLabel.Equals("NombreCompleto"))
            {
                if (_params.SortDirection.Contains("Descending"))
                {
                    query = query.OrderByDescending(x =>
                        (x.FkidPersonaNomNavigation.Nombre ?? string.Empty) + " " +
                        (x.FkidPersonaNomNavigation.Paterno ?? string.Empty) + " " +
                        (x.FkidPersonaNomNavigation.Materno ?? string.Empty));
                }
                else
                {
                    query = query.OrderBy(x =>
                        (x.FkidPersonaNomNavigation.Nombre ?? string.Empty) + " " +
                        (x.FkidPersonaNomNavigation.Paterno ?? string.Empty) + " " +
                        (x.FkidPersonaNomNavigation.Materno ?? string.Empty));
                }
            }
            else
                query = query.OrderByDynamic(_params.SortLabel, _params.SortDirection.Contains("Descending") ? true : false);

            // Obtener total antes de paginar
            var totalCount = query.Count();
            if (_params.Page < 1)
                _params.Page = 1;
            // Aplicar orden y paginación
            var usuariosQuery = query
                //.OrderBy(u => u.Nombre)
                .Skip((_params.Page - 1) * _params.PageSize)
                .Take(_params.PageSize);

            // Ejecutar la consulta y mapear
            var _usuarios = usuariosQuery.ToList();


            // Mapear a DTO
            var mapped = _mapper.Map<IList<UsuarioResponse>>(_usuarios);

            // Retornar resultado paginado
            return new PagedResult<UsuarioResponse>
            {
                Items = mapped,
                TotalCount = totalCount
            };
        }

        public async Task<UsuarioResponse?> GetEmployeeByIdAsync(int empId)
        {
            var emp = await _repository.GetByIdAsync(empId);
            return emp != null ? _mapper.Map<UsuarioResponse>(emp) : null;
        }

        public async Task<bool> AddEmployeeAsync(UsuarioDto dto)
        {
            var emp = _mapper.Map<Usuario>(dto);
            await _repository.AddAsync(emp);
            return true;
        }


        public async Task<bool> UpdateEmployeeAsync(int empId, UsuarioDto dto)
        {
            var existingEmp = await _repository.GetByIdAsync(empId);
            if (existingEmp == null)
                throw new KeyNotFoundException($"User with ID {empId} not found.");

            _mapper.Map(dto, existingEmp);
            await _repository.UpdateAsync(existingEmp);
            return true;
        }

        public async Task<bool> DeleteEmployeeAsync(int empId)
        {
            var emp = await _repository.GetByIdAsync(empId);
            if (emp == null)
                throw new KeyNotFoundException($"User  with ID {empId} not found.");

            emp.Activo = false;
            emp.FechaModificacion = System.DateTime.Now;
            emp.UsuarioModificacion = 1;

            await _repository.UpdateAsync(emp);
            return true;
        }
    }
}
