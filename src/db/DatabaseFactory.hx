package db;

import haxe.Exception;

@:build(db.macros.DatabaseTypes.build())
class DatabaseFactory {
    private static var _instance:DatabaseFactory = null;
    public static var instance(get, null):DatabaseFactory;
    private static function get_instance():DatabaseFactory {
        if (_instance == null) {
            _instance = new DatabaseFactory();
        }
        return _instance;
    }

    ///////////////////////////////////////////////////////////////////////////////
    private var _databaseTypes:Map<String, Void->IDatabase> = [];

    private function new() {
        init();
    }

    private function init() {
        loadTypes();
    }

    private function loadTypes() { // macro will fill this up

    }

    public function createDatabase<T>(typeId:String, config:Dynamic = null):IDatabase {
        if (!_databaseTypes.exists(typeId)) {
            throw new Exception('database type "${typeId}" not registered');
        }
        var ctor = _databaseTypes.get(typeId);
        var instance = ctor();
        if (config != null) {
            instance.config(config);
        }
        return instance;
    }
}