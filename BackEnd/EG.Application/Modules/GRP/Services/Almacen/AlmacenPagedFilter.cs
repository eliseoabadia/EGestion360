using System.Text.Json;
using EG.Common.GenericModel;

namespace EG.Application.Services.Almacen
{
    internal static class AlmacenPagedFilter
    {
        public static bool TryGetInt(PagedRequest request, string key, out int value)
        {
            value = 0;
            if (request.AdditionalFilters == null || !request.AdditionalFilters.TryGetValue(key, out var raw) || raw == null)
            {
                return false;
            }

            if (raw is JsonElement json)
            {
                if (json.ValueKind == JsonValueKind.Number && json.TryGetInt32(out value))
                {
                    return true;
                }

                if (json.ValueKind == JsonValueKind.String && int.TryParse(json.GetString(), out value))
                {
                    return true;
                }
            }

            return int.TryParse(raw.ToString(), out value);
        }

        public static bool TryGetBool(PagedRequest request, string key, out bool value)
        {
            value = false;
            if (request.AdditionalFilters == null || !request.AdditionalFilters.TryGetValue(key, out var raw) || raw == null)
            {
                return false;
            }

            if (raw is JsonElement json)
            {
                if (json.ValueKind == JsonValueKind.True || json.ValueKind == JsonValueKind.False)
                {
                    value = json.GetBoolean();
                    return true;
                }

                if (json.ValueKind == JsonValueKind.String && bool.TryParse(json.GetString(), out value))
                {
                    return true;
                }
            }

            return bool.TryParse(raw.ToString(), out value);
        }

        public static bool TryGetString(PagedRequest request, string key, out string value)
        {
            value = string.Empty;
            if (request.AdditionalFilters == null || !request.AdditionalFilters.TryGetValue(key, out var raw) || raw == null)
            {
                return false;
            }

            value = raw is JsonElement json
                ? json.ValueKind == JsonValueKind.String ? json.GetString() ?? string.Empty : json.ToString()
                : raw.ToString() ?? string.Empty;

            value = value.Trim();
            return !string.IsNullOrWhiteSpace(value);
        }
    }
}
