// <manual> Complements EF Core Power Tools output for objects consumed by migrated services. </manual>
#nullable disable
using Microsoft.EntityFrameworkCore;

namespace EG.Infraestructure.Models;

public partial class EGestionContext
{
    public virtual DbSet<NomEmpresaNomina> NomEmpresaNominas { get; set; }

    public virtual DbSet<NomUniverso> NomUniversos { get; set; }

    public virtual DbSet<NomNivel> NomNiveles { get; set; }

    public virtual DbSet<NomClasePuesto> NomClasePuestos { get; set; }

    public virtual DbSet<NomPuesto> NomPuestos { get; set; }

    public virtual DbSet<NomNombramiento> NomNombramientos { get; set; }

    public virtual DbSet<NomImporteNivel> NomImporteNiveles { get; set; }

    public virtual DbSet<NomContratoLaboral> NomContratoLaborales { get; set; }

    public virtual DbSet<NomCatalogoSimple> NomCatalogoSimples { get; set; }

    public virtual DbSet<VwResguardo> VwResguardos { get; set; }

    public virtual DbSet<VwResguardoDetalle> VwResguardoDetalles { get; set; }

    partial void OnModelCreatingPartial(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<NomEmpresaNomina>(entity =>
        {
            entity.HasKey(e => e.PkidEmpresaNomina).HasName("PK_NOM_EmpresaNomina");
            entity.ToTable("EmpresaNomina", "NOM");
            entity.Property(e => e.PkidEmpresaNomina).HasColumnName("PKIdEmpresaNomina");
            entity.Property(e => e.RazonSocial).HasMaxLength(100);
            entity.Property(e => e.RegImss).HasMaxLength(25).HasColumnName("RegIMSS");
            entity.Property(e => e.RegInfonavit).HasMaxLength(25);
            entity.Property(e => e.CedEmpadronam).HasMaxLength(25);
            entity.Property(e => e.NoFonacot).HasMaxLength(25);
            entity.Property(e => e.UsAdmin).HasMaxLength(100);
            entity.Property(e => e.EmailAdmin).HasMaxLength(100);
            entity.Property(e => e.FkidPeriodoPagoSis).HasColumnName("FKIdPeriodoPago_SIS");
            entity.Property(e => e.PrimaRiesgoImss).HasColumnType("decimal(18, 4)").HasColumnName("PrimaRiesgoIMSS");
            entity.Property(e => e.FkidTipoPagoNom).HasColumnName("FKIdTipoPago_NOM");
            entity.Property(e => e.FechaCreacion).HasPrecision(6);
            entity.Property(e => e.FechaModificacion).HasPrecision(6);
            entity.Property(e => e.Activo).HasDefaultValue(true);
        });

        modelBuilder.Entity<NomUniverso>(entity =>
        {
            entity.HasKey(e => e.PkidUniverso).HasName("PK_NOM_Universo");
            entity.ToTable("Universo", "NOM");
            entity.Property(e => e.PkidUniverso).HasColumnName("PKIdUniverso");
            entity.Property(e => e.Descripcion).HasMaxLength(2);
            entity.Property(e => e.FechaCreacion).HasPrecision(6);
            entity.Property(e => e.FechaModificacion).HasPrecision(6);
            entity.Property(e => e.Activo).HasDefaultValue(true);
        });

        modelBuilder.Entity<NomNivel>(entity =>
        {
            entity.HasKey(e => e.PkidNivel).HasName("PK_NOM_Nivel");
            entity.ToTable("Nivel", "NOM");
            entity.Property(e => e.PkidNivel).HasColumnName("PKIdNivel");
            entity.Property(e => e.Clave).HasMaxLength(5);
            entity.Property(e => e.FkidUniversoNom).HasColumnName("FKIdUniverso_NOM");
            entity.Property(e => e.FechaCreacion).HasPrecision(6);
            entity.Property(e => e.FechaModificacion).HasPrecision(6);
            entity.Property(e => e.Activo).HasDefaultValue(true);

            entity.HasOne(d => d.FkidUniversoNomNavigation)
                .WithMany(p => p.Niveles)
                .HasForeignKey(d => d.FkidUniversoNom)
                .HasConstraintName("FK_NOM_Nivel_Universo");
        });

        modelBuilder.Entity<NomClasePuesto>(entity =>
        {
            entity.HasKey(e => e.PkidClasePuesto).HasName("PK_NOM_ClasePuesto");
            entity.ToTable("ClasePuesto", "NOM");
            entity.Property(e => e.PkidClasePuesto).HasColumnName("PKIdClasePuesto");
            entity.Property(e => e.Descripcion).HasMaxLength(64);
            entity.Property(e => e.FechaCreacion).HasPrecision(6);
            entity.Property(e => e.FechaModificacion).HasPrecision(6);
            entity.Property(e => e.Activo).HasDefaultValue(true);
        });

        modelBuilder.Entity<NomPuesto>(entity =>
        {
            entity.HasKey(e => e.PkidPuesto).HasName("PK_NOM_Puesto");
            entity.ToTable("Puesto", "NOM");
            entity.Property(e => e.PkidPuesto).HasColumnName("PKIdPuesto");
            entity.Property(e => e.FkidPuestoPadreNom).HasColumnName("FKIdPuestoPadre_NOM");
            entity.Property(e => e.FkidEmpresaNominaNom).HasColumnName("FKIdEmpresaNomina_NOM");
            entity.Property(e => e.Nombre).HasMaxLength(150);
            entity.Property(e => e.FkidNivelNom).HasColumnName("FKIdNivel_NOM");
            entity.Property(e => e.FkidClasePuestoNom).HasColumnName("FKIdClasePuesto_NOM");
            entity.Property(e => e.Descripcion1).HasMaxLength(150);
            entity.Property(e => e.Descripcion2).HasMaxLength(150);
            entity.Property(e => e.FechaCreacion).HasPrecision(6);
            entity.Property(e => e.FechaModificacion).HasPrecision(6);
            entity.Property(e => e.Activo).HasDefaultValue(true);

            entity.HasOne(d => d.FkidPuestoPadreNomNavigation)
                .WithMany(p => p.InverseFkidPuestoPadreNomNavigation)
                .HasForeignKey(d => d.FkidPuestoPadreNom)
                .HasConstraintName("FK_NOM_Puesto_Padre");

            entity.HasOne(d => d.FkidEmpresaNominaNomNavigation)
                .WithMany(p => p.Puestos)
                .HasForeignKey(d => d.FkidEmpresaNominaNom)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_NOM_Puesto_EmpresaNomina");

            entity.HasOne(d => d.FkidNivelNomNavigation)
                .WithMany(p => p.Puestos)
                .HasForeignKey(d => d.FkidNivelNom)
                .HasConstraintName("FK_NOM_Puesto_Nivel");

            entity.HasOne(d => d.FkidClasePuestoNomNavigation)
                .WithMany(p => p.Puestos)
                .HasForeignKey(d => d.FkidClasePuestoNom)
                .HasConstraintName("FK_NOM_Puesto_ClasePuesto");
        });

        modelBuilder.Entity<NomNombramiento>(entity =>
        {
            entity.HasKey(e => e.PkidNombramiento).HasName("PK_NOM_Nombramiento");
            entity.ToTable("Nombramiento", "NOM");
            entity.Property(e => e.PkidNombramiento).HasColumnName("PKIdNombramiento");
            entity.Property(e => e.Descripcion).HasMaxLength(80);
            entity.Property(e => e.FechaCreacion).HasPrecision(6);
            entity.Property(e => e.FechaModificacion).HasPrecision(6);
            entity.Property(e => e.Activo).HasDefaultValue(true);
        });

        modelBuilder.Entity<NomImporteNivel>(entity =>
        {
            entity.HasKey(e => e.PkidImporteNivel).HasName("PK_NOM_ImporteNivel");
            entity.ToTable("ImporteNivel", "NOM");
            entity.Property(e => e.PkidImporteNivel).HasColumnName("PKIdImporteNivel");
            entity.Property(e => e.Clave).HasMaxLength(5);
            entity.Property(e => e.ImpSdi).HasColumnType("decimal(18, 2)").HasColumnName("ImpSDI");
            entity.Property(e => e.ImpImss15).HasColumnType("decimal(18, 2)");
            entity.Property(e => e.ImpImss16).HasColumnType("decimal(18, 2)");
            entity.Property(e => e.FechaCreacion).HasPrecision(6);
            entity.Property(e => e.FechaModificacion).HasPrecision(6);
            entity.Property(e => e.Activo).HasDefaultValue(true);
        });

        modelBuilder.Entity<NomContratoLaboral>(entity =>
        {
            entity.HasKey(e => e.PkidContratoLaboral).HasName("PK_NOM_ContratoLaboral");
            entity.ToTable("ContratoLaboral", "NOM");
            entity.Property(e => e.PkidContratoLaboral).HasColumnName("PKIdContratoLaboral");
            entity.Property(e => e.FkidEmpresaNominaNom).HasColumnName("FKIdEmpresaNomina_NOM");
            entity.Property(e => e.FkidPersonaNom).HasColumnName("FKIdPersona_NOM");
            entity.Property(e => e.FkidPuestoNom).HasColumnName("FKIdPuesto_NOM");
            entity.Property(e => e.NumeroContrato).HasMaxLength(20);
            entity.Property(e => e.Vigencia).HasMaxLength(100);
            entity.Property(e => e.SueldoMensual).HasColumnType("decimal(18, 2)");
            entity.Property(e => e.FkidNombramientoNom).HasColumnName("FKIdNombramiento_NOM");
            entity.Property(e => e.FechaCreacion).HasPrecision(6);
            entity.Property(e => e.FechaModificacion).HasPrecision(6);
            entity.Property(e => e.Activo).HasDefaultValue(true);

            entity.HasOne(d => d.FkidEmpresaNominaNomNavigation)
                .WithMany()
                .HasForeignKey(d => d.FkidEmpresaNominaNom)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_NOM_ContratoLaboral_EmpresaNomina");

            entity.HasOne(d => d.FkidPersonaNomNavigation)
                .WithMany()
                .HasForeignKey(d => d.FkidPersonaNom)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_NOM_ContratoLaboral_Persona");

            entity.HasOne(d => d.FkidPuestoNomNavigation)
                .WithMany()
                .HasForeignKey(d => d.FkidPuestoNom)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_NOM_ContratoLaboral_Puesto");

            entity.HasOne(d => d.FkidNombramientoNomNavigation)
                .WithMany()
                .HasForeignKey(d => d.FkidNombramientoNom)
                .HasConstraintName("FK_NOM_ContratoLaboral_Nombramiento");
        });

        modelBuilder.Entity<NomCatalogoSimple>(entity =>
        {
            entity.HasKey(e => e.PkidCatalogoSimple).HasName("PK_NOM_CatalogoSimple");
            entity.ToTable("CatalogoSimple", "NOM");
            entity.HasIndex(e => new { e.Catalogo, e.LegacyTable, e.LegacyId }, "UX_NOM_CatalogoSimple_Legacy")
                .IsUnique()
                .HasFilter("[LegacyId] IS NOT NULL");
            entity.HasIndex(e => new { e.Catalogo, e.Clave }, "IX_NOM_CatalogoSimple_CatalogoClave");

            entity.Property(e => e.PkidCatalogoSimple).HasColumnName("PKIdCatalogoSimple");
            entity.Property(e => e.Catalogo).HasMaxLength(80);
            entity.Property(e => e.LegacyTable).HasMaxLength(128);
            entity.Property(e => e.Clave).HasMaxLength(50);
            entity.Property(e => e.Descripcion).HasMaxLength(250);
            entity.Property(e => e.DescripcionCorta).HasMaxLength(120);
            entity.Property(e => e.FkidCatalogoPadreNom).HasColumnName("FKIdCatalogoPadre_NOM");
            entity.Property(e => e.ValorDecimal1).HasColumnType("decimal(18, 4)");
            entity.Property(e => e.ValorDecimal2).HasColumnType("decimal(18, 4)");
            entity.Property(e => e.FechaInicio).HasColumnType("date");
            entity.Property(e => e.FechaFin).HasColumnType("date");
            entity.Property(e => e.DatoExtra1).HasMaxLength(500);
            entity.Property(e => e.DatoExtra2).HasMaxLength(500);
            entity.Property(e => e.FechaCreacion).HasPrecision(6);
            entity.Property(e => e.FechaModificacion).HasPrecision(6);
            entity.Property(e => e.Activo).HasDefaultValue(true);
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
