namespace EG.Builder.Models;
public class ColumnInfo
{
    public string Name { get; set; }
    public Type Type { get; set; }
    public bool IsPK { get; set; }
    public bool IsFK { get; set; }
    
    public string FKSchemaName { get; set; }
    public string FKTableName { get; set; }
}

