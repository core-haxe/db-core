package db;

@:structInit
class ColumnDefinition {
    public var name:String;
    public var type:ColumnType;
    @:optional public var options:Null<Array<ColumnOptions>>;

    public function clone():ColumnDefinition {
        var c:ColumnDefinition = {
            name: this.name,
            type: this.type
        }
        if (this.options != null) {
            c.options = this.options.copy();
        }
        return c;
    }

    public function debugString() {
        var sb = new StringBuf();
        sb.add(name);
        sb.add(": ");
        sb.add(type);
        sb.add(", ");
        sb.add(options);
        return sb.toString();
    }
}