using AutoMapper;
using EG.Business.Interfaces;
using EG.Domain.Entities;
using EG.Domain.Interfaces;
using EG.Dommain.DTOs.Responses;
using Microsoft.Data.SqlClient;


namespace EG.Business.Services
{
    public class NavigateService(IRepositorySP<spNodeMenuResult> repositorySP,
                IMapper mapper) : INavigateService
    {
        private readonly IRepositorySP<spNodeMenuResult> _repositorySP = repositorySP;
        private readonly IMapper _mapper = mapper;

        public async Task<IEnumerable<spNodeMenuResponse>> GetMenuAsync(int empId)
        {
            var param1 = new SqlParameter("@NoEmploye", empId);
            var param2 = new SqlParameter("@Lenguaje", "ESP");
            var menu = await _repositorySP.ExecuteStoredProcedureAsync<spNodeMenuResult>("[SIS].[spNodeMenu]", param1, param2);
            return _mapper.Map<IEnumerable<spNodeMenuResponse>>(menu);
        }

    }
}