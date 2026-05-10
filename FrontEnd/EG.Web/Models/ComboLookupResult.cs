using EG.Common.GenericModel;

namespace EG.Web.Models;

public class ComboLookupResult
{
    public IEnumerable<LookupItem> Items { get; set; } = Enumerable.Empty<LookupItem>();
    public int TotalCount { get; set; }
}
