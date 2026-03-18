using AutoMapper;
using EG.Domain.DTOs.Requests.Almacen;
using EG.Domain.DTOs.Responses.Almacen;
using EG.Infraestructure.Models;

namespace EG.Business.Mapping.Almacen;

public class AlmacenMappingProfile : Profile
{
    public AlmacenMappingProfile()
    {
        
        // Familia mappings (Familium)
        CreateMap<Familium, FamiliaResponse>()
            .ForMember(dest => dest.PkidFamilia, opt => opt.MapFrom(src => src.PkidFamilia)).ReverseMap();

        CreateMap<FamiliaDto, FamiliaResponse>()
            .ForMember(dest => dest.PkidFamilia, opt => opt.MapFrom(src => src.PkidFamilia)).ReverseMap();

        // Mapeo de TipoBien a TipoBienDto (bidireccional)
        CreateMap<TipoBien, TipoBienDto>().ReverseMap();

        // Mapeo de VwTipoBienConteo a TipoBienResponse
        CreateMap<VwTipoBienConteo, TipoBienResponse>();

        // Mapeo de Bien a BienDto (bidireccional)
        CreateMap<Bien, BienDto>().ReverseMap();

        // Mapeo de VwBien a BienResponse
        CreateMap<VwBien, BienResponse>();

    }
}
