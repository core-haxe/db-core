package db;

using StringTools;

class DebugUtils {
    public static function printRecords(records:Array<Record>, name:String = null) {
        var colSizes:Map<String, Int> = [];
        if (records.length == 0) {
            if (name != null) {
                Sys.println(name + ": no records!");
            }
        }
        // first get max sizes
        var r = records[0];
        for (fieldName in r.fieldNames) {
            colSizes.set(fieldName, fieldName.length);
        }
        for (r in records) {
            for (fieldName in r.fieldNames) {
                var value = Std.string(r.field(fieldName));
                var existingSize = colSizes.get(fieldName);
                var newSize = value.length;
                if (newSize > existingSize) {
                    colSizes.set(fieldName, newSize);
                }
            }
        }

        // now lets actually print
        Sys.println("");
        if (name != null) {
            Sys.println(name + " (" + records.length + "):");
        }
        var r = records[0];
        for (fieldName in r.fieldNames) {
            var size = colSizes.get(fieldName);
            Sys.print("| ");
            Sys.print(fieldName.rpad(" ", size));
            Sys.print(" ");
        }
        Sys.println("|");

        for (fieldName in r.fieldNames) {
            var size = colSizes.get(fieldName);
            Sys.print("|-");
            Sys.print("".rpad("-", size));
            Sys.print("-");
        }
        Sys.println("|");

        for (r in records) {
            for (fieldName in r.fieldNames) {
                var size = colSizes.get(fieldName);
                var value = Std.string(r.field(fieldName)).trim();
                Sys.print("| ");
                Sys.print(value.rpad(" ", size));
                Sys.print(" ");
             }
             Sys.println("|");
        }
        Sys.println("");

    }
}