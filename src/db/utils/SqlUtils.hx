package db.utils;

import db.Query.QueryExpr;

class SqlUtils {
    public static function buildInsert(table:ITable, record:Record, values:Array<Any> = null):String {
        var fieldNames = record.fieldNames;
        var sql = 'INSERT INTO ${table.name} (${fieldNames.join(", ")}) VALUES ';
        var placeholders = [];
        for (f in fieldNames) {
            placeholders.push('?');
            if (values != null) {
                values.push(record.field(f));
            }
        }
        sql += '(${placeholders.join(", ")})';
        sql += ';';
        return sql;
    }

    public static function buildSelect(table:ITable, query:QueryExpr = null, limit:Null<Int> = null, values:Array<Any> = null):String {
        var sql = 'SELECT * FROM ${table.name}';
        if (query != null) {
            sql += ' WHERE (${Query.queryExprToSql(query, values)})';
        }
        if (limit != null) {
            sql += ' LIMIT ' + limit;
        }
        sql += ';';
        return sql;
    }

    public static function buildDeleteRecord(table:ITable, record:Record, values:Array<Any> = null):String {
        var fieldNames = record.fieldNames;
        var sql = 'DELETE FROM ${table.name} WHERE ';
        var placeholders = [];
        for (f in fieldNames) {
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
        var fieldNames = record.fieldNames;
        var sql = 'UPDATE ${table.name} SET ';
        var placeholders = [];
        for (f in fieldNames) {
            placeholders.push('${f} = ?');
            if (values != null) {
                values.push(record.field(f));
            }
        }
        sql += '${placeholders.join(", ")}';
        sql += ' WHERE (${Query.queryExprToSql(query)})';
        sql += ';';
        return sql;
    }
}