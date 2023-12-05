package db.export;

import promises.PromiseUtils;
import promises.Promise;

class DatabaseExporter implements IDatabaseExporter {
    public function new() {
    }

    public function export(db:IDatabase, options:DatabaseExportOptions = null):Promise<String> {
        return new Promise((resolve, reject) -> {
            var finalSchema:DatabaseSchema = null;
            db.schema().then(result -> {
                var schema:DatabaseSchema = result.data;
                finalSchema = schema.clone();
                // TODO: remove unneeded tables etc

                var promises = [];
                for (table in finalSchema.tables) {
                    var getData = true;
                    if (options != null) {
                        getData = !options.structureOnly;
                        var tableExportOptions = options.getTableOptions(table.name);
                        if (tableExportOptions != null) {
                            getData = !tableExportOptions.structureOnly;
                        }
                    }

                    if (getData) {
                        promises.push({id: table.name, promise: getAllTableData.bind(db, table.name)});
                    }
                }
                return PromiseUtils.runAllMapped(promises);
            }).then(results -> {
                for (resultId in results.keys()) {
                    var result = results.get(resultId);
                    if (result != null) {
                        var table = finalSchema.findTable(resultId);
                        if (table != null) {
                            table.data = result;
                        }
                    }
                }
                var stringResult = schemaToString(finalSchema);
                resolve(stringResult);
            }, error -> {
                reject(error);
            });
        });
    }

    private function getAllTableData(db:IDatabase, tableName:String):Promise<Array<Record>> {
        return new Promise((resolve, reject) -> {
            db.table(tableName).then(result -> {
                return result.table.all();
            }).then(result -> {
                resolve(result.data);
            }, error -> {
                trace(error);
                reject(error);
            });
        });
    }

    private function schemaToString(schema:DatabaseSchema):String {
        return null;
    }

    private function columnTypeToString(type:ColumnType):String {
        return switch (type) {
            case Number:    'Number';
            case Decimal:   'Decimal';
            case Boolean:   'Boolean';
            case Text(n):   'Text($n)';
            case Memo:      'Memo';
            case Binary:    'Binary';
            case Unknown:   'Unknown';        
        }
    }

    private function columnOptionToString(option:ColumnOptions):String {
        return switch (option) {
            case PrimaryKey:    return "PrimaryKey";
            case NotNull:       return "NotNull";
            case AutoIncrement: return "AutoIncrement";
        }
    }
}