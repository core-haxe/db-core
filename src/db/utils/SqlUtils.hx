package db.utils;

import db.Query.QueryExpr;

using StringTools;

class SqlUtils {
    public static function buildInsert(table:ITable, record:Record, values:Array<Any> = null):String {
        var fieldNames = fieldNamesFromRecord(record);
        var sql = 'INSERT INTO ${table.name} (${fieldNames.join(", ")}) VALUES ';
        var placeholders = [];
        for (f in record.fieldNames) {
            placeholders.push('?');
            if (values != null) {
                values.push(record.field(f));
            }
        }
        sql += '(${placeholders.join(", ")})';
        sql += ';';
        return sql;
    }

    public static function buildSelect(table:ITable, query:QueryExpr = null, limit:Null<Int> = null, values:Array<Any> = null, relationships:RelationshipDefinitions = null, databaseSchema:DatabaseSchema = null):String {
        var alwaysAliasResultFields:Bool = table.db.getProperty("alwaysAliasResultFields");
        var fieldAliases = [];
        var sqlJoin = buildJoins(table.name, null, table.name, relationships, databaseSchema, fieldAliases);
        if (alwaysAliasResultFields == true || (fieldAliases != null && fieldAliases.length > 0)) {
            var tableSchema = databaseSchema.findTable(table.name);
            if (tableSchema != null) {
                for (tableColumn in tableSchema.columns) {
                    fieldAliases.insert(0, '${table.name}.${tableColumn.name} AS `${table.name}.${tableColumn.name}`');
                }
            }
        }

        var fieldList = '*';
        if (fieldAliases.length > 0) {
            fieldList = fieldAliases.join(", ");
        }
        var sql = 'SELECT ${fieldList} FROM ${table.name}';
        sql += sqlJoin;

        if (query != null) {
            sql += '\nWHERE (${Query.queryExprToSql(query, values, table.name)})';
        }
        if (limit != null) {
            sql += ' LIMIT ' + limit;
        }
        sql += ';';
        return sql;
    }

    private static function buildJoins(tableName:String, prefix:String, fieldNamePrefix:String, relationships:RelationshipDefinitions, databaseSchema:DatabaseSchema, fieldAliases:Array<String>) {
        if (relationships == null) {
            return "";
        }
        var sql = "";

        var tableRelationships = relationships.get(tableName);
        if (tableRelationships == null) {
            return "";
        }
        

        for (tableRelationship in tableRelationships) {
            var table1 = tableRelationship.table1;
            if (prefix != null) {
                table1 = prefix + "." + table1;
            }
            var field1 = tableRelationship.field1;
            var table2 = tableRelationship.table2;
            var field2 = tableRelationship.field2;
            var joinName = tableRelationship.table1 + "." + table2;
            if (prefix != null) {
                joinName = prefix + "." + joinName;
            }

            var tableSchema = databaseSchema.findTable(table2);
            if (tableSchema == null) {
                continue;
            }
            for (tableColumn in tableSchema.columns) {
                fieldAliases.push('`${joinName}`.`${tableColumn.name}` AS `${fieldNamePrefix}.${table2}.${tableColumn.name}`');
            }

            sql += '\n    LEFT JOIN `${table2}` AS `${joinName}` ON `${joinName}`.`${field2}` = `${table1}`.`${field1}`';
            sql += buildJoins(table2, table1, fieldNamePrefix + "." + table2, relationships, databaseSchema, fieldAliases);
        }
        
        return sql;
    }

    public static function buildDeleteRecord(table:ITable, record:Record, values:Array<Any> = null):String {
        var fieldNames = fieldNamesFromRecord(record);
        var sql = 'DELETE FROM ${table.name} WHERE ';
        var placeholders = [];
        for (f in record.fieldNames) {
            placeholders.push('${f} = ?');
            if (values != null) {
                values.push(record.field(f));
            }
        }
        sql += '(${placeholders.join(" AND ")})';
        sql += ';';
        return sql;
    }

    public static function buildDeleteWhere(table:ITable, query:QueryExpr):String {
        var sql = 'DELETE FROM ${table.name}';
        if (query != null) {
            sql += ' WHERE (${Query.queryExprToSql(query)})';
        }
        sql += ';';
        return sql;
    }

    public static function buildUpdate(table:ITable, query:QueryExpr, record:Record, values:Array<Any> = null):String {
        var fieldNames = fieldNamesFromRecord(record);
        var sql = 'UPDATE ${table.name} SET ';
        var placeholders = [];
        for (f in record.fieldNames) {
            var v = record.field(f);
            if (v == null) {
                placeholders.push('${f} = NULL');
            } else {
                placeholders.push('${f} = ?');
                if (values != null) {
                    values.push(v);
                }
            }
        }
        sql += '${placeholders.join(", ")}';
        sql += ' WHERE (${Query.queryExprToSql(query)})';
        sql += ';';
        return sql;
    }

    private static function fieldNamesFromRecord(record:Record):Array<String> {
        var names = [];
        for (f in record.fieldNames) {
            names.push('`${f}`');
        }
        return names;
    }
}