package db;

class DatabaseError {
    public var message:String;
    public var call:String;

    public function new(message:String, call:String = null) {
        this.message = message;
        this.call = call;
    }
}