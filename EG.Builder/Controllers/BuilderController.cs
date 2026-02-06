using EG.Builder.Models;
using EG.Builder.Templates;
using EG.Builder.Templates.Components;
using EG.Infraestructure.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Options;
using Microsoft.IdentityModel.Tokens;
using System.Data;
using System.Text;
using Const = EG.Builder.Commons.Constants;


namespace EG.Builder.Controllers
{

    [Route("[controller]")]
    [ApiController]
    [AllowAnonymous]
    public class BuilderController : Controller
    {
        private readonly IConfiguration _configuration ;
        private readonly EGestionContext _context;

        public BuilderController(IConfiguration configuration, EGestionContext context)
        {
            _configuration = configuration;
            _context = context;

        }

        //[HttpGet("GetTables")]
        //public async Task<IActionResult> GetTables()
        //{
        //    var queryTables = from t in _context.Model.GetEntityTypes().Where(t => t.GetTableName() != null).Select(t => $"{t.GetSchema()}.{t.GetTableName()}")
        //                      select t;

        //    var queryViews = from v in _context.Model.GetEntityTypes().Where(t => t.GetViewName() != null).Select(t => $"{t.GetViewSchema()}.{t.GetViewName()}")
        //                     select v;

        //    return Json(queryTables.Union(queryViews).Order().ToList());
        //}

        [HttpGet("GetTables")]
        public async Task<IActionResult> GetTables()
        {
            var result = await Task.Run(() =>
            {
                var entityTypes = _context.Model.GetEntityTypes();

                var tables = entityTypes
                    .Where(t => t.GetTableName() != null)
                    .Select(t => $"{t.GetSchema() ?? "dbo"}.{t.GetTableName()}");

                var views = entityTypes
                    .Where(t => t.GetViewName() != null)
                    .Select(t => $"{t.GetViewSchema() ?? "dbo"}.{t.GetViewName()}");

                return tables
                    .Union(views)
                    .OrderBy(name => name)
                    .ToList();
            });

            return Json(result);
        }

