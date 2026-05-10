using EG.Common.GenericModel;
using Microsoft.EntityFrameworkCore;

namespace EG.ApiCoreBS.Helpers
{
    public static class LookupPagingHelper
    {
        public static async Task<PagedResult<LookupItem>> ToPagedResultAsync(
            IQueryable<LookupItem> query,
            int page = 1,
            int pageSize = 25,
            string? filter = null)
        {
            page = Math.Max(page, 1);
            pageSize = Math.Clamp(pageSize, 1, 100);

            if (!string.IsNullOrWhiteSpace(filter))
            {
                var term = filter.Trim();
                query = query.Where(x => x.Text.Contains(term));
            }

            var totalCount = await query.CountAsync();
            var items = await query
                .Skip((page - 1) * pageSize)
                .Take(pageSize)
                .ToListAsync();

            return new PagedResult<LookupItem>
            {
                Success = true,
                Message = "OK",
                Code = "SUCCESS",
                Items = items,
                TotalCount = totalCount
            };
        }
    }
}
