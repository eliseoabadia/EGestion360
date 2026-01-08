using System.IO.Compression;
using System.Text;

namespace EG.Common.Helper
{
    public static class CompressionText
    {
        public static string ZipText(string text)
        {
            byte[] byteArray = Encoding.UTF8.GetBytes(text);
            using (var ms = new MemoryStream())
            {
                using (var gzip = new GZipStream(ms, CompressionMode.Compress, true))
                {
                    gzip.Write(byteArray, 0, byteArray.Length);
                }
                return Convert.ToBase64String(ms.ToArray());
            }
        }

        public static string UnzipText(string compressedText)
        {
            byte[] byteArray = Convert.FromBase64String(compressedText);
            using (var ms = new MemoryStream(byteArray))
            {
                using (var gzip = new GZipStream(ms, CompressionMode.Decompress))
                {
                    using (var reader = new StreamReader(gzip))
                    {
                        return reader.ReadToEnd();
                    }
                }
            }
        }

    }

}
