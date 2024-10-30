package db;

@:forward
@:forward.new
@:forwardStatics
abstract RecordSet(RecordSetImpl) {
    @:arrayAccess
    private inline function get(index:Int) {
        return @:privateAccess this.records[index];
    }

    @:arrayAccess
    private inline function set(index:Int, value:Record):Record {
        @:privateAccess this.records[index] = value;
        return value;
    }

    @:from
    private static inline function fromArray(records:Array<Record>) {
        return new RecordSet(records);
    }

    @:to 
    private inline function toArray():Array<Record> {
        return @:privateAccess this.records;
    }
}

private class RecordSetImpl {
    private var records:Array<Record> = null;

    public function new(records:Array<Record> = null) {
        this.records = records;
    }

    public inline function reverse() {
      records.reverse();
      return records;
    }
    
    @:noCompletion
    public function iterator():RecordSetIterator {
        return new RecordSetIterator(records);
    }

    @:noCompletion
    public function keyValueIterator():RecordSetKeyValueIterator {
      return new RecordSetKeyValueIterator(records);
    }

    public var length(get, null):Int;
    private function get_length():Int {
        if (records == null) {
            return 0;
        }
        return records.length;
    }

    public function push(record:Record) {
        if (records == null) {
            records = [];
        }
        records.push(record);
    }

    public function filter(f:Record->Bool):RecordSet {
        if (records == null) {
            return [];
        }
        return records.filter(f);
    }

    public function findRecord(fieldName:String, fieldValue:Any):Record {
        if (records == null) {
            return null;
        }

        for (r in records) {
            if (r.field(fieldName) == fieldValue) {
                return r;
            }
        }

        return null;
    }

    public function extractFieldValues<T>(fieldName:String):Array<T> {
        if (records == null) {
            return [];
        }

        var values:Array<T> = [];
        for (r in records) {
            var v = r.field(fieldName);
            if (v != null) {
                values.push(v);
            }
        }

        return values;
    }

    public function renameField(fieldName:String, newFieldName:String) {
        if (records == null) {
            return;
        }

        for (r in records) {
            r.renameField(fieldName, newFieldName);
        }
    }

    public function copyField(fieldName:String, newFieldName:String) {
        if (records == null) {
            return;
        }

        for (r in records) {
            r.copyField(fieldName, newFieldName);
        }
    }

    public function copy():RecordSet {
        return new RecordSet(this.records.copy());
    }

    public function normalizeFieldNames() { // ensures that all fields have max of 2 "." - can be useful when working with joins
        for (r in records) @:privateAccess {
            for (fieldName in r.data.keys()) {
                if (fieldName.indexOf(".") != -1) {
                    var fieldNameParts = fieldName.split(".");
                    var newFieldName = null;
                    if (fieldNameParts.length > 2) {
                        while (fieldNameParts.length > 2) {
                            fieldNameParts.shift();
                        }
                        newFieldName = fieldNameParts.join(".");
                    }

                    if (newFieldName != null) {
                        r.field(newFieldName, r.field(fieldName));
                        r.removeField(fieldName);
                    }
                }
            }
        }
    }
}

private class RecordSetIterator {
    private var records:Array<Record> = null;
    private var pos:Int = 0;

    public function new(records:Array<Record> = null) {
        this.records = records;
        this.pos = 0;
    }

    public function hasNext():Bool {
        if (records == null) {
            return false;
        }
        return pos < records.length;
    }

    public function next():Record {
        var r = records[pos];
        pos++;
        return r;
    }
}

private class RecordSetKeyValueIterator {
    private var records:Array<Record> = null;
    private var pos:Int = 0;

    public function new(records:Array<Record> = null) {
        this.records = records;
        this.pos = 0;
    }

    public function hasNext():Bool {
        if (records == null) {
            return false;
        }
        return pos < records.length;
    }

    public function next():{key: Int, value:Record} {
        var r = {
          key: pos,
          value: records[pos]
        }
        pos++;
        return r;
    }
}
