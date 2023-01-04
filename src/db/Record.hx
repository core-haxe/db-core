package db;

class Record {
    private var data:Map<String, Any> = [];

    public function new() {
    }

    public var fieldNames(get, null):Array<String>;
    private function get_fieldNames():Array<String> {
        var list = [];
        for (f in data.keys()) {
            list.push(f);
        }
        return list;
    }

    public function field(name:String, value:Any = null):Any { // if value is non null, this is effectively a setter
        if (value != null) {
            data.set(name, value);
            return value;
        }

        return data.get(name);
    }

    public static function fromDynamic(data:Dynamic):Record {
        var r = new Record();
        for (f in Reflect.fields(data)) {
            var v = Reflect.field(data, f);
            r.data.set(f, v);
        }
        return r;
    }
}