const fs=require('node:fs');const file='FrontEnd/EG.Web/Pages/Shared/BaseCrudPage.razor.cs';let s=fs.readFileSync(file,'utf8').replaceAll('\r\n','\n');const start=s.indexOf('        var items = new List<TResponse>();',s.indexOf('LoadExportItemsAsync()'));const end=s.indexOf('\n    protected virtual async Task ExportToExcel()',start);if(start<0||end<0)throw Error('Export loader not found');s=s.slice(0,start)+`        var sortLabel = string.IsNullOrWhiteSpace(SortLabel) ? GetDefaultSortLabel() : SortLabel;
        var search = SearchString;
        var direction = SortDirection;
        var filters = GetAdditionalFilters();
        var result = await EG.Web.Models.Forms.PagedExportReader.ReadAsync(
            (page, size) => Service.GetAllPaginadoAsync(page, size, search, sortLabel, direction, filters),
            ExportPageSize, MaxExportRows);
        if (result.Limited)
            Snackbar.Add($"La exportacion se limito a {MaxExportRows:N0} registros. Ajusta filtros para exportar menos datos.", Severity.Warning);
        return result.Items;
    }
`+s.slice(end);fs.writeFileSync(file,s);
const bienes='FrontEnd/EG.Web/Pages/Modules/GRP/Patrimonio/Bienes.razor';s=fs.readFileSync(bienes,'utf8').replaceAll('\r\n','\n');const a=s.indexOf('    protected override async Task ExportToExcel()'),b=s.indexOf('    protected override async Task ReloadData()',a);if(a<0||b<0)throw Error('Bienes export not found');s=s.slice(0,a)+s.slice(b);fs.writeFileSync(bienes,s);
