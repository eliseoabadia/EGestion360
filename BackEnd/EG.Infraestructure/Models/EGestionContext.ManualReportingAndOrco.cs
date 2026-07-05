// <manual> Complements EF Core Power Tools output for objects consumed by migrated services. </manual>
#nullable disable
using Microsoft.EntityFrameworkCore;

namespace EG.Infraestructure.Models;

public partial class EGestionContext
{
    public virtual DbSet<SaldoMensual> SaldoMensuales
    {
        get => SaldoMensuals;
        set => SaldoMensuals = value;
    }

    partial void OnModelCreatingPartial(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<Empresa>(entity =>
        {
            entity.Property(e => e.PkidEmpresa).ValueGeneratedOnAdd();
        });

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

        modelBuilder.Entity<SaldoMensual>(entity =>
        {
            entity.HasOne(d => d.FkidAnioSisNavigation)
                .WithMany()
                .HasForeignKey(d => d.FkidAnioSis)
                .OnDelete(DeleteBehavior.ClientSetNull);

            entity.HasOne(d => d.FkidCuentaContableNavigation)
                .WithMany()
                .HasForeignKey(d => d.FkidCuentaContable)
                .OnDelete(DeleteBehavior.ClientSetNull);

            entity.HasOne(d => d.UsuarioCreacionNavigation)
                .WithMany()
                .HasForeignKey(d => d.UsuarioCreacion)
                .OnDelete(DeleteBehavior.ClientSetNull);

            entity.HasOne(d => d.UsuarioModificacionNavigation)
                .WithMany()
                .HasForeignKey(d => d.UsuarioModificacion);
        });

    }
}
