using System.Data;
using EG.Domain.DTOs.Responses.Adquisicion;
using EG.Infraestructure.Models;
using Microsoft.Data.SqlClient;
using Microsoft.EntityFrameworkCore;

namespace EG.Application.Services.Adquisicion
{
    public static class OrcoProyectoCatalog
    {
        public static IQueryable<OrcoProyectoResponse> ActiveProjectsQuery(EGestionContext context)
        {
            return context.Pies
                .AsNoTracking()
                .Where(x => x.Activo)
                .Select(x => new OrcoProyectoResponse
                {
                    PkidProyecto = x.PkidPy,
                    Descripcion = x.Descripcion ?? string.Empty,
                    Activo = x.Activo
                });
        }

        public static async Task<bool> EnsureProyectoOrcoAsync(
            EGestionContext context,
            int? proyectoId,
            int usuarioId)
        {
            if (!proyectoId.HasValue)
            {
                return true;
            }

            var proyectoPres = await context.Pies
                .AsNoTracking()
                .Where(x => x.PkidPy == proyectoId.Value && x.Activo)
                .Select(x => new { x.PkidPy, x.Descripcion })
                .FirstOrDefaultAsync();

            if (proyectoPres == null)
            {
                return false;
            }

            var userId = usuarioId > 0 ? usuarioId : 1;
            var descripcion = proyectoPres.Descripcion ?? string.Empty;

            await context.Database.ExecuteSqlRawAsync(
                """
                BEGIN TRY
                    IF EXISTS (SELECT 1 FROM [ORCO].[Proyecto] WHERE [PKIdProyecto] = @ProyectoId)
                    BEGIN
                        UPDATE [ORCO].[Proyecto]
                           SET [Descripcion] = @Descripcion,
                               [Activo] = 1,
                               [FechaModificacion] = SYSDATETIME(),
                               [UsuarioModificacion] = @UsuarioId
                         WHERE [PKIdProyecto] = @ProyectoId;
                    END
                    ELSE
                    BEGIN
                        SET IDENTITY_INSERT [ORCO].[Proyecto] ON;

                        INSERT INTO [ORCO].[Proyecto]
                            ([PKIdProyecto], [Descripcion], [Activo], [FechaCreacion], [UsuarioCreacion])
                        VALUES
                            (@ProyectoId, @Descripcion, 1, SYSDATETIME(), @UsuarioId);

                        SET IDENTITY_INSERT [ORCO].[Proyecto] OFF;
                    END
                END TRY
                BEGIN CATCH
                    BEGIN TRY
                        SET IDENTITY_INSERT [ORCO].[Proyecto] OFF;
                    END TRY
                    BEGIN CATCH
                    END CATCH;

                    THROW;
                END CATCH;
                """,
                new SqlParameter("@ProyectoId", proyectoId.Value),
                new SqlParameter("@Descripcion", SqlDbType.NVarChar, 256) { Value = descripcion },
                new SqlParameter("@UsuarioId", userId));

            return true;
        }
    }
}
