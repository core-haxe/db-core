package db.macros;

import haxe.macro.Context;
import haxe.macro.Expr;

using StringTools;

class DatabaseTypes {
    private static var typeClasses:Map<String, String> = [];

    macro static function register(id:String, c:String) {
        Sys.println('db-core     > registering database type ${c} (${id})');
        var parts = c.split(".");
        var name = parts.pop();
        #if (haxe >= version("4.3.0"))
        Context.onAfterInitMacros(() -> {
            Context.resolveType(TPath({pack: parts, name: name}), Context.currentPos());
        });
        #else
        Context.resolveType(TPath({pack: parts, name: name}), Context.currentPos());
        #end
        if (!typeClasses.exists(id)) {
            typeClasses.set(id, c);
        }

        return null;
    }

    macro static function build():Array<Field> {
        var fields = Context.getBuildFields();

        var typeIds:Array<String> = [];
        var typeExprs:Array<Expr> = [];
        for (typeId in typeClasses.keys()) {
            typeIds.push(typeId);
            var c = typeClasses.get(typeId);
            var parts = c.split(".");
            var name = parts.pop();
            var t:TypePath = {
                pack: parts,
                name: name
            }
            typeExprs.push(macro {
                var p:db.macros.IDatabaseType = new $t();
                var typeInfo = p.typeInfo();
                _databaseTypes.set($v{typeId}, typeInfo.ctor);
                //Sys.println(" - registering database type " + typeInfo.id);
            });
        }

        for (f in fields) {
            if (f.name == "loadTypes") {
                switch (f.kind) {
                    case FFun(f):
                        switch(f.expr.expr) {
                            case EBlock(exprs): 
                                for (e in typeExprs) {
                                    exprs.push(e);
                                }
                            case _:
                        }
                    case _:    
                }
                break;
            }
        }

        for (typeId in typeIds) {
            fields.push({
                name: typeId.toUpperCase().replace("-", "_"),
                kind: FVar(
                    macro: String,
                    macro $v{typeId}
                ),
                access: [AStatic, APublic, AInline],
                pos: Context.currentPos()
            });
        }

        return fields;
    }
}
