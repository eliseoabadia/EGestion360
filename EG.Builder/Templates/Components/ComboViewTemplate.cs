namespace EG.Builder.Templates.Components;
public static class ComboViewTemplate
{
    public static string View =
@"      
        columns.AddFor(m => m.COLPKHEADERNAME).Caption(""TABLEFKNAME"")ALLOWEDITINGDETAIL
           .Lookup(lookup => lookup.DataSource(ds => ds.Mvc().Controller(""CONTROLLERNAME"").LoadAction(""GetTABLEFKNAME"").Key(""PRIMARYFKKEY""))
                                   .DisplayExpr(""DISPLAYNAMEFK"")
                                   .ValueExpr(""PRIMARYFKKEY""));
";
}

