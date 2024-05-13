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

    public function hasField(name:String):Bool {
        if (data == null) {
            return false;
        }
        return data.exists(name);
    }

    public function field(name:String, value:Any = null):Any { // if value is non null, this is effectively a setter
        if (value != null) {
            data.set(name, value);
            return value;
        }

        return data.get(name);
    }

    public function empty(name:String) {
        data.set(name, null);
    }

    public function values():Array<Any> {
        var v = [];
        for (k in data.keys()) {
            v.push(data.get(k));
        }
        return v;
    }

    public function stringValues():Array<String> {
        var v = [];
        for (k in data.keys()) {
            v.push(Std.string(data.get(k)));
        }
        return v;
    }

    public function removeField(name:String) {
        data.remove(name);
    }

    public function debugString():String {
        var sb = new StringBuf();
        for (f in data.keys()) {
            sb.add(f);
            sb.add("=");
            sb.add(data.get(f));
            sb.add("; ");
        }
        return sb.toString();
    }

    public function equals(other:Record) {
        var thisFieldNames = this.fieldNames;
        var otherFieldNames = other.fieldNames;
        if (thisFieldNames.length != otherFieldNames.length) {
            return false;
        }

        var thisData = this.data;
        var otherData = other.data;

        for (thisFieldName in thisFieldNames) {
            if (!otherData.exists(thisFieldName)) {
                return false;
            }
        }

        for (otherFieldName in otherFieldNames) {
            if (!thisData.exists(otherFieldName)) {
                return false;
            }
        }

        for (thisFieldName in thisFieldNames) {
            if (thisData.get(thisFieldName) != otherData.get(thisFieldName)) {
                return false;
            }
        }

        return true;
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