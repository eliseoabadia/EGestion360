// <manual> Complements EF Core Power Tools output for objects consumed by migrated services. </manual>
#nullable disable
using Microsoft.EntityFrameworkCore;

namespace EG.Infraestructure.Models;

public partial class EGestionContext
{
    public virtual DbSet<OrdenCompra> OrdenCompras { get; set; }

    public virtual DbSet<OrdenCompraDetalle> OrdenCompraDetalles { get; set; }

    public virtual DbSet<OrdenCompraPartidum> OrdenCompraPartida { get; set; }

    public virtual DbSet<VwOrdenCompra> VwOrdenCompras { get; set; }

    public virtual DbSet<VwOrdenCompraDetalle> VwOrdenCompraDetalles { get; set; }

    public virtual DbSet<VwOrdenCompraPartidum> VwOrdenCompraPartida { get; set; }

    public virtual DbSet<VwResguardo> VwResguardos { get; set; }

    public virtual DbSet<VwResguardoDetalle> VwResguardoDetalles { get; set; }

    partial void OnModelCreatingPartial(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<OrdenCompra>(entity =>
        {
            entity.HasKey(e => e.PkidOrdenCompra);
            entity.ToTable("OrdenCompra", "ORCO");
            entity.Property(e => e.PkidOrdenCompra).HasColumnName("PKIdOrdenCompra");
            entity.Property(e => e.FkidEmpresaSis).HasColumnName("FKIdEmpresa_SIS");
            entity.Property(e => e.FkidRequisicionOrco).HasColumnName("FKIdRequisicion_ORCO");
            entity.Property(e => e.FkidProveedorSis).HasColumnName("FKIdProveedor_SIS");
            entity.Property(e => e.FkidPolizaConta).HasColumnName("FKIdPoliza_CONTA");
            entity.Property(e => e.FkidEstatusOrdenCompraOrco).HasColumnName("FKIdEstatusOrdenCompra_ORCO");
            entity.Property(e => e.FlDocumento).HasColumnName("FL_Documento");
        });

        modelBuilder.Entity<OrdenCompraDetalle>(entity =>
        {
            entity.HasKey(e => e.PkidOrdenCompraDetalle);
            entity.ToTable("OrdenCompraDetalle", "ORCO");
            entity.Property(e => e.PkidOrdenCompraDetalle).HasColumnName("PKIdOrdenCompraDetalle");
            entity.Property(e => e.FkidOrdenCompraOrco).HasColumnName("FKIdOrdenCompra_ORCO");
            entity.Property(e => e.FkidRequisicionDetalleOrco).HasColumnName("FKIdRequisicionDetalle_ORCO");
            entity.Property(e => e.FkidCotizacionDetalleOrco).HasColumnName("FKIdCotizacionDetalle_ORCO");
            entity.Property(e => e.FkidTipoBienAlma).HasColumnName("FKIdTipoBien_ALMA");
            entity.Property(e => e.FkidUnidadesAlma).HasColumnName("FKIdUnidades_ALMA");
        });

        modelBuilder.Entity<OrdenCompraPartidum>(entity =>
        {
            entity.HasKey(e => e.PkidOrdenCompraPartida);
            entity.ToTable("OrdenCompraPartida", "ORCO");
            entity.Property(e => e.PkidOrdenCompraPartida).HasColumnName("PKIdOrdenCompraPartida");
            entity.Property(e => e.FkidOrdenCompraOrco).HasColumnName("FKIdOrdenCompra_ORCO");
            entity.Property(e => e.FkidPartidaConta).HasColumnName("FKIdPartida_CONTA");
            entity.Property(e => e.FkidFuenteFinanciamientoPres).HasColumnName("FKIdFuenteFinanciamiento_PRES");
        });

        modelBuilder.Entity<VwOrdenCompra>(entity =>
        {
            entity.HasNoKey();
            entity.ToView("Vw_OrdenCompra", "ORCO");
            entity.Property(e => e.PkidOrdenCompra).HasColumnName("PKIdOrdenCompra");
            entity.Property(e => e.FkidEmpresaSis).HasColumnName("FKIdEmpresa_SIS");
            entity.Property(e => e.FkidRequisicionOrco).HasColumnName("FKIdRequisicion_ORCO");
            entity.Property(e => e.FkidProveedorSis).HasColumnName("FKIdProveedor_SIS");
            entity.Property(e => e.ProveedorRfc).HasColumnName("ProveedorRFC");
            entity.Property(e => e.FkidPolizaConta).HasColumnName("FKIdPoliza_CONTA");
            entity.Property(e => e.FkidEstatusOrdenCompraOrco).HasColumnName("FKIdEstatusOrdenCompra_ORCO");
            entity.Property(e => e.FlDocumento).HasColumnName("FL_Documento");
        });

        modelBuilder.Entity<VwOrdenCompraDetalle>(entity =>
        {
            entity.HasNoKey();
            entity.ToView("Vw_OrdenCompraDetalle", "ORCO");
            entity.Property(e => e.PkidOrdenCompraDetalle).HasColumnName("PKIdOrdenCompraDetalle");
            entity.Property(e => e.FkidOrdenCompraOrco).HasColumnName("FKIdOrdenCompra_ORCO");
            entity.Property(e => e.FkidRequisicionDetalleOrco).HasColumnName("FKIdRequisicionDetalle_ORCO");
            entity.Property(e => e.FkidCotizacionDetalleOrco).HasColumnName("FKIdCotizacionDetalle_ORCO");
            entity.Property(e => e.FkidTipoBienAlma).HasColumnName("FKIdTipoBien_ALMA");
            entity.Property(e => e.Cabms).HasColumnName("CABMS");
            entity.Property(e => e.FkidUnidadesAlma).HasColumnName("FKIdUnidades_ALMA");
        });

        modelBuilder.Entity<VwOrdenCompraPartidum>(entity =>
        {
            entity.HasNoKey();
            entity.ToView("Vw_OrdenCompraPartida", "ORCO");
            entity.Property(e => e.PkidOrdenCompraPartida).HasColumnName("PKIdOrdenCompraPartida");
            entity.Property(e => e.FkidOrdenCompraOrco).HasColumnName("FKIdOrdenCompra_ORCO");
            entity.Property(e => e.FkidPartidaConta).HasColumnName("FKIdPartida_CONTA");
            entity.Property(e => e.FkidFuenteFinanciamientoPres).HasColumnName("FKIdFuenteFinanciamiento_PRES");
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
