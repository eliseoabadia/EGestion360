using System.Security.Cryptography;
using System.Text;
using EG.Application.Interfaces.FirmaDocumental;
using EG.Domain.Platform.Settings;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;

namespace EG.Application.Services.FirmaDocumental
{
    public sealed class AesFirmaCertificateProtector : IFirmaCertificateProtector
    {
        private const int KeySizeBytes = 32;
        private const int NonceSizeBytes = 12;
        private const int TagSizeBytes = 16;
        private static readonly byte[] EphemeralKey = RandomNumberGenerator.GetBytes(KeySizeBytes);
        private readonly byte[] _key;

        public AesFirmaCertificateProtector(
            IOptions<FirmaDocumentalSettings> options,
            ILogger<AesFirmaCertificateProtector> logger)
        {
            var configuredKey = options.Value.VaultKey;
            if (string.IsNullOrWhiteSpace(configuredKey))
            {
                _key = EphemeralKey;
                logger.LogWarning("FirmaDocumental: VaultKey no configurado. La boveda usara llave efimera; configure FirmaDocumental:VaultKey para persistencia real.");
                return;
            }

            _key = SHA256.HashData(Encoding.UTF8.GetBytes(configuredKey));
        }

        public string Protect(byte[] content)
        {
            var nonce = RandomNumberGenerator.GetBytes(NonceSizeBytes);
            var cipher = new byte[content.Length];
            var tag = new byte[TagSizeBytes];

            using var aes = new AesGcm(_key, TagSizeBytes);
            aes.Encrypt(nonce, content, cipher, tag);

            var payload = new byte[nonce.Length + tag.Length + cipher.Length];
            Buffer.BlockCopy(nonce, 0, payload, 0, nonce.Length);
            Buffer.BlockCopy(tag, 0, payload, nonce.Length, tag.Length);
            Buffer.BlockCopy(cipher, 0, payload, nonce.Length + tag.Length, cipher.Length);
            return Convert.ToBase64String(payload);
        }

        public byte[] Unprotect(string protectedContent)
        {
            var payload = Convert.FromBase64String(protectedContent);
            if (payload.Length < NonceSizeBytes + TagSizeBytes)
                throw new InvalidOperationException("El contenido protegido de la bóveda es inválido.");

            var nonce = payload[..NonceSizeBytes];
            var tag = payload[NonceSizeBytes..(NonceSizeBytes + TagSizeBytes)];
            var cipher = payload[(NonceSizeBytes + TagSizeBytes)..];
            var plain = new byte[cipher.Length];

            using var aes = new AesGcm(_key, TagSizeBytes);
            aes.Decrypt(nonce, cipher, tag, plain);
            return plain;
        }
    }
}
