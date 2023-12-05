package db.export;

import Query.QueryExpr;

typedef TableExportOptions = {
    var name:String;
    var ?structureOnly:Bool;
    var ?query:QueryExpr;
}