package db;

enum ColumnType {
    Number;
    Decimal;
    Boolean;
    Text(n:Int);
    Memo;
}