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
        
        runner.addCase(new TestBasic(sqlite()));
        runner.addCase(new TestBasicRelationships(sqlite()));

        Report.create(runner, SuccessResultsDisplayMode.AlwaysShowSuccessResults, HeaderDisplayMode.NeverShowHeader);
        runner.run();
    }

    private static function addCases(runner:Runner, db:IDatabase) {
    }

    private static function sqlite():IDatabase {
        return DatabaseFactory.instance.createDatabase(DatabaseFactory.SQLITE, {
            filename: "persons.db"
        });
    }
}