        [HttpGet("BuildTheScreen/{selectedElement}/{saveTheCode}")]
        public async Task<IActionResult> BuildTheScreen(string selectedElement, bool saveTheCode = false)
        {
            string itemService = string.Empty;
            string iitemService = string.Empty;
            string controllerTemplate = string.Empty;
            string iControllerTemplate = string.Empty;
            string viewTemplate = string.Empty;
            string viewCrearTemplate = string.Empty;
            string viewEdithTemplate = string.Empty;
            string viewDeleteTemplate = string.Empty;
            string controllerName = string.Empty;
            string message = string.Empty;

            await Task.Run(() =>
            {
                string notApplicable = string.Empty;
                
                string PK = string.Empty;
                string FK = string.Empty;


                (itemService, iitemService, controllerTemplate, iControllerTemplate, 
                viewTemplate, viewCrearTemplate, viewEdithTemplate, viewDeleteTemplate, controllerName, PK, FK) = BuildCodeSource(selectedElement, false);
                var (hasDetail, tableName) = HasTableDetail(selectedElement);

                controllerTemplate = controllerTemplate.Replace(Const.EDITDETAILPKFK, string.Empty).Replace(Const.EDITDETAILPARAMETER, string.Empty);
                viewTemplate = viewTemplate.Replace(Const.EDITDETAILTOINSERT, string.Empty);

                if (hasDetail)
                {
                    var parts = selectedElement.Split('.');
                    FK = string.Empty;

                    //(controDetailllerName, controllerDetailTemplate, viewDetailTemplate, notApplicable, FK) =
                    //    BuildCodeSource($"{parts[0]}.{tableName}", true, PK);
                }

                //// Limpieza inicial
                //controllerTemplate = controllerTemplate
                //    .Replace(Const.EDITDETAILPKFK, string.Empty)
                //    .Replace(Const.EDITDETAILPARAMETER, string.Empty);

                //viewTemplate = viewTemplate.Replace(Const.EDITDETAILTOINSERT, string.Empty);

                //if (!string.IsNullOrEmpty(viewDetailTemplate))
                //{
                //    viewDetailTemplate = viewDetailTemplate
                //        .Replace(Const.CONTENTDETAIL, string.Empty)
                //        .Replace(Const.TABLEDETAILUSING, string.Empty);

                //    var detView = ITemplateService.View.Replace(Const.CONTENTDETAIL, viewDetailTemplate);

                //    viewTemplate = viewTemplate
                //        .Replace(Const.CONTENTDETAIL, detView)
                //        .Replace(Const.EDITDETAILPKFK, Const.EDITDETAILLOADPARAMS.Replace(Const.EDITDETAILPKCOLUMN, PK))
                //        .Replace(Const.EDITDETAILTOINSERT, Const.EDITDETAILTOINSERTVALUE
                //            .Replace(Const.EDITDETAILPKCOLUMN, PK)
                //            .Replace(Const.EDITDETAILFKCOLUMN, FK));

                //    controllerDetailTemplate = controllerDetailTemplate
                //        .Replace(Const.EDITDETAILPARAMETER, Const.EDITDETAILPARAMETERVALUES)
                //        .Replace(Const.EDITDETAILPKFK, Const.EDITDETAILFKCOLUMNWHERE.Replace(Const.EDITDETAILFKCOLUMN, FK));
                //}
                //else
                //{
                //    viewTemplate = viewTemplate
                //        .Replace(Const.CONTENTDETAIL, string.Empty)
                //        .Replace(Const.EDITDETAILPKFK, string.Empty);
                //}

                //if (saveTheCode)
                //{
                //    var pathController = Path.Combine(_configuration["PathController"], $"{controllerName}Controller.cs");
                //    var pathView = Path.Combine(_configuration["PathView"], controllerName);

                //    System.IO.File.WriteAllText(pathController, controllerTemplate);

                //    if (!string.IsNullOrEmpty(controllerDetailTemplate))
                //    {
                //        var detailPath = Path.Combine(_configuration["PathController"], $"{controDetailllerName}Controller.cs");
                //        System.IO.File.WriteAllText(detailPath, controllerDetailTemplate);
                //    }

                //    Directory.CreateDirectory(pathView);
                //    System.IO.File.WriteAllText(Path.Combine(pathView, "Index.cshtml"), viewTemplate);
                //}

                message = saveTheCode ? "Código salvado correctamente" : "Código construido correctamente";
            });
            //itemService, iitemService, controllerTemplate, iControllerTemplate, viewTemplate, viewCrearTemplate, viewEdithTemplate, viewDeleteTemplate
            return Json(new
            {
                Tab1Content = controllerTemplate,
                Tab2Content = viewTemplate,
                Tab3Content = itemService,
                Tab4Content = viewCrearTemplate,
                Tab5Content = viewEdithTemplate,
                Tab6Content = viewDeleteTemplate,
                Tab7Content = iControllerTemplate,
                Tab8Content = iitemService,
                Message = message
            });
        }

