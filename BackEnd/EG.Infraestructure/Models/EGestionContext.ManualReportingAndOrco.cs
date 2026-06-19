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
        modelBuilder.Entity<Nivel1>(entity =>
        {
            entity.HasOne(d => d.FkidUniversoNomNavigation)
                .WithMany()
                .HasForeignKey(d => d.FkidUniversoNom)
                .HasConstraintName("FK_NOM_Nivel_Universo");
        });

        modelBuilder.Entity<Puesto>(entity =>
        {
            entity.HasOne(d => d.FkidPuestoPadreNomNavigation)
                .WithMany()
                .HasForeignKey(d => d.FkidPuestoPadreNom)
                .HasConstraintName("FK_NOM_Puesto_Padre");

            entity.HasOne(d => d.FkidNivelNomNavigation)
                .WithMany()
                .HasForeignKey(d => d.FkidNivelNom)
                .HasConstraintName("FK_NOM_Puesto_Nivel");

            entity.HasOne(d => d.FkidClasePuestoNomNavigation)
                .WithMany()
                .HasForeignKey(d => d.FkidClasePuestoNom)
                .HasConstraintName("FK_NOM_Puesto_ClasePuesto");
        });

        modelBuilder.Entity<ConceptoFijo>(entity =>
        {
            entity.HasOne(d => d.FkidEmpresaSisNavigation)
                .WithMany()
                .HasForeignKey(d => d.FkidEmpresaSis)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_NOM_ConceptoFijo_EmpresaNomina");

            entity.HasOne(d => d.FkidConceptoNomNavigation)
                .WithMany()
                .HasForeignKey(d => d.FkidConceptoNom)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_NOM_ConceptoFijo_Concepto");

            entity.HasOne(d => d.FkidPuestoNomNavigation)
                .WithMany()
                .HasForeignKey(d => d.FkidPuestoNom)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_NOM_ConceptoFijo_Puesto");
        });

        modelBuilder.Entity<ConceptoProporcional>(entity =>
        {
            entity.HasOne(d => d.FkidEmpresaSisNavigation)
                .WithMany()
                .HasForeignKey(d => d.FkidEmpresaSis)
                .HasConstraintName("FK_NOM_ConceptoProporcional_EmpresaNomina");

            entity.HasOne(d => d.FkidPuestoNomNavigation)
                .WithMany()
                .HasForeignKey(d => d.FkidPuestoNom)
                .HasConstraintName("FK_NOM_ConceptoProporcional_Puesto");

            entity.HasOne(d => d.FkidConceptoNomNavigation)
                .WithMany()
                .HasForeignKey(d => d.FkidConceptoNom)
                .HasConstraintName("FK_NOM_ConceptoProporcional_Concepto");
        });

        modelBuilder.Entity<ConceptoTabular>(entity =>
        {
            entity.HasOne(d => d.FkidEmpresaSisNavigation)
                .WithMany()
                .HasForeignKey(d => d.FkidEmpresaSis)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_NOM_ConceptoTabular_EmpresaNomina");

            entity.HasOne(d => d.FkidConceptoNomNavigation)
                .WithMany()
                .HasForeignKey(d => d.FkidConceptoNom)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_NOM_ConceptoTabular_Concepto");

            entity.HasOne(d => d.FkidPuestoNomNavigation)
                .WithMany()
                .HasForeignKey(d => d.FkidPuestoNom)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_NOM_ConceptoTabular_Puesto");
        });

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
