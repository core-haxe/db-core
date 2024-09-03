package db.utils;

import Query.QueryExpr;
import haxe.io.Bytes;

using StringTools;

class SqlUtils {
    public static function buildInsert(table:ITable, record:Record, values:Array<Any> = null, typeMapper:IDataTypeMapper = null):String {
        var fieldNames = fieldNamesFromRecord(record);
        var sql = 'INSERT INTO ${table.name} (${fieldNames.join(", ")}) VALUES ';
        var placeholders = [];
        for (f in record.fieldNames) {
            placeholders.push('?');
            if (values != null) {
                values.push(record.field(f));
            }
        }
        if (typeMapper != null) {
            for (i in 0...values.length) {
                var v = values[i];
                if (typeMapper.shouldConvertValueToDatabase(v)) {
                    v = typeMapper.convertValueToDatabase(v);
                    values[i] = v;
                }
            }
        }
        sql += '(${placeholders.join(", ")})';
        sql += ';';
        return sql;
    }

    public static function buildSelect(table:ITable, query:QueryExpr = null, limit:Null<Int> = null, offset:Null<Int> = null, values:Array<Any> = null, relationships:RelationshipDefinitions = null, databaseSchema:DatabaseSchema = null):String {
        var alwaysAliasResultFields:Bool = table.db.getProperty("alwaysAliasResultFields", false);
        var fieldAliases = [];
        var sqlJoin = buildJoins(table.name, null, relationships, databaseSchema, fieldAliases);
        if (alwaysAliasResultFields == true || (fieldAliases != null && fieldAliases.length > 0)) {
            if (databaseSchema != null) {
                var tableSchema = databaseSchema.findTable(table.name);
                if (tableSchema != null) {
                    for (tableColumn in tableSchema.columns) {
                        fieldAliases.insert(0, '${table.name}.`${tableColumn.name}` AS `${table.name}.${tableColumn.name}`');
                    }
                }
            }
        }

        var fieldList = '*';
        if (fieldAliases.length > 0) {
            fieldList = fieldAliases.join(", ");
        }
        var sql = 'SELECT ${fieldList} FROM ${table.name}';
        sql += sqlJoin;

        var hasJoins = (relationships != null);
        if (hasJoins && (limit != null || offset != null)) {
            var tableDef = databaseSchema.findTable(table.name);
            if (tableDef != null) {
                var primaryKeyColumns = tableDef.findPrimaryKeyColumns();
                if (primaryKeyColumns != null && primaryKeyColumns.length > 0) {
                    if (limit != null || offset != null) {
                        var tableName = table.name;
                        var primaryKeyName = primaryKeyColumns[0].name;

                        sql += '\nINNER JOIN(\n';
                        sql += '    SELECT `$primaryKeyName` FROM `$tableName`\n';
                        if (query != null) {
                            sql += '        WHERE (${Query.queryExprToSql(query, values, table.name)})\n';
                        }
                        if (limit != null) {
                            sql += '        LIMIT $limit\n';
                        }
                        if (offset != null) {
                            sql += '        OFFSET $offset\n';
                        }

                        sql += ') __temp__ on `$tableName`.`$primaryKeyName` = __temp__.`$primaryKeyName`\n';
                    }
                }
            }
        } else {
            if (query != null) {
                sql += '\nWHERE (${Query.queryExprToSql(query, values, table.name)})';
            }
    
            if (limit != null) {
                sql += ' LIMIT ' + limit;
            }
            if (offset != null) {
                sql += ' OFFSET ' + offset;
            }
        }
        sql += ';';
        return sql;
    }

    public static function buildCount(table:ITable, query:QueryExpr = null, values:Array<Any> = null):String {
        var fieldList = 'COUNT(*)';
        var sql = 'SELECT ${fieldList} FROM ${table.name}';

        if (query != null) {
            sql += '\nWHERE (${Query.queryExprToSql(query, values, table.name)})';
        }
        sql += ';';
        return sql;
    }

