
namespace EG.Builder.Templates.Components;
public static class FieldsView
{
    public static string Controller =
@"
        [HttpGet(""GetTABLEFKNAME"")]
        public object GetTABLEFKNAME(DataSourceLoadOptions loadOptions)
        {
            var _catResult = _context.TABLEFKNAME.Where(y => y.CtLive).Select(x => new { x.PRIMARYFKKEY, x.DISPLAYNAMEFK });

            return DataSourceLoader.Load(_catResult.AsSplitQuery().ToList(), loadOptions);
        }
";
}

