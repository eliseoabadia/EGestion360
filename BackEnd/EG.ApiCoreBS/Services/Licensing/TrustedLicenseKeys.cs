namespace EG.ApiCoreBS.Services.Licensing;

internal static class TrustedLicenseKeys
{
    private static readonly IReadOnlyDictionary<string, string> PublicKeys =
        new Dictionary<string, string>(StringComparer.Ordinal)
        {
            ["2026-01"] = """
                -----BEGIN PUBLIC KEY-----
                MIIBojANBgkqhkiG9w0BAQEFAAOCAY8AMIIBigKCAYEA8CuqPFXjQCbLwx9JyIRu
                SAFAKNaIyoc+ZP0lPd7vDfmsx/yqIbbjMnjswV6FHi9eXzA8oZzO7oDFOfXC+Q+2
                CummsKlPAdhz3bJu9oek2Kbhhx8rKd5pM3wxJooSzjK+063l6AoJL4w+Vn9pHGNB
                Q3Ts2skmaRqG1f/H+FIsoDuPTj2jxsASck2nuCD08LHzHRFXUMWh/F8YO9Zedhyd
                nrYF3gygr4S3GS8ETwIMPR4WyaviDIg4LpoHC3PyP2y0xBjz8VjzjFsMAeSTjheQ
                JZu6dDtCfwt/GMOFbXWUaWQhz2v3HZRE4tBzELn5FuKyHxsnN9LQkOnfRgt7gb68
                dXFtsqpnrkL8brqnD1RyJld+RN/78q/h1n44wZVC9waokm+DP0qBj+h7qP/x7AT6
                JAZfn0OVdB9cv0Rzcwe7MlKlYghqiXXeYm4dmcDxHmRvGMm4qw0OmbxNuRfngw/R
                cM5s3obuSG/vZEoFlruwr5PLNKBeiuUmsrDYRzt0mH3RAgMBAAE=
                -----END PUBLIC KEY-----
                """
        };

    internal static bool TryGet(string keyId, out string publicKeyPem) =>
        PublicKeys.TryGetValue(keyId, out publicKeyPem!);
}
