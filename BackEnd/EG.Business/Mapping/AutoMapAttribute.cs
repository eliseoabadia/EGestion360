namespace EG.Business.Mapping
{
    [AttributeUsage(AttributeTargets.Class)]
    public class AutoMapAttribute : Attribute
    {
        public AutoMapAttribute(params Type[] targetTypes)
        {
            TargetTypes = targetTypes;
        }

        public Type[] TargetTypes { get; }
    }
}