    public static function buildDistinctSelect(table:ITable, query:QueryExpr = null, distinctColumn:String = null, limit:Null<Int> = null, offset:Null<Int> = null, values:Array<Any> = null, relationships:RelationshipDefinitions = null, databaseSchema:DatabaseSchema = null):String {
        var alwaysAliasResultFields:Bool = table.db.getProperty("alwaysAliasResultFields", false);
        var fieldAliases = [];

        var fieldList = '*';
        if (distinctColumn != null) {
            fieldAliases.push('distinct(${distinctColumn})');
        }
        if (fieldAliases.length > 0) {
            fieldList = fieldAliases.join(", ");
        }
        var sql = 'SELECT ${fieldList} FROM ${table.name}';

        if (query != null) {
            sql += '\nWHERE (${Query.queryExprToSql(query, values, table.name)})';
        }
        if (limit != null) {
            sql += ' LIMIT ' + limit;
        }
        if (offset != null) {
            sql += ' OFFSET ' + offset;
        }
        sql += ';';
        return sql;
    }

    private static function buildJoins(tableName:String, prefix:String, relationships:RelationshipDefinitions, databaseSchema:DatabaseSchema, fieldAliases:Array<String>) {
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
            var field1 = tableRelationship.field1;
            var table2 = tableRelationship.table2;
            var field2 = tableRelationship.field2;
            if (prefix == null) {
                prefix = table1;
            }
            var joinName = table1 + "." + table2;
            if (relationships.complexRelationships) {
                joinName = prefix + "." + field1 + "." + table2 + "." + field2;
            }

            var tableSchema = databaseSchema.findTable(table2);
            if (tableSchema == null) {
                continue;
            }

            for (tableColumn in tableSchema.columns) {
                fieldAliases.push('`${joinName}`.`${tableColumn.name}` AS `${joinName}.${tableColumn.name}`');
            }

            sql += '\n    LEFT JOIN `${table2}` AS `${joinName}` ON `${joinName}`.`${field2}` = `${prefix}`.`${field1}`';
            sql += buildJoins(table2, joinName, relationships, databaseSchema, fieldAliases);
        }
        
        return sql;
    }

    public static function buildDeleteRecord(table:ITable, record:Record, values:Array<Any> = null):String {
        var fieldNames = fieldNamesFromRecord(record);
        var sql = 'DELETE FROM ${table.name} WHERE ';
        var placeholders = [];
        for (f in record.fieldNames) {
            var v = record.field(f);
            f = quoteFieldName(f);
            if ((v is Bytes)) {
                continue;
            }
            placeholders.push('${f} = ?');
            if (values != null) {
                values.push(v);
            }
        }
        sql += '(${placeholders.join(" AND ")})';
        sql += ';';
        return sql;
    }

    public static function buildDeleteWhere(table:ITable, query:QueryExpr):String {
        var sql = 'DELETE FROM ${table.name}';
        if (query != null) {
            sql += ' WHERE (${Query.queryExprToSql(query, null, table.name)})';
        }
        sql += ';';
        return sql;
    }

    public static function buildUpdate(table:ITable, query:QueryExpr, record:Record, values:Array<Any> = null, typeMapper:IDataTypeMapper = null):String {
        var fieldNames = fieldNamesFromRecord(record);
        var sql = 'UPDATE ${table.name} SET ';
        var placeholders = [];
        for (f in record.fieldNames) {
            var v = record.field(f);
            f = quoteFieldName(f);
            if (v == null) {
                placeholders.push('${f} = NULL');
            } else {
                if (typeMapper != null && typeMapper.shouldConvertValueToDatabase(v)) {
                    v = typeMapper.convertValueToDatabase(v);
                }
                placeholders.push('${f} = ?');
                if (values != null) {
                    values.push(v);
                }
            }
        }
        sql += '${placeholders.join(", ")}';
        sql += ' WHERE (${Query.queryExprToSql(query, values, table.name)})';
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

    private static inline function quoteFieldName(f:String) {
        return '`${f}`';
    }
}
