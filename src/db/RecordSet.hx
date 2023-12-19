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

    @:noCompletion
    public function iterator():RecordSetIterator {
        return new RecordSetIterator(records);
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

    public function copy():RecordSet {
        return new RecordSet(this.records);
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