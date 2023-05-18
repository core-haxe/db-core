package db;

class RelationshipDefinitions {
    public var complexRelationships:Bool = false;

    private var _defs:Map<String, Array<RelationshipDefinition>> = [];

    public function new() {
    }

    public var relationships:Map<String, String>;

    public function add(field1:String, field2:String) {
        var parts1 = field1.split(".");
        var parts2 = field2.split(".");
        var table1 = parts1.shift();
        var table2 = parts2.shift();
        var field1 = parts1.join(".");
        var field2 = parts2.join(".");

        var array = _defs.get(table1);
        if (array == null) {
            array = [];
            _defs.set(table1, array);
        }

        array.push({
            table1: table1,
            table2: table2,
            field1: field1,
            field2: field2
        });
    }

    public function get(table:String):Array<RelationshipDefinition> {
        return _defs.get(table);
    }

    public function all():Array<RelationshipDefinition> {
        var list = [];
        for (key in _defs.keys()) {
            list = list.concat(_defs.get(key));
        }
        return list;
    }

    public function keys():Iterator<String> {
        return _defs.keys();
    }
}