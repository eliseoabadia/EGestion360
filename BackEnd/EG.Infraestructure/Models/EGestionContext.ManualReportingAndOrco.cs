// <manual> Complements EF Core Power Tools output for objects consumed by migrated services. </manual>
#nullable disable
using Microsoft.EntityFrameworkCore;

namespace EG.Infraestructure.Models;

public partial class EGestionContext
{
    public virtual DbSet<VwResguardo> VwResguardos { get; set; }

    public virtual DbSet<VwResguardoDetalle> VwResguardoDetalles { get; set; }

    partial void OnModelCreatingPartial(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<VwResguardo>(entity =>
        {
            entity.HasNoKey();
            entity.ToView("Vw_Resguardo", "ALMA");
            entity.Property(e => e.PkidResguardo).HasColumnName("PKIdResguardo");
            entity.Property(e => e.FkidEmpresaSis).HasColumnName("FKIdEmpresa_SIS");
            entity.Property(e => e.FkidAreaSis).HasColumnName("FKIdArea_SIS");
            entity.Property(e => e.FkidPersonaNom).HasColumnName("FKIdPersona_NOM");
        });

        modelBuilder.Entity<VwResguardoDetalle>(entity =>
        {
            entity.HasNoKey();
            entity.ToView("Vw_ResguardoDetalle", "ALMA");
            entity.Property(e => e.PkidResguardoDetalle).HasColumnName("PKIdResguardoDetalle");
            entity.Property(e => e.FkidResguardoAlma).HasColumnName("FKIdResguardo_ALMA");
            entity.Property(e => e.FkidEmpresaSis).HasColumnName("FKIdEmpresa_SIS");
            entity.Property(e => e.FkidAreaSis).HasColumnName("FKIdArea_SIS");
            entity.Property(e => e.FkidPersonaNom).HasColumnName("FKIdPersona_NOM");
            entity.Property(e => e.FkidBienAlma).HasColumnName("FKIdBien_ALMA");
            entity.Property(e => e.FkidTipoBienAlma).HasColumnName("FKIdTipoBien_ALMA");
            entity.Property(e => e.FkidEstadoBienAlma).HasColumnName("FKIdEstadoBien_ALMA");
        });
    }
}
