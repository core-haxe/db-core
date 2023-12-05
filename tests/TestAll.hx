package;

import db.DatabaseFactory;
import db.IDatabase;
import utest.ui.common.HeaderDisplayMode;
import utest.ui.Report;
import utest.Runner;
import cases.*;

class TestAll {
    public static function main() {
        var runner = new Runner();

        addCases(runner, sqlite());
//        addCases(runner, mysql());

        Report.create(runner, SuccessResultsDisplayMode.AlwaysShowSuccessResults, HeaderDisplayMode.NeverShowHeader);
        runner.run();
    }

    private static function addCases(runner:Runner, db:IDatabase) {
        runner.addCase(new TestBasic(db));
        runner.addCase(new TestQuery(db));
        runner.addCase(new TestSchema(db));
        runner.addCase(new TestAdd(db));
        runner.addCase(new TestDelete(db));
        runner.addCase(new TestDeleteAll(db));
        runner.addCase(new TestUpdate(db));
        runner.addCase(new TestPaging(db));
        runner.addCase(new TestCount(db));
        runner.addCase(new TestFindUnique(db));
        runner.addCase(new TestAddColumn(db));
        runner.addCase(new TestRemoveColumn(db));

        #if !neko
        runner.addCase(new TestBinary(db));
        runner.addCase(new TestExport(db));
        #end

        #if nodejs // for another day
        runner.addCase(new TestBasicRelationships(db));
        #end
    }

    private static function sqlite():IDatabase {
        return DatabaseFactory.instance.createDatabase(DatabaseFactory.SQLITE, {
            filename: "persons.db"
        });
    }

    private static function mysql():IDatabase {
        return DatabaseFactory.instance.createDatabase(DatabaseFactory.MYSQL, {
            database: "Persons",
            host: Sys.getEnv("MYSQL_HOST"),
            user: Sys.getEnv("MYSQL_USER"),
            pass: Sys.getEnv("MYSQL_PASS")
        });
    }
}