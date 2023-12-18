package db.exporter;

import haxe.crypto.Base64;
import haxe.Json;
import haxe.io.Bytes;

class JsonDatabaseExporter extends DatabaseExporter {
    private override function schemaToString(schema:DatabaseSchema):String {
        var json:Dynamic = {};
        json.tables = [];
        for (t in schema.tables) {
            json.tables.push(tableSchemaToJson(t));
        }
        return Json.stringify(json, "    ");
    }

    private function tableSchemaToJson(tableSchema:TableSchema):Dynamic {
        var json:Dynamic = {};
        json.name = tableSchema.name;
        json.columns = [];
        var columnNames = [];
        for (c in tableSchema.columns) {
            json.columns.push(tableColumnToJson(c));
            columnNames.push(c.name);
        }
        if (tableSchema.data != null) {
            json.data = [];
            for (record in tableSchema.data) {
                var recordData = [];
                for (columnName in columnNames) {
                    recordData.push(convertFieldData(record.field(columnName)));
                }
                json.data.push(recordData);
            }
        }
        return json;
    }

    private function convertFieldData(fieldData:Any):Any {
        if ((fieldData is Bytes)) {
            return Base64.encode(fieldData);
        }
        return fieldData;
    }

    private function tableColumnToJson(column:ColumnDefinition):Dynamic {
        var json:Dynamic = {};
        json.name = column.name;
        json.type = columnTypeToString(column.type);
        json.options = [];
        if (column.options != null) {
            for (o in column.options) {
                json.options.push(columnOptionToString(o));
            }
        }
        return json;
    }
}