package cases;

import db.Record;
import haxe.io.Bytes;
import utest.Assert;
import cases.util.DBCreator;
import utest.Async;
import db.IDatabase;
import utest.ITest;
import Query.*;

class TestBinary implements ITest {
    private var db:IDatabase;

    public function new(db:IDatabase) {
        this.db = db;
    }

    function setup(async:Async) {
        logging.LogManager.instance.addAdaptor(new logging.adaptors.ConsoleLogAdaptor({
            levels: [logging.LogLevel.Info, logging.LogLevel.Error]
        }));
        DBCreator.create(db).then(_ -> {
            async.done();
        });
    }

    function teardown(async:Async) {
        logging.LogManager.instance.clearAdaptors();
        db.disconnect().then(_ -> {
            DBCreator.cleanUp();
            async.done();
        }, error -> {
            trace(error);
        });
    }

    function testBinaryFindOne(async:Async) {
        db.table("Person").then(result -> {
            return result.table.findOne(query($personId = 1));
        }).then(result -> {
            Assert.equals(1, result.data.field("personId"));
            Assert.equals("Ian", result.data.field("firstName"));
            Assert.equals("Harrigan", result.data.field("lastName"));
            Assert.equals(1, result.data.field("iconId"));
            Assert.isOfType(result.data.field("contractDocument"), Bytes);
            var bytes:Bytes = result.data.field("contractDocument");
            Assert.equals(Bytes.ofString("this is ians contract document").toString(), bytes.toString());
            async.done();
        }, error -> {
            trace("error", error);
        });
    }

    function testBinaryFindAll(async:Async) {
        db.table("Person").then(result -> {
            return result.table.all();
        }).then(result -> {
            Assert.equals(4, result.data.length);

            Assert.equals(1, result.data[0].field("personId"));
            Assert.equals("Ian", result.data[0].field("firstName"));
            Assert.equals("Harrigan", result.data[0].field("lastName"));
            Assert.equals(1, result.data[0].field("iconId"));
            Assert.isOfType(result.data[0].field("contractDocument"), Bytes);
            var bytes:Bytes = result.data[0].field("contractDocument");
            Assert.equals(Bytes.ofString("this is ians contract document").toString(), bytes.toString());

            async.done();
        }, error -> {
            trace("error", error);
        });
    }

    function testBinaryFind(async:Async) {
        db.table("Person").then(result -> {
            return result.table.find(query($personId = 1));
        }).then(result -> {
            Assert.equals(1, result.data.length);

            Assert.equals(1, result.data[0].field("personId"));
            Assert.equals("Ian", result.data[0].field("firstName"));
            Assert.equals("Harrigan", result.data[0].field("lastName"));
            Assert.equals(1, result.data[0].field("iconId"));
            Assert.isOfType(result.data[0].field("contractDocument"), Bytes);
            var bytes:Bytes = result.data[0].field("contractDocument");
            Assert.equals(Bytes.ofString("this is ians contract document").toString(), bytes.toString());
            async.done();
        }, error -> {
            trace("error", error);
        });
    }

    function testBinaryAdd(async:Async) {
        db.table("Person").then(result -> {
            var record = new Record();
            record.field("lastName", "new last name");
            record.field("firstName", "new first name");
            record.field("iconId", 1);
            record.field("contractDocument", Bytes.ofString("this is a new contract document"));
            return result.table.add(record);
        }).then(result -> {
            Assert.equals(5, result.data.field("_insertedId"));
            Assert.equals("new first name", result.data.field("firstName"));
            Assert.equals("new last name", result.data.field("lastName"));
            Assert.equals(1, result.data.field("iconId"));
            Assert.isOfType(result.data.field("contractDocument"), Bytes);
            var bytes:Bytes = result.data.field("contractDocument");
            Assert.equals(Bytes.ofString("this is a new contract document").toString(), bytes.toString());
            return result.table.findOne(query($personId = 5)); // lets just requery to make absolutely sure
        }).then(result -> {
            Assert.equals("new first name", result.data.field("firstName"));
            Assert.equals("new last name", result.data.field("lastName"));
            Assert.equals(1, result.data.field("iconId"));
            Assert.isOfType(result.data.field("contractDocument"), Bytes);
            var bytes:Bytes = result.data.field("contractDocument");
            Assert.equals(Bytes.ofString("this is a new contract document").toString(), bytes.toString());
            async.done();
        }, error -> {
            trace("error", error);
        });
    }    
}