package db;

@:structInit
class TableSchema {
    @:optional public var name:String;
    @:optional public var columns:Array<ColumnDefinition> = [];
}