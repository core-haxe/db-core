package db;

interface IDataTypeMapper {
    public function haxeTypeToDatabaseType(haxeType:ColumnType):String;
}