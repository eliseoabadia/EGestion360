namespace EG.Web.Pages.Shared;

public interface ICrudDialogFormHost
{
    void RegisterComponent(object component);
    void UnregisterComponent(object component);
}
