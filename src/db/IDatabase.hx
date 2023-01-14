package db;

import promises.Promise;

interface IDatabase {
    public function config(details:Dynamic):Void;

    public function defineTableRelationship(field1:String, field2:String):Void;
    public function definedTableRelationships():RelationshipDefinitions;

    public function connect():Promise<DatabaseResult<Bool>>;
    public function disconnect():Promise<DatabaseResult<Bool>>;

    public function table(name:String):Promise<DatabaseResult<ITable>>;
    public function createTable(name:String, columns:Array<ColumnDefinition>):Promise<DatabaseResult<ITable>>;
    public function deleteTable(name:String):Promise<DatabaseResult<Bool>>;
}