        private (string, string, string, string, string, string, string, string, string, string, string) BuildCodeSource(string selectedElement, bool isMasterDetail, string pkIdMaster = "")
        {
            var parts = selectedElement.Split('.');

            if (parts.Length != 2)
                throw new ArgumentException("The selected element must be in the format 'schema.tableName'.");

            var schema = parts[0];
            var tableName = parts[1];

            var columnsInfo = GetColumns(schema, tableName);

            string controllerName = schema + tableName;
            var FK = string.Empty;
            var PK = string.Empty;
            if (tableName.Contains("VW_"))
                PK = columnsInfo.Where(x => x.Name.Contains("Pk")).FirstOrDefault().Name;
            else
                PK = columnsInfo.First(it => it.IsPK).Name;
            

                var buildColumnsList = columnsInfo.Where(it => !it.IsPK
                && it.Name != "UsuarioCreacion"
                && it.Name != "FechaCreacion"
                && it.Name != "UsuarioModificacion"
                && it.Name != "FechaModificacion"
                && it.Name != "Activo"
                )
                .ToList();

            var oFK = buildColumnsList.FirstOrDefault(it => it.IsFK);
            if (oFK != null)
                FK = oFK.Name;



            var (columnHeaderList, columnDetailist) = BuildColumnsListForController(buildColumnsList);
            //var (columnListView, columnComboListListView) = BuildColumnsListForView(buildColumnsList, controllerName, isMasterDetail, pkIdMaster);

            string _itemService = AppSerices.ItemService;
            string _iitemService = AppSerices.IItemService;
            string _controllerTemplate = ControllerTemplate.Controller;
            string _iControllerTemplate = ControllerTemplate.IController;
            string _viewTemplate = ViewTemplate.View;
            string _viewCrearTemplate = ViewCrearTemplate.View;
            string _viewEdithTemplate = ViewEdithTemplate.View;
            string _viewDeleteTemplate = ViewDeleteTemplate.View;

            string itemService = _itemService
                .Replace(Const.CONTROLLERNAME, controllerName)
                .Replace(Const.TABLENAME, tableName)
                .Replace(Const.PRIMARYKEY, PK)
                .Replace(Const.COLUMNHEADERLIST, columnHeaderList)
                .Replace(Const.COLUMNDETAILIST, columnDetailist);
            string iitemService = _iitemService
                .Replace(Const.CONTROLLERNAME, controllerName)
                .Replace(Const.TABLENAME, tableName)
                .Replace(Const.PRIMARYKEY, PK)
                .Replace(Const.COLUMNHEADERLIST, columnHeaderList)
                .Replace(Const.COLUMNDETAILIST, columnDetailist);

            string controllerTemplate = _controllerTemplate
                .Replace(Const.CONTROLLERNAME, controllerName)
                .Replace(Const.TABLENAME, tableName)
                .Replace(Const.PRIMARYKEY, PK)
                .Replace(Const.COLUMNHEADERLIST, columnHeaderList)
                .Replace(Const.COLUMNDETAILIST, columnDetailist);
            string iControllerTemplate = _iControllerTemplate
                .Replace(Const.CONTROLLERNAME, controllerName)
                .Replace(Const.TABLENAME, tableName)
                .Replace(Const.PRIMARYKEY, PK)
                .Replace(Const.COLUMNHEADERLIST, columnHeaderList)
                .Replace(Const.COLUMNDETAILIST, columnDetailist);

            string viewTemplate = _viewTemplate
                .Replace(Const.CONTROLLERNAME, controllerName)
                .Replace(Const.TABLENAME, tableName)
                .Replace(Const.PRIMARYKEY, PK)
                .Replace(Const.SEARCHHEADERTABLE, columnHeaderList)
                .Replace(Const.SEARCHDETAILTABLE, columnDetailist)
                .Replace(Const.ROUTEPAGEMENU, $"{tableName}s")
                
                .Replace(Const.COLUMNHEADERLIST, columnHeaderList)
                .Replace(Const.COLUMNDETAILIST, columnDetailist);

            string viewCrearTemplate = _viewCrearTemplate
                .Replace(Const.CONTROLLERNAME, controllerName)
                .Replace(Const.TABLENAME, tableName)
                .Replace(Const.PRIMARYKEY, PK)
                .Replace(Const.COLUMNHEADERLIST, columnHeaderList)
                .Replace(Const.COLUMNDETAILIST, columnDetailist);

            string viewEdithTemplate = _viewEdithTemplate
                .Replace(Const.CONTROLLERNAME, controllerName)
                .Replace(Const.TABLENAME, tableName)
                .Replace(Const.PRIMARYKEY, PK)
                .Replace(Const.COLUMNHEADERLIST, columnHeaderList)
                .Replace(Const.COLUMNDETAILIST, columnDetailist);

            string viewDeleteTemplate = _viewDeleteTemplate
                .Replace(Const.CONTROLLERNAME, controllerName)
                .Replace(Const.TABLENAME, tableName)
                .Replace(Const.PRIMARYKEY, PK)
                .Replace(Const.COLUMNHEADERLIST, columnHeaderList)
                .Replace(Const.COLUMNDETAILIST, columnDetailist);

            return (itemService, iitemService, controllerTemplate, iControllerTemplate, viewTemplate, viewCrearTemplate, viewEdithTemplate, viewDeleteTemplate, controllerName, PK, FK);
        }

