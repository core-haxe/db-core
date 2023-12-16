package db.importer;

import haxe.crypto.Base64;
import haxe.Json;

class JsonDatabaseImporter extends DatabaseImporter {
    private override function stringToSchema(data:String):DatabaseSchema {
        var json = Json.parse(data);
        var schema:DatabaseSchema = {};

        if (json.tables != null) {
            var jsonTables:Array<Dynamic> = json.tables;
            for (jsonTable in jsonTables) {
                var tableSchema = jsonToTableSchema(jsonTable) ;
                if (tableSchema != null) {
                    schema.tables.push(tableSchema);
                }
            }
        }

        return schema;
    }

    private function jsonToTableSchema(json:Dynamic):TableSchema {
        var tableSchema:TableSchema = {};
        tableSchema.name = json.name;
        if (json.columns != null) {
            var jsonColumns:Array<Dynamic> = json.columns;
            for (jsonColumn in jsonColumns) {
                var columnDef = jsonToColumnDefinition(jsonColumn);
                if (columnDef != null) {
                    tableSchema.columns.push(columnDef);
                }
            }

            if (json.data != null) {
                var jsonData:Array<Array<Dynamic>> = json.data;
                assignTableData(tableSchema, jsonData);
            }
        }
        return tableSchema;
    }

    private function assignTableData(tableSchema:TableSchema, data:Array<Array<Dynamic>>) {
        tableSchema.data = [];
        for (item in data) {
            var record = new Record();
            for (i in 0...item.length) {
                var columnName = tableSchema.columns[i].name;
                var columnValue = item[i];
                record.field(columnName, convertFieldData(columnValue, tableSchema.columns[i]));
            }
            tableSchema.data.push(record);
        }
    }

    private function convertFieldData(fieldData:Any, columnDef:ColumnDefinition):Any {
        if (Std.string(fieldData) == "null") {
            return null;
        }
        if (columnDef.type == Binary) {
            return Base64.decode(Std.string(fieldData));
        }
        return fieldData;
    }

    private function jsonToColumnDefinition(json:Dynamic):ColumnDefinition {
        var columnDef:ColumnDefinition = {
            name: json.name,
            type: stringToColumnType(json.type),
            options: []
        };
        if (json.options != null) {
            var jsonOptions:Array<String> = json.options;
            for (jsonOption in jsonOptions) {
                columnDef.options.push(stringToColumnOption(jsonOption));
            }
        }
        return columnDef;
    }
}