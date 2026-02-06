namespace EG.Builder.Commons
{
    public static class Constants
    {
        #region Constants

        public const string CONTROLLERNAME = "CONTROLLERNAME";
        public const string TABLENAME = "TABLENAME";
        public const string PRIMARYKEY = "PKIDENEITY";
        public const string COLUMNHEADERLIST = "SEARCHHEADERTABLE";
        public const string ROUTEPAGEMENU = "ROUTEPAGEMENU";
        

        public const string DISPLAYNAMEFK = "DISPLAYNAMEFK";
        public const string COLPKHEADERNAME = "COLPKHEADERNAME";
        public const string PRIMARYFKKEY = "PRIMARYFKKEY";
        public const string COLUMNDETAILIST = "FUNCTIONSFKLIST";
        public const string SEARCHHEADERTABLE = "SEARCHHEADERTABLE";
        public const string SEARCHDETAILTABLE = "SEARCHDETAILTABLE";



        #endregion

        #region ConstantsMasterDetail

        
            public const string PK_ = "PK_";

        public const string TABLEDETAILUSING = "@using GRP.Model.Entities";
        public const string TABLEFKNAME = "TABLEFKNAME";
        public const string CONTENTDETAIL = "CONTENTDETAIL";

        public const string EDITDETAILPARAMETER = "EDITDETAILPARAMETER";
        public const string EDITDETAILPKFK = "EDITDETAILPKFK";

        public const string EDITDETAILPKCOLUMN = "PKColumn";
        public const string EDITDETAILFKCOLUMN = "FkColumn";

        public const string EDITDETAILPARAMETERVALUES = "int id, ";
        public const string EDITDETAILLOADPARAMS = ".LoadParams(new { id = new JS(\"data.PKColumn\") })";
        public const string EDITDETAILFKCOLUMNWHERE = "it.FkColumn == id && ";

        public const string ALLOWEDITINGDETAIL = "ALLOWEDITINGDETAIL";
        public const string ALLOWEDITINGDETAILVALUE = ".AllowEditing(false)";

        public const string EDITDETAILTOINSERT = "EDITDETAILTOINSERT";
        public const string EDITDETAILTOINSERTVALUE = ".OnInitNewRow(\"function(e) { e.data.FkColumn = \" + new JS(\"data.PKColumn\") + \"; }\")";


        #endregion
    }
}
