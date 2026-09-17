using System.Diagnostics;
using System.Reflection;
var temp = Path.Combine(Path.GetTempPath(), "GE360-" + Guid.NewGuid());
Directory.CreateDirectory(temp);
int result = 1;
try {
 var asm = Assembly.GetExecutingAssembly();
 using (var input = asm.GetManifestResourceStream(asm.GetManifestResourceNames().Single(n => n.EndsWith("Configurar.ps1"))))
 using (var output = File.Create(Path.Combine(temp,"Configurar.ps1"))) input!.CopyTo(output);
 var start = new ProcessStartInfo("powershell.exe") { UseShellExecute = false };
 foreach(var arg in new[]{"-NoProfile","-ExecutionPolicy","Bypass","-File",Path.Combine(temp,"Configurar.ps1"),"-PackagePath",AppContext.BaseDirectory}) start.ArgumentList.Add(arg);
 using var process = Process.Start(start)!;
 process.WaitForExit(); result = process.ExitCode;
} catch(Exception ex) { Console.Error.WriteLine(ex.Message); }
finally { Directory.Delete(temp,true); }
Console.WriteLine(result == 0 ? "Configuracion terminada." : "Configuracion incompleta. Revise el error anterior.");
Console.WriteLine("Presione ENTER para cerrar."); Console.ReadLine();
return result;
