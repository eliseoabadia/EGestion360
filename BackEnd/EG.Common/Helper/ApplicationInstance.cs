
using System.Collections.Concurrent;


namespace EG.Common.Helper
{
    public class ApplicationInstance
    {

        public ConcurrentDictionary<string, object> Application { get; } = new ConcurrentDictionary<string, object>();
        //private static ConcurrentDictionary<string, object> _appVariables = new ConcurrentDictionary<string, object>();

        // Method to set or update a variable in the ConcurrentDictionary
        public void SetVariable(string key, object value)
        {
            Application.AddOrUpdate(key, value, (oldKey, oldValue) => value);
        }
    }
}