        private List<ColumnInfo> GetColumns(string schema, string tableName)
        {
            // TODO: Resolver para vistas
            //var entityType = _context.Model.GetEntityTypes()
            //    .FirstOrDefault(e => e.GetSchema() == schema && e.GetTableName() == tableName)
            //    ?? throw new ArgumentException($"Table or view '{schema}.{tableName}' not found in the context.");

            //var properties = entityType.GetProperties();

            var queryTables = _context.Model.GetEntityTypes().FirstOrDefault(e => e.GetSchema() == schema && e.GetTableName() == tableName);

            var queryViews = _context.Model.GetEntityTypes().FirstOrDefault(e => e.GetViewSchema() == schema && e.GetViewName() == tableName);

            var properties = queryTables == null ? queryViews.GetProperties() : queryTables.GetProperties();

            var columnsInfo = properties.Select(p =>
            {
                var foreignKey = p.GetContainingForeignKeys().FirstOrDefault();
                var fkTableName = foreignKey?.PrincipalEntityType.GetTableName();
                var fkSchemaName = foreignKey?.PrincipalEntityType.GetSchema();

                return new ColumnInfo
                {
                    Name = p.Name,
                    Type = p.ClrType,
                    IsPK = p.IsPrimaryKey(),
                    IsFK = foreignKey != null,
                    FKSchemaName = fkSchemaName,
                    FKTableName = fkTableName
                };
            }).ToList();

            //foreach (var column in columnsInfo)
            //{
            //    if (column.Type == typeof(bool) || column.Type == typeof(bool?))
            //    {
            //        Console.WriteLine("Es booleano");
            //    }

            //    if (column.Type == typeof(string))
            //    {
            //        Console.WriteLine("Es string");
            //    }

            //    if (column.Type == typeof(int) || column.Type == typeof(int?))
            //    {
            //        Console.WriteLine("Es int");
            //    }

            //    if (column.Type == typeof(DateTime) || column.Type == typeof(DateTime?))
            //    {
            //        Console.WriteLine("Es DateTime");
            //    }

            //    if (column.Type == typeof(decimal) || column.Type == typeof(decimal?))
            //    {
            //        Console.WriteLine("Es decimal");
            //    }
            //}

            return columnsInfo;
        }

        private (string, string) BuildColumnsListForController(List<ColumnInfo> columnInfoList)
        {
            string columnHeaderList = "";
            string columnDetailist = "";

            foreach (var columnInfo in columnInfoList)
            {
                columnHeaderList += $"\t\t\t\t\t<MudTh><MudTableSortLabel SortLabel=\"{columnInfo.Name}\" T=\"{columnInfo.Name}Response\">ID</MudTableSortLabel></MudTh>\n";
                columnDetailist += $"\t\t\t\t\t<MudTd DataLabel=\"{columnInfo.Name}\">@context.{columnInfo.Name}</MudTd>\n";
                //columnList += "\t\t\t\t\tit." + columnInfo.Name + ",\n";

                //if (columnInfo.IsFK)
                //{
                //    var columnsInfoFK = GetColumns(columnInfo.FKSchemaName, columnInfo.FKTableName);
                //    var fkColName = GetFKColumnName(columnInfo, columnsInfoFK);
                //    var fkIdName = columnsInfoFK.Where(x => x.IsPK).FirstOrDefault().Name;

                //    columnListCombos += FieldsView.Controller
                //        .Replace(Const.PRIMARYFKKEY, fkIdName)
                //        .Replace(Const.TABLEFKNAME, columnInfo.FKTableName)
                //        .Replace(Const.DISPLAYNAMEFK, fkColName);
                //}
            }

            return (columnHeaderList, columnDetailist);
        }

        //public static string GenerateDto(string className, List<ColumnInfo> columns)
        //{
        //    var sb = new StringBuilder();
        //    sb.AppendLine($"public class {className}");
        //    sb.AppendLine("{");

        //    foreach (var col in columns)
        //    {
        //        string nullableSuffix = (col.IsNullable && col.Type != "string") ? "?" : "";
        //        sb.AppendLine($"    public {col.Type}{nullableSuffix} {col.Name} {{ get; set; }}");
        //    }

        //    sb.AppendLine("}");
        //    return sb.ToString();
        //}

