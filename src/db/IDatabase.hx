package db;

import promises.Promise;

interface IDatabase {
    public function config(details:Dynamic):Void;
    public function setProperty(name:String, value:Any):Void;
    public function getProperty(name:String, defaultValue:Any):Any;

    public function schema():Promise<DatabaseResult<DatabaseSchema>>;

    public function defineTableRelationship(field1:String, field2:String):Void;
    public function definedTableRelationships():RelationshipDefinitions;
    public function clearTableRelationships():Void;

    public function connect():Promise<DatabaseResult<Bool>>;
    public function disconnect():Promise<DatabaseResult<Bool>>;

    public function create():Promise<DatabaseResult<IDatabase>>;
    public function delete():Promise<DatabaseResult<Bool>>;

    public function table(name:String):Promise<DatabaseResult<ITable>>;
    public function createTable(name:String, columns:Array<ColumnDefinition>):Promise<DatabaseResult<ITable>>;
    public function deleteTable(name:String):Promise<DatabaseResult<Bool>>;

    #if allow_raw
    public function raw(data:String, values:Array<Any> = null):Promise<DatabaseResult<RecordSet>>;
    #end
}