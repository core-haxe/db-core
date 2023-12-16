package db.importer;

import promises.Promise;

interface IDatabaseImporter {
    public function importFromString(db:IDatabase, data:String, options:DatabaseImportOptions = null):Promise<IDatabase>;
}