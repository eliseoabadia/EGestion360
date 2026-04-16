using AutoMapper;
using EG.Domain.DTOs.Requests.ConteoCiclico;
using EG.Domain.DTOs.Responses.ConteoCiclico;
using EG.Infraestructure.Models;

namespace EG.Business.Mapping.ConteoCiclico;

public class ConteoDetalleEscaneoMappingProfile : Profile
{
    public ConteoDetalleEscaneoMappingProfile()
    {
        // Entity ↔ DTO (using ConteoDto for simplicity since ConteoDetalleEscaneo shares write model)
        CreateMap<ConteoDetalleEscaneo, ConteoDto>().ReverseMap();

        // Vista → Response
        CreateMap<VwConteoDetalleEscaneo, ConteoDetalleEscaneoResponse>();
    }
}
