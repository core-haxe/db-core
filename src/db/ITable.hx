package db;

import db.Query.QueryExpr;
import promises.Promise;

interface ITable {
    public var db:IDatabase;
    public var name:String;
    public var exists:Bool;

    public function all():Promise<DatabaseResult<Array<Record>>>;
    public function page(pageIndex:Int, pageSize:Int = 100, query:QueryExpr = null):Promise<DatabaseResult<Array<Record>>>;
    public function add(record:Record):Promise<DatabaseResult<Record>>;
    public function addAll(records:Array<Record>):Promise<DatabaseResult<Array<Record>>>;
    public function delete(record:Record):Promise<DatabaseResult<Record>>;
    public function deleteAll(query:QueryExpr = null):Promise<DatabaseResult<Bool>>;
    public function update(query:QueryExpr, record:Record):Promise<DatabaseResult<Record>>;
    public function find(query:QueryExpr):Promise<DatabaseResult<Array<Record>>>;
    public function findOne(query:QueryExpr):Promise<DatabaseResult<Record>>;
}