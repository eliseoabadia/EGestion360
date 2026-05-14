using Mapster;

namespace EG.Business.Mapping
{
    public class MappingProfile : IRegister
    {
        public void Register(TypeAdapterConfig config)
        {
            // Registro manual de perfiles — cada perfil individual implementa IRegister
            // y se auto-descubre via TypeAdapterConfig.GlobalSettings.Scan() en Program.cs.
        }
    }
}