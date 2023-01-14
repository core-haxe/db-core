package db.utils;

import db.Query.QueryExpr;

using StringTools;

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

    public static function buildSelect(table:ITable, query:QueryExpr = null, limit:Null<Int> = null, values:Array<Any> = null, relationships:RelationshipDefinitions = null, relationshipExclusions:Array<String> = null):String {
        var sql = 'SELECT * FROM ${table.name}';
        sql += addJoins(table.name, relationships, false, null, relationshipExclusions);

        if (query != null) {
            sql += '\nWHERE (${Query.queryExprToSql(query, values)})';
        }
        if (limit != null) {
            sql += ' LIMIT ' + limit;
        }
        sql += ';';
        return sql;
    }

    private static function addJoins(tableName:String, relationships:RelationshipDefinitions, invert:Bool = false, counters:Map<String, Int> = null, exclusions:Array<String> = null) {
        if (relationships == null) {
            return "";
        }

        if (exclusions == null) {
            exclusions = [];
        }

        if (exclusions.contains(tableName)) {
            return "";
        }

        var sql = "";
        if (relationships != null) {
            var localExclusions = exclusions.copy();
            exclusions.push(tableName);

            var tableRelationships = relationships.get(tableName);
            if (tableRelationships != null) {
                if (counters == null) {
                    counters = [];
                }
                var additionalTables = [];
                for (tableRelationship in tableRelationships) {
                    var table1 = tableRelationship.table1;
                    var table2 = tableRelationship.table2;
                    var field1 = tableRelationship.field1;
                    var field2 = tableRelationship.field2;

                    var sourceTable = table2;
                    if (invert) {
                        sourceTable = table1;
                        invert = false;
                    }

                    if (localExclusions.contains(sourceTable)) {
                        continue;
                    }

                    var table1Alias = table1;
                    var table2Alias = table2;

                    var as = "";
                    var sourceTableAlias = sourceTable;
                    if (counters.exists(sourceTable)) {
                        table2Alias += counters.get(sourceTable);
                        as = ' AS ${table2Alias}';
                    }
                    sql += '\n    INNER JOIN ${sourceTable}${as} ON ${table2Alias}.${field2} = ${table1Alias}.${field1}';
                    if (!counters.exists(sourceTable)) {
                        counters.set(sourceTable, 1);
                    } else {
                        counters.set(sourceTable, counters.get(sourceTable) + 1);
                    }

                    for (additionalTableName in relationships.keys()) {
                        if (additionalTableName == tableName) {
                            continue;
                        }

                        for (tableRelationship2 in relationships.get(additionalTableName)) {
                            if (tableRelationship2.table2 == sourceTable
                                && relationships.get(additionalTableName) != null
                                && !exclusions.contains(additionalTableName)) {
                                if (!additionalTables.contains(additionalTableName)) {
                                    additionalTables.push(additionalTableName);
                                }
                            }
                        }
                    }
                }

                if (additionalTables.length > 0) {
                    for (a in additionalTables) {
                        sql += addJoins(a, relationships, true, counters, exclusions);
                    }
                }
    
            }
        }

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