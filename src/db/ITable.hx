package db;

import Query.QueryExpr;
import promises.Promise;

interface ITable {
    public var db:IDatabase;
    public var name:String;
    public var exists:Bool;

    public function schema():Promise<DatabaseResult<TableSchema>>;
    public function applySchema(newSchema:TableSchema):Promise<DatabaseResult<TableSchema>>;

    public function all():Promise<DatabaseResult<RecordSet>>;
    public function page(pageIndex:Int, pageSize:Int = 100, query:QueryExpr = null, allowRelationships:Bool = true):Promise<DatabaseResult<RecordSet>>;
    public function add(record:Record):Promise<DatabaseResult<Record>>;
    public function addAll(records:RecordSet):Promise<DatabaseResult<RecordSet>>;
    public function delete(record:Record):Promise<DatabaseResult<Record>>;
    public function deleteAll(query:QueryExpr = null):Promise<DatabaseResult<Bool>>;
    public function update(query:QueryExpr, record:Record):Promise<DatabaseResult<Record>>;
    public function find(query:QueryExpr, allowRelationships:Bool = true):Promise<DatabaseResult<RecordSet>>;
    public function findOne(query:QueryExpr, allowRelationships:Bool = true):Promise<DatabaseResult<Record>>;
    public function findUnique(columnName:String, query:QueryExpr = null, allowRelationships:Bool = true):Promise<DatabaseResult<RecordSet>>;
    public function count(query:QueryExpr = null):Promise<DatabaseResult<Int>>;

    public function addColumn(column:ColumnDefinition):Promise<DatabaseResult<Bool>>;
    public function removeColumn(column:ColumnDefinition):Promise<DatabaseResult<Bool>>;

    #if allow_raw
    public function raw(data:String, values:Array<Any> = null):Promise<DatabaseResult<RecordSet>>;
    #end
}