        private (string, string) BuildColumnsListForView(List<ColumnInfo> columnInfoList, string controllerName, bool isMasterDetail, string pkIdMaster = "")
        {
            string columnList = "";
            string columnListCombos = "";

            foreach (var columnInfo in columnInfoList)
            {
                if(!columnInfo.IsFK)
                    columnList += $"\t\tcolumns.AddFor(m => m.{columnInfo.Name}).Caption(\"{columnInfo.Name}\");" + "\n";
                else {
                    var columnsInfoFK = GetColumns(columnInfo.FKSchemaName, columnInfo.FKTableName);
                    var fkColName = GetFKColumnName(columnInfo, columnsInfoFK);
                    var fkIdName = columnsInfoFK.Where(x => x.IsPK).FirstOrDefault().Name;

                    string cadCombo = ComboViewTemplate.View
                        .Replace(Const.CONTROLLERNAME, controllerName)
                        .Replace(Const.PRIMARYFKKEY, fkIdName)
                        .Replace(Const.COLPKHEADERNAME, columnInfo.Name)
                        .Replace(Const.TABLEFKNAME, columnInfo.FKTableName)
                        .Replace(Const.DISPLAYNAMEFK, fkColName);
                    if (isMasterDetail && cadCombo.Contains(pkIdMaster))
                        cadCombo = cadCombo.Replace(Const.ALLOWEDITINGDETAIL, Const.ALLOWEDITINGDETAILVALUE);
                    else
                        cadCombo = cadCombo.Replace(Const.ALLOWEDITINGDETAIL, string.Empty);

                    columnListCombos += cadCombo;
                }
            }

            return (columnList, columnListCombos);
        }

        private static string GetFKColumnName(ColumnInfo fkColumn, List<ColumnInfo> columnsInfoFK)
        {
            string fkColName;
            var fkIdName = columnsInfoFK.Where(x => x.IsPK).FirstOrDefault().Name;

            if (fkColumn.FKTableName.Contains("Anio"))
                fkColName = columnsInfoFK.Where(x => x.Name.StartsWith("Clave")).FirstOrDefault().Name;
            else if (fkColumn.FKTableName.Contains("Banco")
                        || fkColumn.FKTableName.Contains("Area")
                        || fkColumn.FKTableName.Contains("Municipio")
                        || fkColumn.FKTableName.Contains("Pais")
                        || fkColumn.FKTableName.Contains("Pantalla")
                        || fkColumn.FKTableName.Contains("Rol")
                        || fkColumn.FKTableName.Contains("TipoDoctoCLC")
                        || fkColumn.FKTableName.Contains("Persona")
                        || fkColumn.FKTableName.Contains("Estado"))
                fkColName = columnsInfoFK.Where(x => x.Name.StartsWith("Nombre")).FirstOrDefault().Name;
            else if (columnsInfoFK.Where(x => x.Name.Contains("Descripcion")).Any())
                fkColName = columnsInfoFK.Where(x => x.Name.Contains("Descripcion")).FirstOrDefault().Name;
            else
                fkColName = fkIdName;

            return fkColName;
        }

        private (bool, string) HasTableDetail(string selectedElement)
        {
            if (selectedElement.Contains("VW_"))
                return (false, string.Empty);

            string tableDetailName = string.Empty;
            var parts = selectedElement.Split('.');

            if (parts.Length != 2)
                throw new ArgumentException("The selected element must be in the format 'schema.tableName'.");

            var schema = parts[0];
            var tableName = parts[1];

            bool result = false;
            var modelData = _context.Model.GetEntityTypes().Where(e => e.GetSchema() == schema && e.GetTableName() == tableName)
            .Select(entityType => new
            {
                entityType.ClrType.Name,
                NavigationProperties = entityType.GetNavigations().Select(x => x.PropertyInfo)
            }).FirstOrDefault();

            if (modelData.NavigationProperties.Any(x => x.Name.Contains($"Detalle{tableName}")))
            {
                result = true;
                tableDetailName = modelData.NavigationProperties.First(x => x.Name.Contains($"Detalle{tableName}")).Name;
            }
            return (result, tableDetailName);
        }
    }
}
