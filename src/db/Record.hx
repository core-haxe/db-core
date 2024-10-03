package db;

#if (!macro && (dbcore_as_externs || (modular && !modular_host)))

extern class Record {
    public function new();
    private var data:Map<String, Any>;
    public function field(name:String, value:Any = null):Any;
    public function renameField(fieldName:String, newFieldName:String):Void;
    public function copyField(fieldName:String, newFieldName:String):Void;
    public function removeField(name:String):Void;
}

#else

@:keep @:expose
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

    public var fieldCount(get, null):Int;
    private function get_fieldCount():Int {
        var n = 0;
        for (_ in data.keys()) {
            n++;
        }
        return n;
    }

    public function hasField(name:String):Bool {
        if (data == null) {
            return false;
        }
        return data.exists(name);
    }

    public function renameField(fieldName:String, newFieldName:String) {
        if (data.exists(fieldName)) {
            var v = data.get(fieldName);
            data.set(newFieldName, v);
            data.remove(fieldName);
        }
    }

    public function copyField(fieldName:String, newFieldName:String) {
        if (data.exists(fieldName)) {
            var v = data.get(fieldName);
            data.set(newFieldName, v);
        }
    }

    public function filterFields(callback:String->Any->Bool) {
        var newData:Map<String, Any> = [];
        for (fieldName in data.keys()) {
            var fieldValue = data.get(fieldName);
            if (callback(fieldName, fieldValue)) {
                newData.set(fieldName, fieldValue);
            }
        }
        data = newData;
    }

    public function findFields(callback:String->Bool):Array<String> {
        var list = [];
        for (fieldName in data.keys()) {
            if (callback(fieldName)) {
                list.push(fieldName);
            }
        }
        return list;
    }

    public function findFieldValues<T>(callback:String->T->Bool):Array<T> {
        var list:Array<T> = [];
        for (fieldName in data.keys()) {
            var fieldValue = data.get(fieldName);
            if (fieldValue == null) {
                continue;
            }
            if (callback(fieldName, fieldValue)) {
                list.push(fieldValue);
            }
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

    public function copy():Record {
        var c = new Record();
        c.data = this.data.copy();
        return c;
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

    public function merge(other:Record) {
        for (key in other.data.keys()) {
            var value = other.data.get(key);
            data.set(key, value);
        }
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

#end