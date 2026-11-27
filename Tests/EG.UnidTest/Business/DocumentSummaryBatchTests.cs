using EG.Application.Services.SoporteDocumental;
using EG.Business.Interfaces;
using EG.Domain.DTOs.Requests.SoporteDocumental;
using EG.Domain.DTOs.Responses.SoporteDocumental;
using EG.UnidTest.Support;

namespace EG.UnidTest.Business;

public sealed class DocumentSummaryBatchTests
{
    [Fact]
    public async Task ClientCompanyCannotReplaceAuthenticatedScope()
    {
        var queries = new Queries();
        var service = new DocumentSummaryAppService(queries, new FixedUserContext(1, 7));
        await service.ReadBatchAsync([new() { Modulo = "PBR", EntidadId = 1, FkidEmpresaSis = 999 }]);
        Assert.Equal(7, queries.Company);
    }

    [Fact]
    public async Task OversizedBatchIsRejectedBeforeDatabase()
    {
        var queries = new Queries();
        var service = new DocumentSummaryAppService(queries, new FixedUserContext(1, 7));
        await Assert.ThrowsAsync<ArgumentException>(() => service.ReadBatchAsync(
            Enumerable.Range(1, 101).Select(id => new DocumentoEntidadRequest { Modulo = "PBR", EntidadId = id }).ToList()));
        Assert.Null(queries.Company);
    }

    private sealed class Queries : IDocumentSummaryQueries
    {
        public int? Company { get; private set; }
        public Task<List<DocumentoResumenResponse>> ReadBatchAsync(IReadOnlyList<DocumentoEntidadRequest> requests, int empresaId)
        { Company = empresaId; return Task.FromResult(new List<DocumentoResumenResponse>()); }
    }
}
