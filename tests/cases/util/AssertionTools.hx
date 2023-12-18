package cases.util;

import db.ColumnOptions;
import db.ColumnDefinition;
import db.TableSchema;
import db.ColumnType;
import haxe.io.Bytes;
import utest.Assert;
import db.Record;

class AssertionTools {
    public static function assertRecordExists(data:Map<String, Any>, records:Array<Record>) {
        var found = false;
        for (record in records) {
            var isMatch = true;
            for (expectedFieldName in data.keys()) {
                var expectedFieldValue = data.get(expectedFieldName);
                var actualFieldValue = record.field(expectedFieldName);
                if ((expectedFieldValue is Bytes) || (actualFieldValue is Bytes)) {
                    if (expectedFieldValue == null && actualFieldValue != null) {
                        isMatch = false;
                    } else if (expectedFieldValue != null && actualFieldValue == null) {
                        isMatch = false;
                    } else {
                        var expectedBytes:Bytes = expectedFieldValue;
                        var actualBytes:Bytes = actualFieldValue;
                        if (expectedBytes.toString() != actualBytes.toString()) {
                            isMatch = false;
                        }
                    }
                } else if (actualFieldValue != expectedFieldValue) {
                    isMatch = false;
                }
                if (!isMatch) {
                    break;
                }
            }
            if (isMatch) {
                found = true;
                break;
            }
        }
        Assert.equals(true, found);
    }

    public static function assertTableSchema(tableSchema:TableSchema, tableName:String, columns:Array<ColumnDefinition>) {
        Assert.notNull(tableSchema.name);
        Assert.equals(tableName.toLowerCase(), tableSchema.name.toLowerCase());
        Assert.equals(columns.length, tableSchema.columns.length);
        for (i in 0...columns.length) {
            var expected = columns[i];
            var actual = tableSchema.columns[i];
            Assert.equals(expected.name, actual.name);
            assertColumnType(expected.type, actual.type);
            assertColumnOptions(expected.options, actual.options);
        }
    }

    public static function assertColumnType(expected:ColumnType, actual:ColumnType) {
        switch (expected) {
            case Text(n1):
                switch (actual) {
                    case Text(n2):
                        Assert.equals(n1, n2);
                    case _:
                        Assert.fail("expected Text");
                }
            case _:
                Assert.equals(expected, actual);
        }
    }

    public static function assertColumnOptions(expected:Array<ColumnOptions>, actual:Array<ColumnOptions>) {
        Assert.equals(expected.length, actual.length);
        for (i in 0...expected.length) {
            Assert.equals(expected[i], actual[i]);
        }
    }
}