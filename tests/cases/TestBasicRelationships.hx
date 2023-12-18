package cases;

import Query.*;
import db.IDatabase;
import utest.Assert;
import cases.util.DBCreator;
import utest.Async;
import utest.ITest;
import cases.util.AssertionTools.*;

class TestBasicRelationships implements ITest {
    private var db:IDatabase;

    public function new(db:IDatabase) {
        this.db = db;
    }

    function setupClass(async:Async) {
        logging.LogManager.instance.addAdaptor(new logging.adaptors.ConsoleLogAdaptor({
            levels: [logging.LogLevel.Info, logging.LogLevel.Error]
        }));
        DBCreator.create(db, true).then(_ -> {
            async.done();
        });
    }

    function teardownClass(async:Async) {
        logging.LogManager.instance.clearAdaptors();
        db.disconnect().then(_ -> {
            DBCreator.cleanUp();
            async.done();
        }, error -> {
            trace(error);
        });
    }

    function testBasicFindOne(async:Async) {
        db.table("Person").then(result -> {
            return result.table.findOne(query($personId = 1));
        }).then(result -> {
            Assert.equals(1, result.data.field("Person.personId"));
            Assert.equals("Ian", result.data.field("Person.firstName"));
            Assert.equals("Harrigan", result.data.field("Person.lastName"));
            Assert.equals(1, result.data.field("Person.iconId"));
            Assert.equals("/somepath/icon1.png", result.data.field("Person.Icon.path"));
            Assert.equals("ACME Inc", result.data.field("Person_Organization.Organization.name"));
            async.done();
        }, error -> {
            trace("error", error);
        });
    }

    function testBasicAll(async:Async) {
        db.table("Person").then(result -> {
            return result.table.all();
        }).then(result -> {
            Assert.equals(7, result.data.length);

            assertRecordExists([
                "Person.personId" => 1,
                "Person.firstName" => "Ian",
                "Person.lastName" => "Harrigan",
                "Person.iconId" => 1,
                "Person.Icon.path" => "/somepath/icon1.png",
                "Person_Organization.Organization.name" => "ACME Inc",
            ], result.data);

            assertRecordExists([
                "Person.personId" => 1,
                "Person.firstName" => "Ian",
                "Person.lastName" => "Harrigan",
                "Person.iconId" => 1,
                "Person.Icon.path" => "/somepath/icon1.png",
                "Person_Organization.Organization.name" => "PASX Ltd",
            ], result.data);

            assertRecordExists([
                "Person.personId" => 2,
                "Person.firstName" => "Bob",
                "Person.lastName" => "Barker",
                "Person.iconId" => 3,
                "Person.Icon.path" => "/somepath/icon3.png",
                "Person_Organization.Organization.name" => "ACME Inc",
            ], result.data);

            assertRecordExists([
                "Person.personId" => 2,
                "Person.firstName" => "Bob",
                "Person.lastName" => "Barker",
                "Person.iconId" => 3,
                "Person.Icon.path" => "/somepath/icon3.png",
                "Person_Organization.Organization.name" => "Haxe LLC",
            ], result.data);

            assertRecordExists([
                "Person.personId" => 3,
                "Person.firstName" => "Tim",
                "Person.lastName" => "Mallot",
                "Person.iconId" => 2,
                "Person.Icon.path" => "/somepath/icon2.png",
                "Person_Organization.Organization.name" => "ACME Inc",
            ], result.data);

            assertRecordExists([
                "Person.personId" => 4,
                "Person.firstName" => "Jim",
                "Person.lastName" => "Parker",
                "Person.iconId" => 1,
                "Person.Icon.path" => "/somepath/icon1.png",
                "Person_Organization.Organization.name" => "Haxe LLC",
            ], result.data);

            assertRecordExists([
                "Person.personId" => 4,
                "Person.firstName" => "Jim",
                "Person.lastName" => "Parker",
                "Person.iconId" => 1,
                "Person.Icon.path" => "/somepath/icon1.png",
                "Person_Organization.Organization.name" => "PASX Ltd",
            ], result.data);

            async.done();
        }, error -> {
            trace("error", error);
        });
    }

