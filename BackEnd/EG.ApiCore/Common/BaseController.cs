using Microsoft.AspNetCore.Mvc;

public abstract class BaseController : Controller
{
    public int UserId { get; set; }
    public bool Lectura { get; set; }
    public bool Escritura { get; set; }
    public string IpAddress { get; set; }
    public string ControllerName => GetType().Name.Replace("Controller", "");
}