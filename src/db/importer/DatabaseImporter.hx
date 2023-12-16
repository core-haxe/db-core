package db.importer;

import promises.PromiseUtils;
import promises.Promise;

using StringTools;

class DatabaseImporter implements IDatabaseImporter {
    public function new() {
    }

    public function importFromString(db:IDatabase, data:String, options:DatabaseImportOptions = null):Promise<IDatabase> {
        return new Promise((resolve, reject) -> {
            var schema = stringToSchema(data);
            if (schema == null) {
                throw 'could not parse string to schema';
            }

            var finalSchema = schema.clone();
            // TODO: remove unneeded tables etc

            var createTablePromises = [];
            var importDataPromises = [];
            for (tableSchema in finalSchema.tables) {
                createTablePromises.push(createTableFromSchema.bind(db, tableSchema));

                var useData = (tableSchema.data != null && tableSchema.data.length > 0);
                if (options != null) {
                    useData = !options.structureOnly;
                    var tableImportOptions = options.getTableOptions(tableSchema.name);
                    if (tableImportOptions != null) {
                        useData = !tableImportOptions.structureOnly;
                    }
                }

                if (useData) {
                    importDataPromises.push({id: tableSchema.name, promise: importTableData.bind(db, tableSchema)});
                }
            }

            PromiseUtils.runSequentially(createTablePromises).then(_ -> {
                return PromiseUtils.runAllMapped(importDataPromises);
            }).then(result -> {
                resolve(db);
            }, error -> {
                reject(error);
            });

            /*
            for (table in schema.tables) {
                trace(table.name);
                for (c in table.columns) {
                    trace("    " + c.name, c.type, c.options);
                }
                if (table.data != null) {
                    for (record in table.data) {
                        trace("        " + record.debugString());
                    }
                } else {
                    trace("    NO DATA!");
                }
                trace("");
            }
            */
        });
    }

    private function createTableFromSchema(db:IDatabase, tableSchema:TableSchema):Promise<Bool> {
        return new Promise((resolve, reject) -> {
            db.createTable(tableSchema.name, tableSchema.columns).then(_ -> {
                resolve(true);
            }, error -> {
                reject(error);
            });
        });
    }

    private function importTableData(db:IDatabase, tableSchema:TableSchema):Promise<Bool> {
        return new Promise((resolve, reject) -> {
            db.table(tableSchema.name).then(result -> {
                return result.table.addAll(tableSchema.data);
            }).then(result -> {
                resolve(true);
            }, error -> {
                reject(error);
            });
        });
    }

    private function stringToSchema(data:String):DatabaseSchema {
        return null;
    }

    private function stringToColumnType(data:String):ColumnType {
        if (data == null) {
            return Unknown;
        }

        if (data == 'Number') {
            return Number;
        } else if (data == 'Decimal') {
            return Decimal;
        } else if (data == 'Boolean') {
            return Boolean;
        } else if (data == 'Memo') {
            return Memo;
        } else if (data == 'Binary') {
            return Binary;
        } else if (data.startsWith('Text(') && data.endsWith(')')) {
            var s = data.replace('Text(', '').replace(')', '');
            return Text(Std.parseInt(s));
        }
        return Unknown;
    }

    private function stringToColumnOption(data:String):ColumnOptions {
        if (data == null) {
            return null;
        }

        if (data == "PrimaryKey") {
            return PrimaryKey;
        } else if (data == "NotNull") {
            return NotNull;
        } else if (data == "AutoIncrement") {
            return AutoIncrement;
        }

        return null;
    }
}