    function testBasicFind(async:Async) {
        db.table("Person").then(result -> {
            return result.table.find(query($personId = 1));
        }).then(result -> {
            Assert.equals(2, result.data.length);

            assertRecordExists([
                "Person.personId" => 1,
                "Person.firstName" => "Ian",
                "Person.lastName" => "Harrigan",
                "Person.iconId" => 1,
                "Person.Icon.path" => "/somepath/icon1.png",
                "Person_Organization.Organization.name" => "ACME Inc",
            ], result.data);

            assertRecordExists([
                "Person.personId" => 1,
                "Person.firstName" => "Ian",
                "Person.lastName" => "Harrigan",
                "Person.iconId" => 1,
                "Person.Icon.path" => "/somepath/icon1.png",
                "Person_Organization.Organization.name" => "PASX Ltd",
            ], result.data);

            async.done();
        }, error -> {
            trace("error", error);
        });
    }

    function testBasicFind_Var(async:Async) {
        var personId = 1;
        db.table("Person").then(result -> {
            return result.table.find(query($personId = personId));
        }).then(result -> {
            Assert.equals(2, result.data.length);

            assertRecordExists([
                "Person.personId" => 1,
                "Person.firstName" => "Ian",
                "Person.lastName" => "Harrigan",
                "Person.iconId" => 1,
                "Person.Icon.path" => "/somepath/icon1.png",
                "Person_Organization.Organization.name" => "ACME Inc",
            ], result.data);

            assertRecordExists([
                "Person.personId" => 1,
                "Person.firstName" => "Ian",
                "Person.lastName" => "Harrigan",
                "Person.iconId" => 1,
                "Person.Icon.path" => "/somepath/icon1.png",
                "Person_Organization.Organization.name" => "PASX Ltd",
            ], result.data);

            async.done();
        }, error -> {
            trace("error", error);
        });
    }

    function testBasicFind_VarString(async:Async) {
        var firstName = "Ian";
        db.table("Person").then(result -> {
            return result.table.find(query($firstName = firstName));
        }).then(result -> {
            Assert.equals(2, result.data.length);

            assertRecordExists([
                "Person.personId" => 1,
                "Person.firstName" => "Ian",
                "Person.lastName" => "Harrigan",
                "Person.iconId" => 1,
                "Person.Icon.path" => "/somepath/icon1.png",
                "Person_Organization.Organization.name" => "ACME Inc",
            ], result.data);

            assertRecordExists([
                "Person.personId" => 1,
                "Person.firstName" => "Ian",
                "Person.lastName" => "Harrigan",
                "Person.iconId" => 1,
                "Person.Icon.path" => "/somepath/icon1.png",
                "Person_Organization.Organization.name" => "PASX Ltd",
            ], result.data);

            async.done();
        }, error -> {
            trace("error", error);
        });
    }

    function testBasicFindOr_VarString(async:Async) {
        var personName1 = "Ian";
        var personName2 = "Jim";
        db.table("Person").then(result -> {
            return result.table.find(query($firstName = personName1 || $firstName = personName2));
        }).then(result -> {
            Assert.equals(4, result.data.length);

            assertRecordExists([
                "Person.personId" => 1,
                "Person.firstName" => "Ian",
                "Person.lastName" => "Harrigan",
                "Person.iconId" => 1,
                "Person.Icon.path" => "/somepath/icon1.png",
                "Person_Organization.Organization.name" => "ACME Inc",
            ], result.data);

            assertRecordExists([
                "Person.personId" => 1,
                "Person.firstName" => "Ian",
                "Person.lastName" => "Harrigan",
                "Person.iconId" => 1,
                "Person.Icon.path" => "/somepath/icon1.png",
                "Person_Organization.Organization.name" => "PASX Ltd",
            ], result.data);

            assertRecordExists([
                "Person.personId" => 4,
                "Person.firstName" => "Jim",
                "Person.lastName" => "Parker",
                "Person.iconId" => 1,
                "Person.Icon.path" => "/somepath/icon1.png",
                "Person_Organization.Organization.name" => "Haxe LLC",
            ], result.data);

            assertRecordExists([
                "Person.personId" => 4,
                "Person.firstName" => "Jim",
                "Person.lastName" => "Parker",
                "Person.iconId" => 1,
                "Person.Icon.path" => "/somepath/icon1.png",
                "Person_Organization.Organization.name" => "PASX Ltd",
            ], result.data);

            async.done();
        }, error -> {
            trace("error", error);
        });
    }

