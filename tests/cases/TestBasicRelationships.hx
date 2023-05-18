package cases;

import Query.*;
import db.IDatabase;
import utest.Assert;
import cases.util.DBCreator;
import utest.Async;
import utest.Test;

class TestBasicRelationships extends Test {
    private var db:IDatabase;

    public function new(db:IDatabase) {
        super();
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
        async.done();
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

            Assert.equals(1, result.data[0].field("Person.personId"));
            Assert.equals("Ian", result.data[0].field("Person.firstName"));
            Assert.equals("Harrigan", result.data[0].field("Person.lastName"));
            Assert.equals(1, result.data[0].field("Person.iconId"));
            Assert.equals("/somepath/icon1.png", result.data[0].field("Person.Icon.path"));
            Assert.equals("ACME Inc", result.data[0].field("Person_Organization.Organization.name"));

            Assert.equals(1, result.data[1].field("Person.personId"));
            Assert.equals("Ian", result.data[1].field("Person.firstName"));
            Assert.equals("Harrigan", result.data[1].field("Person.lastName"));
            Assert.equals(1, result.data[1].field("Person.iconId"));
            Assert.equals("/somepath/icon1.png", result.data[1].field("Person.Icon.path"));
            Assert.equals("PASX Ltd", result.data[1].field("Person_Organization.Organization.name"));

            Assert.equals(2, result.data[2].field("Person.personId"));
            Assert.equals("Bob", result.data[2].field("Person.firstName"));
            Assert.equals("Barker", result.data[2].field("Person.lastName"));
            Assert.equals(3, result.data[2].field("Person.iconId"));
            Assert.equals("/somepath/icon3.png", result.data[2].field("Person.Icon.path"));
            Assert.equals("ACME Inc", result.data[2].field("Person_Organization.Organization.name"));

            Assert.equals(2, result.data[3].field("Person.personId"));
            Assert.equals("Bob", result.data[3].field("Person.firstName"));
            Assert.equals("Barker", result.data[3].field("Person.lastName"));
            Assert.equals(3, result.data[3].field("Person.iconId"));
            Assert.equals("/somepath/icon3.png", result.data[3].field("Person.Icon.path"));
            Assert.equals("Haxe LLC", result.data[3].field("Person_Organization.Organization.name"));

            Assert.equals(3, result.data[4].field("Person.personId"));
            Assert.equals("Tim", result.data[4].field("Person.firstName"));
            Assert.equals("Mallot", result.data[4].field("Person.lastName"));
            Assert.equals(2, result.data[4].field("Person.iconId"));
            Assert.equals("/somepath/icon2.png", result.data[4].field("Person.Icon.path"));
            Assert.equals("ACME Inc", result.data[4].field("Person_Organization.Organization.name"));

            Assert.equals(4, result.data[5].field("Person.personId"));
            Assert.equals("Jim", result.data[5].field("Person.firstName"));
            Assert.equals("Parker", result.data[5].field("Person.lastName"));
            Assert.equals(1, result.data[5].field("Person.iconId"));
            Assert.equals("/somepath/icon1.png", result.data[5].field("Person.Icon.path"));
            Assert.equals("Haxe LLC", result.data[5].field("Person_Organization.Organization.name"));

            Assert.equals(4, result.data[6].field("Person.personId"));
            Assert.equals("Jim", result.data[6].field("Person.firstName"));
            Assert.equals("Parker", result.data[6].field("Person.lastName"));
            Assert.equals(1, result.data[6].field("Person.iconId"));
            Assert.equals("/somepath/icon1.png", result.data[6].field("Person.Icon.path"));
            Assert.equals("PASX Ltd", result.data[6].field("Person_Organization.Organization.name"));

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

            Assert.equals(1, result.data[0].field("Person.personId"));
            Assert.equals("Ian", result.data[0].field("Person.firstName"));
            Assert.equals("Harrigan", result.data[0].field("Person.lastName"));
            Assert.equals(1, result.data[0].field("Person.iconId"));
            Assert.equals("/somepath/icon1.png", result.data[0].field("Person.Icon.path"));
            Assert.equals("ACME Inc", result.data[0].field("Person_Organization.Organization.name"));

            Assert.equals(1, result.data[1].field("Person.personId"));
            Assert.equals("Ian", result.data[1].field("Person.firstName"));
            Assert.equals("Harrigan", result.data[1].field("Person.lastName"));
            Assert.equals(1, result.data[1].field("Person.iconId"));
            Assert.equals("/somepath/icon1.png", result.data[1].field("Person.Icon.path"));
            Assert.equals("PASX Ltd", result.data[1].field("Person_Organization.Organization.name"));

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

            Assert.equals(1, result.data[0].field("Person.personId"));
            Assert.equals("Ian", result.data[0].field("Person.firstName"));
            Assert.equals("Harrigan", result.data[0].field("Person.lastName"));
            Assert.equals(1, result.data[0].field("Person.iconId"));
            Assert.equals("/somepath/icon1.png", result.data[0].field("Person.Icon.path"));
            Assert.equals("ACME Inc", result.data[0].field("Person_Organization.Organization.name"));

            Assert.equals(1, result.data[1].field("Person.personId"));
            Assert.equals("Ian", result.data[1].field("Person.firstName"));
            Assert.equals("Harrigan", result.data[1].field("Person.lastName"));
            Assert.equals(1, result.data[1].field("Person.iconId"));
            Assert.equals("/somepath/icon1.png", result.data[1].field("Person.Icon.path"));
            Assert.equals("PASX Ltd", result.data[1].field("Person_Organization.Organization.name"));

            Assert.equals(4, result.data[2].field("Person.personId"));
            Assert.equals("Jim", result.data[2].field("Person.firstName"));
            Assert.equals("Parker", result.data[2].field("Person.lastName"));
            Assert.equals(1, result.data[2].field("Person.iconId"));
            Assert.equals("/somepath/icon1.png", result.data[2].field("Person.Icon.path"));
            Assert.equals("Haxe LLC", result.data[2].field("Person_Organization.Organization.name"));

            Assert.equals(4, result.data[3].field("Person.personId"));
            Assert.equals("Jim", result.data[3].field("Person.firstName"));
            Assert.equals("Parker", result.data[3].field("Person.lastName"));
            Assert.equals(1, result.data[3].field("Person.iconId"));
            Assert.equals("/somepath/icon1.png", result.data[3].field("Person.Icon.path"));
            Assert.equals("PASX Ltd", result.data[3].field("Person_Organization.Organization.name"));

            async.done();
        }, error -> {
            trace("error", error);
        });
    }
}