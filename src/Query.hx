package;

import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.ExprTools;

using StringTools;

enum QBinop {
    QOpEq;
    QOpAssign;
    QOpBoolAnd;
    QOpBoolOr;
    QOpNotEq;
    QOpGt;
    QOpLt;
    QOpGte;
    QOpLte;
    QOpIn;
    QOpSimilar;
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
    QueryCall(name:String, params:Array<QueryExpr>);
    QueryArrayDecl(values:Array<QueryExpr>);
    QueryUnsupported(v:String);
}

class Query {
    public static macro function query(expr:Expr) {
        var qe = exprToQueryExpr(expr);
        return generate(qe);
    }

    public static macro function field(name:String) {
        return macro "^" + $v{name};
    }

    public static function joinQueryParts(parts:Array<QueryExpr>, op:QBinop) {
        var query:QueryExpr = null;
        if (parts.length > 1) {
            var last = parts.pop();
            var beforeLast = parts.pop();
            var qp = QueryBinop(op, beforeLast, last);
            while (parts.length > 0) {
                var q = parts.pop();
                qp = QueryBinop(op, q, qp);
            }
            query = qp;
        } else {
            query = parts[0];
        }
        return query;
    }

    #if macro

    private static function generate(qe:QueryExpr):haxe.macro.Expr {
        var pos = Context.currentPos();
        return switch (qe) {
            case QueryValue(e): macro @:pos(pos) Query.QueryExpr.QueryValue($e);
            case QueryBinop(op, e1, e2): macro @:pos(pos) Query.QueryExpr.QueryBinop($i{haxe.EnumTools.EnumValueTools.getName(op)}, $e{generate(e1)}, $e{generate(e2)});
            case QueryParenthesis(e): macro @:pos(pos) Query.QueryExpr.QueryParenthesis($e{generate(e)});
            case QueryConstant(c): macro @:pos(pos) Query.QueryExpr.QueryConstant($i{haxe.EnumTools.EnumValueTools.getName(c)}($a{
                haxe.EnumTools.EnumValueTools.getParameters(c).map(p -> macro @:pos(pos) $v{p})
            }));
            case QueryCall(name, params): macro @:pos(pos) Query.QueryExpr.QueryCall($v{name}, $v{params});
            case QueryArrayDecl(values): macro @:pos(pos) Query.QueryExpr.QueryArrayDecl($v{values});
            case QueryUnsupported(v): macro @:pos(pos) Query.QueryExpr.QueryUnsupported($v{v});
        }
    }

