package db.export;

import promises.Promise;

interface IDatabaseExporter {
    public function export(db:IDatabase, options:DatabaseExportOptions = null):Promise<String>;
}
