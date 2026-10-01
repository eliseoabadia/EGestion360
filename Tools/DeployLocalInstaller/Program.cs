using System.Diagnostics;
using System.Reflection;
using System.IO.Compression;

Console.Title = "Instalador EGestion360 - Front HTTPS / Backend local 5555";
var assembly = Assembly.GetExecutingAssembly();
if (args.Contains("--verify")) {
    using var payload = assembly.GetManifestResourceStream("Payload.zip") ?? throw new Exception("Sin payload");
    using var zip = new ZipArchive(payload);
    foreach (var required in new[]{"Front/web.config", "Front/wwwroot/appsettings.Production.json", "Back/EG.ApiCoreBS.dll", "Back/appsettings.Production.json"})
        if (!zip.Entries.Any(e => e.FullName.Replace('\\','/') == required)) throw new Exception("Falta " + required);
    using var script = assembly.GetManifestResourceStream("Instalar.ps1") ?? throw new Exception("Sin script");
    Console.WriteLine("Payload e instalador verificados: " + zip.Entries.Count + " archivos.");
    return 0;
}
int result = 1;
try {
    var temp = Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.CommonApplicationData), "EGestion360", "Instaladores", Guid.NewGuid().ToString("N"));
    Directory.CreateDirectory(temp);
    foreach (var name in new[]{"Instalar.ps1", "Payload.zip"}) {
        using var input = assembly.GetManifestResourceStream(name) ?? throw new Exception("Falta recurso " + name);
        using var output = File.Create(Path.Combine(temp,name));
        input.CopyTo(output);
    }
    Console.WriteLine("Instalando en C:\\GestionEmpresarial. Se guardara un respaldo antes de reemplazar archivos.");
    var start = new ProcessStartInfo(Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.Windows), "System32", "WindowsPowerShell", "v1.0", "powershell.exe")) { UseShellExecute=false };
    foreach (var arg in new[]{"-NoProfile", "-ExecutionPolicy", "Bypass", "-File", Path.Combine(temp,"Instalar.ps1"), "-Payload", Path.Combine(temp,"Payload.zip")}) start.ArgumentList.Add(arg);
    using var process = Process.Start(start) ?? throw new Exception("No se pudo iniciar el instalador");
    process.WaitForExit(); result=process.ExitCode;
} catch (Exception ex) { Console.WriteLine("ERROR: " + ex.Message); }
Console.WriteLine(result == 0 ? "Listo. El backend seguira funcionando al cerrar esta ventana." : "La instalacion no termino correctamente. Revisa el error mostrado y el registro.");
Console.WriteLine("Presiona Entrar para cerrar.");
Console.ReadLine();
return result;