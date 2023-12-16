package db.exporter;

import promises.Promise;

interface IDatabaseExporter {
    public function exportToString(db:IDatabase, options:DatabaseExportOptions = null):Promise<String>;
}
