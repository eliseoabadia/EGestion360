using AutoMapper;
using EG.Domain.DTOs.Requests.Almacen;
using EG.Domain.DTOs.Responses.Almacen;
using EG.Domain.DTOs.Responses.ConteoCiclico;
using EG.Infraestructure.Models;

namespace EG.Business.Mapping.Almacen
{
    public class AlmacenMappingProfile : Profile
    {
        public AlmacenMappingProfile()
        {
            // MotivoES
            CreateMap<Motivo, MotivoEsResponse>().ReverseMap();
            CreateMap<Motivo, MotivoEsDto>().ReverseMap();

            // Unidades
            CreateMap<Unidade, UnidadeResponse>().ReverseMap();
            CreateMap<Unidade, UnidadeDto>().ReverseMap();

            // EstatusSolicitud
            CreateMap<EstatusSolicitud, EstatusSolicitudResponse>().ReverseMap();
            CreateMap<EstatusSolicitud, EstatusSolicitudDto>().ReverseMap();

            // PeriodoConteo
            CreateMap<PeriodoConteo, PeriodoConteoResponse>().ReverseMap();
            CreateMap<PeriodoConteo, PeriodoConteoDto>().ReverseMap();
        }
    }
}
