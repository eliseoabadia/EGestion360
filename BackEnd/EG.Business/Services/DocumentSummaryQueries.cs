using System.Text.Json;
using EG.Business.Interfaces;
using EG.Domain.DTOs.Requests.SoporteDocumental;
using EG.Domain.DTOs.Responses.SoporteDocumental;
using EG.Infraestructure.Models;
using Microsoft.Data.SqlClient;
using Microsoft.EntityFrameworkCore;

namespace EG.Business.Services;

public sealed class DocumentSummaryQueries(EGestionContext context) : IDocumentSummaryQueries
{
    public async Task<List<DocumentoResumenResponse>> ReadBatchAsync(IReadOnlyList<DocumentoEntidadRequest> requests, int empresaId)
    {
        var json = JsonSerializer.Serialize(requests);
        return await context.Database.SqlQueryRaw<DocumentoResumenResponse>("""
            SELECT d.Modulo, d.SubModulo, d.Controlador, d.Servicio, d.EntidadId,
                   d.FkidEmpresaSis, d.TotalDocumentos, d.TotalBytes, d.UltimaFechaDocumento
            FROM SIS.Vw_DocumentoResumenEntidad d
            INNER JOIN (
                SELECT DISTINCT Modulo, SubModulo, Controlador, Servicio, EntidadId
                FROM OPENJSON(@Requests) WITH (
                    Modulo nvarchar(150) '$.Modulo', SubModulo nvarchar(150) '$.SubModulo',
                    Controlador nvarchar(150) '$.Controlador', Servicio nvarchar(150) '$.Servicio',
                    EntidadId bigint '$.EntidadId')
            ) q ON d.Modulo=q.Modulo AND ISNULL(d.SubModulo,N'')=ISNULL(q.SubModulo,N'')
                AND ISNULL(d.Controlador,N'')=ISNULL(q.Controlador,N'')
                AND ISNULL(d.Servicio,N'')=ISNULL(q.Servicio,N'') AND d.EntidadId=q.EntidadId
            WHERE d.FkidEmpresaSis=@EmpresaId
            """, new SqlParameter("@Requests", json), new SqlParameter("@EmpresaId", empresaId)).ToListAsync();
    }
}
