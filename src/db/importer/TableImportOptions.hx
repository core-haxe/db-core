package db.importer;

typedef TableImportOptions = {
    var name:String;
    var ?structureOnly:Bool;
    var ?truncateFirst:Bool;
}