using System.Text.Json;
using EG.Business.Interfaces;
using EG.Common;
using EG.Common.Exceptions;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.Adquisicion;
using EG.Domain.DTOs.Responses.Adquisicion;
using EG.Domain.Interfaces;
using EG.Infraestructure.Models;
using Mapster;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;

namespace EG.Business.Services;

public sealed partial class PaaaService : IPaaaService
{
    private readonly IRepositoryProvider repositories;
    private readonly IPaaaPersistence persistence;
    private readonly IUserContextService userContext;
    private readonly ILogger<PaaaService> logger;

    public PaaaService(IRepositoryProvider repositories, IPaaaPersistence persistence,
        IUserContextService userContext, ILogger<PaaaService> logger)
    {
        this.repositories = repositories;
        this.persistence = persistence;
        this.userContext = userContext;
        this.logger = logger;
    }

    private IQueryable<T> Query<T>() where T : class => repositories.For<T>().QueryWithIncludes(_ => true).AsNoTracking();

    private static bool TryReadYear(PagedRequest request, out int year)
    {
        year = 0;
        if (request.AdditionalFilters == null || !request.AdditionalFilters.TryGetValue("FkidAnioSis", out var raw) || raw == null) return false;
        return raw is JsonElement json && json.ValueKind == JsonValueKind.Number
            ? json.TryGetInt32(out year) : int.TryParse(raw.ToString(), out year);
    }

    private static (int Page, int Size) Paging(PagedRequest request)
    {
        var size = Math.Clamp(request.PageSize <= 0 ? 25 : request.PageSize, 1, 250);
        return (Math.Clamp(request.Page, 1, int.MaxValue / size), size);
    }

    private static async Task<PagedResult<LookupItem>> LookupAsync(IQueryable<LookupItem> query, PagedRequest request, string message)
    {
        var count = await query.CountAsync();
        var (page, size) = Paging(request);
        var result = Success(await query.Skip((page - 1) * size).Take(size).ToListAsync(), message);
        result.TotalCount = count;
        return result;
    }

    private async Task<PagedResult<T>> ExecuteAsync<T>(Func<Task<PagedResult<T>>> operation)
    {
        try { return await operation(); }
        catch (UserVisibleException exception) { return Failure<T>(exception.UserMessage, exception.Code); }
        catch (KeyNotFoundException) { return Failure<T>("Registro no encontrado.", "NOT_FOUND"); }
        catch (UnauthorizedAccessException) { return Failure<T>("No tienes acceso a esta área o empresa.", "FORBIDDEN"); }
        catch (Exception exception)
        {
            logger.LogError(exception, "No se pudo completar la operación de PAAAS.");
            return Failure<T>(UserFacingMessages.UnexpectedError, "ERROR");
        }
    }

    private static PagedResult<T> Failure<T>(string message, string code) => new() { Success = false, Code = code, Message = message };
    private static PagedResult<T> Success<T>(IList<T> items, string message) => new()
    {
        Success = true, Code = "SUCCESS", Message = message, Items = items, TotalCount = items.Count
    };
    private static PagedResult<T> Single<T>(T item, string message)
    {
        var result = Success<T>([item], message);
        result.Data = item;
        return result;
    }
}
