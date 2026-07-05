namespace EG.Application.Interfaces.FirmaDocumental
{
    public interface IFirmaCertificateProtector
    {
        string Protect(byte[] content);
        byte[] Unprotect(string protectedContent);
    }
}
