package db;

import haxe.macro.ExprTools;
import haxe.macro.Expr;
import haxe.macro.Context;

using StringTools;

enum QBinop {
    QOpAssign;
    QOpBoolAnd;
    QOpBoolOr;
    QOpNotEq;
    QOpUnsupported(v:String);
   
}

enum QConstant {
	QInt(v:String);
	QFloat(f:String);
	QString(s:String);
	QIdent(s:String);
}

enum QueryExpr {
    QueryBinop(op:QBinop, e1:QueryExpr, e2:QueryExpr);
    QueryConstant(c:QConstant);
    QueryParenthesis(e:QueryExpr);
    #if macro
    QueryValue(e:Expr);
    #else
    QueryValue(v:Any);
    #end
    QueryUnsupported(v:String);
}

class Query {
    public static macro function query(expr:Expr) {
        var qe = exprToQueryExpr(expr);
        return generate(qe);
    }

    #if macro

    private static function generate(qe:QueryExpr):haxe.macro.Expr {
        return switch (qe) {
          case QueryValue(e): macro QueryValue($e);
          case QueryBinop(op, e1, e2): macro QueryBinop($v{op}, $e{generate(e1)}, $e{generate(e2)});
          case QueryParenthesis(e): macro QueryParenthesis($e{generate(e)});
          case _: macro $v{qe}; // Should work fine for everything that is only made up of literals
        }
    }

    private static function exprToQueryExpr(e:Expr):QueryExpr {
        return switch (e.expr) {
            case EBinop(op, e1, e2):
                var qbinop = switch (op) {
                    case OpAssign:      QBinop.QOpAssign;
                    case OpBoolAnd:     QBinop.QOpBoolAnd;
                    case OpBoolOr:      QBinop.QOpBoolOr;
                    case OpNotEq:       QBinop.QOpNotEq;
                    case _:  
                        trace("unsupported", op, op.getName());
                        QBinop.QOpUnsupported(op.getName());
                }
                QueryBinop(qbinop, exprToQueryExpr(e1), exprToQueryExpr(e2));
            case EParenthesis(e):
                QueryParenthesis(exprToQueryExpr(e));
            case EConst(CIdent(s)):
                if (s.startsWith("$")) {
                    var varName = s.substr(1);
                    QueryConstant(QIdent(varName));
                } else {
                    QueryValue(macro @:pos(e.pos) $i{s});
                }
            case EConst(CInt(s)):
                QueryConstant(QInt(s));
            case EConst(CString(s, _)):    
                QueryConstant(QString(s));
            case EField(e, field):
                switch (exprToQueryExpr(e)) {
                    case QueryValue(e):  QueryValue(macro @:pos(e.pos) $e.$field);
                    case qe:             qe;
                }
            case EArray(e1, e2):
                switch (exprToQueryExpr(e1)) {
                    case QueryValue(e):  QueryValue(macro @:pos(e.pos) $e[$e2]);
                    case qe:             qe;
                }
            case ECall(e, params):
                switch (exprToQueryExpr(e)) {
                    case QueryValue(e):  QueryValue(macro @:pos(e.pos) $e($a{params}));
                    case qe:             qe;
                }
            case _:
                trace("unsupported:", e.expr);
                return QueryUnsupported(e.expr.getName());
        }
    }
    #end

    public static function queryExprToSql(qe:QueryExpr, values:Array<Any> = null):String {
        var sb = new StringBuf();
        queryExprPartToSql(qe, sb, values);
        return sb.toString();
    }

    private static function queryExprPartToSql(qe:QueryExpr, sb:StringBuf, values:Array<Any>) {
        switch (qe) {
            case QueryBinop(op, e1, e2):
                queryExprPartToSql(e1, sb, values);
                switch (op) {
                    case QOpAssign:             sb.add(" = ");
                    case QOpBoolAnd:            sb.add(" AND ");
                    case QOpBoolOr:             sb.add(" OR ");
                    case QOpNotEq:              sb.add(" <> ");
                    case QOpUnsupported(v):    
                        trace("WARNING: unsupported binary operation encountered:", v);
                    case _:    
                }
                queryExprPartToSql(e2, sb, values);
            case QueryParenthesis(e):
                sb.add("(");
                queryExprPartToSql(e, sb, values);
                sb.add(")");
            case QueryConstant(QIdent(s)): 
                sb.add(s);
            case QueryConstant(QInt(s)):    
                if (values == null) {
                    sb.add(s);
                } else {
                    values.push(s);
                    sb.add("?");
                }
            case QueryConstant(QString(s)):
                if (values == null) {
                    sb.add("\"" + s + "\"");
                } else {
                    values.push(s);
                    sb.add("?");
                }
            case QueryValue(v):
                if (values == null) {
                    sb.add(v);
                } else {
                    values.push(v);
                    sb.add("?");
                }
            case QueryUnsupported(v):
                trace("WARNING: unsupported query expression encountered:", v);
            case _:    
        }
    }
}