namespace EG.Web.Extensions;
public class DialogState
{
    private Dictionary<string, object> _forms = new();

    public void RegisterForm(string key, object form)
    {
        _forms[key] = form;
    }

    public T? GetForm<T>(string key) where T : class
    {
        return _forms.TryGetValue(key, out var form) ? form as T : null;
    }

    public void Clear()
    {
        _forms.Clear();
    }
}