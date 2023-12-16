package db.exporter;

import Query.QueryExpr;

typedef TableExportOptions = {
    var name:String;
    var ?structureOnly:Bool;
    var ?query:QueryExpr;
}