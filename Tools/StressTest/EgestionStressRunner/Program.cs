using System.Collections.Concurrent;
using System.Diagnostics;
using System.Net.Http.Headers;
using System.Text.Json;

var options = StressOptions.FromArgs(args);
var url = $"{options.BaseUrl.TrimEnd('/')}/{options.Endpoint.TrimStart('/')}";

using var handler = new SocketsHttpHandler
{
    MaxConnectionsPerServer = Math.Max(1, options.Concurrency),
    PooledConnectionLifetime = TimeSpan.FromMinutes(2)
};
using var client = new HttpClient(handler)
{
    Timeout = TimeSpan.FromSeconds(options.TimeoutSeconds)
};
client.DefaultRequestHeaders.Accept.Add(new MediaTypeWithQualityHeaderValue("application/json"));

if (!string.IsNullOrWhiteSpace(options.Token))
{
    client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", options.Token.Trim().Replace("Bearer ", "", StringComparison.OrdinalIgnoreCase));
}

var latencies = new ConcurrentBag<double>();
var statuses = new ConcurrentBag<int>();
var errors = new ConcurrentBag<string>();
var next = 0;
var watch = Stopwatch.StartNew();

var workers = Enumerable.Range(0, options.Concurrency)
    .Select(_ => Task.Run(async () =>
    {
        while (true)
        {
            var current = Interlocked.Increment(ref next);
            if (current > options.TotalRequests)
            {
                break;
            }

            var requestWatch = Stopwatch.StartNew();
            try
            {
                using var response = await client.GetAsync(url);
                requestWatch.Stop();
                latencies.Add(requestWatch.Elapsed.TotalMilliseconds);
                statuses.Add((int)response.StatusCode);
            }
            catch (Exception ex)
            {
                requestWatch.Stop();
                latencies.Add(requestWatch.Elapsed.TotalMilliseconds);
                statuses.Add(0);
                errors.Add(ex.Message);
            }
        }
    }))
    .ToArray();

await Task.WhenAll(workers);
watch.Stop();

var latencyValues = latencies.Order().ToArray();
var statusValues = statuses.ToArray();
var successCount = statusValues.Count(status => status >= 200 && status < 300);
var failedCount = options.TotalRequests - successCount;
var durationSeconds = Math.Max(watch.Elapsed.TotalSeconds, 0.001d);
var successRate = options.TotalRequests > 0 ? successCount / (double)options.TotalRequests : 0d;
var p95 = Percentile(latencyValues, 95);
var p99 = Percentile(latencyValues, 99);
var latencyScore = Math.Clamp((1000d - p95) / 1000d, 0d, 1d);
var stabilityScore = p99 <= 2500d ? 1d : Math.Clamp(2500d / Math.Max(p99, 1d), 0d, 1d);
var effectiveness = ((successRate * 0.60d) + (latencyScore * 0.30d) + (stabilityScore * 0.10d)) * 100d;

var result = new
{
    Url = url,
    options.TotalRequests,
    options.Concurrency,
    Success = successCount,
    Failed = failedCount,
    SuccessRatePercent = Math.Round(successRate * 100d, 2),
    RequestsPerSecond = Math.Round(options.TotalRequests / durationSeconds, 2),
    AverageMs = Math.Round(latencyValues.Length == 0 ? 0d : latencyValues.Average(), 2),
    P50Ms = Math.Round(Percentile(latencyValues, 50), 2),
    P95Ms = Math.Round(p95, 2),
    P99Ms = Math.Round(p99, 2),
    MaxMs = Math.Round(latencyValues.Length == 0 ? 0d : latencyValues[^1], 2),
    EffectivenessPercent = Math.Round(effectiveness, 2),
    ErrorSamples = errors.Take(5).ToArray()
};

Console.WriteLine(JsonSerializer.Serialize(result, new JsonSerializerOptions { WriteIndented = true }));

static double Percentile(double[] values, double percentile)
{
    if (values.Length == 0)
    {
        return 0d;
    }

    var index = (int)Math.Ceiling((percentile / 100d) * values.Length) - 1;
    index = Math.Clamp(index, 0, values.Length - 1);
    return values[index];
}

sealed record StressOptions(
    string BaseUrl,
    string Endpoint,
    int TotalRequests,
    int Concurrency,
    int TimeoutSeconds,
    string Token)
{
    public static StressOptions FromArgs(string[] args)
    {
        var values = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);
        for (var index = 0; index < args.Length; index++)
        {
            var key = args[index];
            if (!key.StartsWith("--", StringComparison.Ordinal) || index + 1 >= args.Length)
            {
                continue;
            }

            values[key[2..]] = args[++index];
        }

        return new StressOptions(
            Get(values, "base-url", "http://localhost:5058"),
            Get(values, "endpoint", "/api/Navigate/ping"),
            GetInt(values, "requests", 1000),
            GetInt(values, "concurrency", 50),
            GetInt(values, "timeout", 10),
            Get(values, "token", string.Empty));
    }

    private static string Get(IReadOnlyDictionary<string, string> values, string key, string fallback)
        => values.TryGetValue(key, out var value) && !string.IsNullOrWhiteSpace(value) ? value : fallback;

    private static int GetInt(IReadOnlyDictionary<string, string> values, string key, int fallback)
        => values.TryGetValue(key, out var value) && int.TryParse(value, out var parsed) && parsed > 0 ? parsed : fallback;
}
