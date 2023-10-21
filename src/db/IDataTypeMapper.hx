package db;

interface IDataTypeMapper {
    public function haxeTypeToDatabaseType(haxeType:ColumnType):String;
    public function shouldConvertValueToDatabase(value:Any):Bool;
    public function convertValueToDatabase(value:Any):Any;
}