    private static function exprToQueryExpr(e:Expr):QueryExpr {
        return switch (e.expr) {
            case EBinop(op, e1, e2):
                var qbinop = switch (op) {
                    case OpEq:          QBinop.QOpEq;
                    case OpAssign:      QBinop.QOpAssign;
                    case OpBoolAnd:     QBinop.QOpBoolAnd;
                    case OpBoolOr:      QBinop.QOpBoolOr;
                    case OpNotEq:       QBinop.QOpNotEq;
                    case OpGt:          QBinop.QOpGt;
                    case OpLt:          QBinop.QOpLt;
                    case OpGte:         QBinop.QOpGte;
                    case OpLte:         QBinop.QOpLte;
                    case OpIn:          QBinop.QOpIn;
                    case _:  
                        trace("unsupported", op, op.getName());
                        QBinop.QOpUnsupported(op.getName());
                }
                QueryBinop(qbinop, exprToQueryExpr(e1), exprToQueryExpr(e2));
            case EUnop(OpNegBits, postFix, e):    
                QueryBinop(QBinop.QOpSimilar, exprToQueryExpr(e),  exprToQueryExpr(e));
            case EParenthesis(e):
                QueryParenthesis(exprToQueryExpr(e));
            case EConst(CIdent(s)):
                if (s.startsWith("$")) {
                    var varName = s.substr(1);
                    if (varName == "distinct") {
                        QueryCall(varName, null);
                    } else {
                        QueryConstant(QIdent(varName));
                    }
                } else {
                    QueryValue(macro @:pos(e.pos) $i{s});
                }
            case EConst(CInt(s)):
                QueryConstant(QInt(s));
            case EConst(CString(s, _)):    
                QueryConstant(QString(s));
            case EField(e, field):
                var s = ExprTools.toString(e);
                if (s.startsWith("$")) {
                    var varName = s.substr(1) + "." + field;
                    QueryConstant(QIdent(varName));
                } else {
                    switch (exprToQueryExpr(e)) {
                        case QueryValue(e):  QueryValue(macro @:pos(e.pos) $e.$field);
                        case qe:             qe;
                    }
                }
            case EArray(e1, e2):
                switch (exprToQueryExpr(e1)) {
                    case QueryValue(e):  QueryValue(macro @:pos(e.pos) $e[$e2]);
                    case qe:             qe;
                }
            //case EArrayDecl(values):    

            case ECall(e, params):
                switch (exprToQueryExpr(e)) {
                    case QueryValue(e):  QueryValue(macro @:pos(e.pos) $e($a{params}));
                    case QueryCall(name, _):
                        var a = [];
                        for (p in params) {
                            a.push(exprToQueryExpr(p));
                        }
                        QueryCall(name, a);
                    case qe:             qe;
                }

            case EArrayDecl(values):    
                var exprs = [];
                for (v in values) {
                    exprs.push(exprToQueryExpr(v));
                }
                QueryArrayDecl(exprs);
            case _:
                trace("unsupported:", e.expr);
                return QueryUnsupported(e.expr.getName());
        }
    }
    #end

    public static function queryExprToSql(qe:QueryExpr, values:Array<Any> = null, fieldPrefix:String = null):String {
        if (qe == null) {
            return null;
        }
        var sb = new StringBuf();
        queryExprPartToSql(qe, sb, values, fieldPrefix, false);
        var s = sb.toString();

        // because of the [mis]use of the haxe OpNegBits in the AST, we have to post fix the SQL string to normalise it
        // not ideal, but "fine" and i dont think there is another way around it
        var likeReplacerRegex = ~/=\s\sLIKE\s('.*?'|\?)/gm;
        var n = 0;
        s = likeReplacerRegex.map(s, (f -> {
            var term = f.matched(1).trim();
            if (values != null && values[n] != null && (values[n] is String)) {
                values[n] = Std.string(values[n]).replace("*", "%");
            }
            n++;
            if (term == "?") {
                return "LIKE ?";
            }
            term = term.replace("*", "%");
            if (!term.startsWith("'")) {
                term = "'" + term;
            }
            if (!term.endsWith("'")) {
                term = term + "'";
            }
            return "LIKE " + term + "";
        }));
        s = s.replace("` = NULL", "` IS NULL");
        s = s.replace("` <> NULL", "` IS NOT NULL");

        return s;
    }

