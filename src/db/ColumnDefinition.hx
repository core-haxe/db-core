package db;

@:structInit
class ColumnDefinition {
    public var name:String;
    public var type:ColumnType;
    @:optional public var options:Null<Array<ColumnOptions>>;
}