    function testBasicFindOr_Var(async:Async) {
        var personId1 = 1;
        var personId2 = 4;
        db.table("Person").then(result -> {
            return result.table.find(query($personId = personId1 || $personId = personId2));
        }).then(result -> {
            Assert.equals(4, result.data.length);

            assertRecordExists([
                "Person.personId" => 1,
                "Person.firstName" => "Ian",
                "Person.lastName" => "Harrigan",
                "Person.iconId" => 1,
                "Person.Icon.path" => "/somepath/icon1.png",
                "Person_Organization.Organization.name" => "ACME Inc",
            ], result.data);

            assertRecordExists([
                "Person.personId" => 1,
                "Person.firstName" => "Ian",
                "Person.lastName" => "Harrigan",
                "Person.iconId" => 1,
                "Person.Icon.path" => "/somepath/icon1.png",
                "Person_Organization.Organization.name" => "PASX Ltd",
            ], result.data);

            assertRecordExists([
                "Person.personId" => 4,
                "Person.firstName" => "Jim",
                "Person.lastName" => "Parker",
                "Person.iconId" => 1,
                "Person.Icon.path" => "/somepath/icon1.png",
                "Person_Organization.Organization.name" => "Haxe LLC",
            ], result.data);

            assertRecordExists([
                "Person.personId" => 4,
                "Person.firstName" => "Jim",
                "Person.lastName" => "Parker",
                "Person.iconId" => 1,
                "Person.Icon.path" => "/somepath/icon1.png",
                "Person_Organization.Organization.name" => "PASX Ltd",
            ], result.data);

            async.done();
        }, error -> {
            trace("error", error);
        });
    }

    function testBasicFindOr(async:Async) {
        db.table("Person").then(result -> {
            return result.table.find(query($personId = 1 || $personId = 4));
        }).then(result -> {
            Assert.equals(4, result.data.length);

            assertRecordExists([
                "Person.personId" => 1,
                "Person.firstName" => "Ian",
                "Person.lastName" => "Harrigan",
                "Person.iconId" => 1,
                "Person.Icon.path" => "/somepath/icon1.png",
                "Person_Organization.Organization.name" => "ACME Inc",
            ], result.data);

            assertRecordExists([
                "Person.personId" => 1,
                "Person.firstName" => "Ian",
                "Person.lastName" => "Harrigan",
                "Person.iconId" => 1,
                "Person.Icon.path" => "/somepath/icon1.png",
                "Person_Organization.Organization.name" => "PASX Ltd",
            ], result.data);

            assertRecordExists([
                "Person.personId" => 4,
                "Person.firstName" => "Jim",
                "Person.lastName" => "Parker",
                "Person.iconId" => 1,
                "Person.Icon.path" => "/somepath/icon1.png",
                "Person_Organization.Organization.name" => "Haxe LLC",
            ], result.data);

            assertRecordExists([
                "Person.personId" => 4,
                "Person.firstName" => "Jim",
                "Person.lastName" => "Parker",
                "Person.iconId" => 1,
                "Person.Icon.path" => "/somepath/icon1.png",
                "Person_Organization.Organization.name" => "PASX Ltd",
            ], result.data);

            async.done();
        }, error -> {
            trace("error", error);
        });
    }
}