    private static function queryExprPartToSql(qe:QueryExpr, sb:StringBuf, values:Array<Any>, fieldPrefix:String, isColumn:Bool) {
        switch (qe) {
            case QueryBinop(op, e1, e2):
                var isColumn2 = (op.getName() == "QOpEq") || (op.getName() == "QOpAssign") || (op.getName() == "QOpNotEq") || (op.getName() == "QOpGt") || (op.getName() == "QOpLt") || (op.getName() == "QOpGte") || (op.getName() == "QOpLte") || (op.getName() == "QOpIn");
                if (op.getName() != "QOpSimilar") {
                    queryExprPartToSql(e1, sb, values, fieldPrefix, isColumn2);
                }
                switch (op) {
                    case QOpEq:                 sb.add(" = ");
                    case QOpAssign:             sb.add(" = ");
                    case QOpBoolAnd:            sb.add(" AND ");
                    case QOpBoolOr:             sb.add(" OR ");
                    case QOpNotEq:              sb.add(" <> ");
                    case QOpGt:                 sb.add(" > ");
                    case QOpLt:                 sb.add(" < ");
                    case QOpGte:                sb.add(" >= ");
                    case QOpLte:                sb.add(" <= ");
                    case QOpIn:                 sb.add(" IN ");
                    case QOpSimilar:            sb.add(" LIKE ");
                    case QOpUnsupported(v):    
                        trace("WARNING: unsupported binary operation encountered:", v);
                    case _:    
                }
                queryExprPartToSql(e2, sb, values, fieldPrefix, isColumn);
            case QueryParenthesis(e):
                sb.add("(");
                queryExprPartToSql(e, sb, values, fieldPrefix, false);
                sb.add(")");
            case QueryConstant(QIdent(s)): 
                sb.add(buildColumn(s, fieldPrefix));
            case QueryConstant(QInt(s)):    
                if (values == null) {
                    sb.add(s);
                } else {
                    values.push(s);
                    sb.add("?");
                }
            case QueryConstant(QString(s)):
                if (values == null) {
                    sb.add("'" + s + "'");
                } else {
                    values.push(s);
                    sb.add("?");
                }
            case QueryValue(v):
                if ((v is Array)) {
                    sb.add("(");
                    var array:Array<Any> = cast v;
                    var newArray:Array<String> = [];
                    for (a in array) {
                        if (a is String) {
                            newArray.push('\'${Std.string(a)}\'');
                        } else {
                            newArray.push(Std.string(a));
                        }
                    }
                    sb.add(newArray.join(", "));
                    sb.add(")");
                } else if (values == null) {
                    if (Std.string(v).startsWith("^")) { // lets add a special case for %field, this is so we can construct query in macros (where $ means something different)
                        sb.add(buildColumn(Std.string(v).substring(1), fieldPrefix));
                    } else {
                        if (v is String) {
                            sb.add("'" + v + "'");
                        } else {
                            sb.add(v);
                        }
                    }
                } else {
                    if (Std.string(v).startsWith("^")) { // lets add a special case for %field, this is so we can construct query in macros (where $ means something different)
                        sb.add(buildColumn(Std.string(v).substring(1), fieldPrefix));
                    } else {
                        if (isColumn) {
                            sb.add(buildColumn(Std.string(v), fieldPrefix));
                        } else {
                            if ((v is Date)) {
                                var date:Date = cast v;
                                var dateString = date.toString().replace(" ", "T") + "Z";
                                values.push(dateString);
                                sb.add("?");
                            } else if (v == null) {
                                sb.add("NULL");
                            } else {
                                values.push(v);
                                sb.add("?");
                            }
                        }
                    }
                }
            case QueryCall(name, params):
                sb.add(name);
                sb.add("(");
                var paramStrings = [];
                for (p in params) {
                    var temp = new StringBuf();
                    queryExprPartToSql(p, temp, values, fieldPrefix, false);
                    paramStrings.push(temp.toString());
                }
                sb.add(paramStrings.join(", "));
                sb.add(")");
            case QueryArrayDecl(arrayValues):    
                sb.add("(");
                var paramStrings = [];
                for (av in arrayValues) {
                    var temp = new StringBuf();
                    queryExprPartToSql(av, temp, values, fieldPrefix, false);
                    paramStrings.push(temp.toString());
                }
                sb.add(paramStrings.join(", "));
                sb.add(")");
            case QueryUnsupported(v):
                trace("WARNING: unsupported query expression encountered:", v);
            case _:    
        }
    }

    private static function buildColumn(s:String, fieldPrefix:String):String {
        var full = s;
        if (fieldPrefix != null) {
            full = fieldPrefix + "." + s;
        }
        var sb:StringBuf = new StringBuf();
        if (full.contains(".")) {
            var parts = full.split(".");
            var field = parts.pop();
            sb.add("`");
            sb.add(parts.join("."));
            sb.add("`.`");
            sb.add(field);
            sb.add("`");
        } else {
            sb.add(full);
        }
        return sb.toString();
    }
}
