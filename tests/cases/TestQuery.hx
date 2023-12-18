package cases;

import Query.*;
import db.IDatabase;
import utest.Assert;
import cases.util.DBCreator;
import utest.Async;
import utest.ITest;

class TestQuery implements ITest {
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

    function testBasicQuery(async:Async) {
        db.table("Person").then(result -> {
            return result.table.find(query($personId = 1));
        }).then(result -> {
            Assert.equals(1, result.data.length);
            Assert.equals(1, result.data[0].field("personId"));
            Assert.equals("Ian", result.data[0].field("firstName"));
            Assert.equals("Harrigan", result.data[0].field("lastName"));
            Assert.equals(1, result.data[0].field("iconId"));
            Assert.equals(111.222, result.data[0].field("hourlyRate"));
            async.done();
        }, error -> {
            trace("error", error);
        });
    }

    function testBasicQueryGt(async:Async) {
        db.table("Person").then(result -> {
            return result.table.find(query($personId > 2));
        }).then(result -> {
            Assert.equals(2, result.data.length);
            async.done();
        }, error -> {
            trace("error", error);
        });
    }

    function testBasicQueryGte(async:Async) {
        db.table("Person").then(result -> {
            return result.table.find(query($personId >= 2));
        }).then(result -> {
            Assert.equals(3, result.data.length);
            async.done();
        }, error -> {
            trace("error", error);
        });
    }

    function testBasicQueryLt(async:Async) {
        db.table("Person").then(result -> {
            return result.table.find(query($personId < 2));
        }).then(result -> {
            Assert.equals(1, result.data.length);
            async.done();
        }, error -> {
            trace("error", error);
        });
    }

    function testBasicQueryLte(async:Async) {
        db.table("Person").then(result -> {
            return result.table.find(query($personId <= 2));
        }).then(result -> {
            Assert.equals(2, result.data.length);
            async.done();
        }, error -> {
            trace("error", error);
        });
    }

    function testBasicQueryRange(async:Async) {
        db.table("Person").then(result -> {
            return result.table.find(query($personId > 1 && $personId <= 3));
        }).then(result -> {
            Assert.equals(2, result.data.length);
            async.done();
        }, error -> {
            trace("error", error);
        });
    }

    function testBasicQuery_NoResults(async:Async) {
        db.table("Person").then(result -> {
            return result.table.find(query($personId = 101));
        }).then(result -> {
            Assert.equals(0, result.data.length);
            async.done();
        }, error -> {
            trace("error", error);
        });
    }

    function testBasicQuery_FindOne_NoResults(async:Async) {
        db.table("Person").then(result -> {
            return result.table.findOne(query($personId = 101));
        }).then(result -> {
            Assert.isNull(result.data);
            async.done();
        }, error -> {
            trace("error", error);
        });
    }

    function testBasicQuery_VarInt(async:Async) {
        var thePersonId = 1;
        db.table("Person").then(result -> {
            return result.table.find(query($personId = thePersonId));
        }).then(result -> {
            Assert.equals(1, result.data.length);
            Assert.equals(1, result.data[0].field("personId"));
            Assert.equals("Ian", result.data[0].field("firstName"));
            Assert.equals("Harrigan", result.data[0].field("lastName"));
            Assert.equals(1, result.data[0].field("iconId"));
            Assert.equals(111.222, result.data[0].field("hourlyRate"));            
            async.done();
        }, error -> {
            trace("error", error);
        });
    }

    function testBasicQuery_VarString(async:Async) {
        var thePersonName = "Ian";
        db.table("Person").then(result -> {
            return result.table.find(query($firstName = thePersonName));
        }).then(result -> {
            Assert.equals(1, result.data.length);
            Assert.equals(1, result.data[0].field("personId"));
            Assert.equals("Ian", result.data[0].field("firstName"));
            Assert.equals("Harrigan", result.data[0].field("lastName"));
            Assert.equals(1, result.data[0].field("iconId"));
            Assert.equals(111.222, result.data[0].field("hourlyRate"));            
            async.done();
        }, error -> {
            trace("error", error);
        });
    }

    function testBasicQueryOr_VarInt(async:Async) {
        var thePersonId1 = 1;
        var thePersonId2 = 4;
        db.table("Person").then(result -> {
            return result.table.find(query($personId = thePersonId1 || $personId = thePersonId2));
        }).then(result -> {
            Assert.equals(2, result.data.length);
            async.done();
        }, error -> {
            trace("error", error);
        });
    }

    function testBasicQueryOr_VarString(async:Async) {
        var thePersonName1 = "Ian";
        var thePersonName2 = "Jim";
        db.table("Person").then(result -> {
            return result.table.find(query($firstName = thePersonName1 || $firstName = thePersonName2));
        }).then(result -> {
            Assert.equals(2, result.data.length);
            async.done();
        }, error -> {
            trace("error", error);
        });
    }

    function testBasicQueryOr_VarString_VarColumn(async:Async) {
        var theColumn = "firstName";
        var thePersonName1 = "Ian";
        var thePersonName2 = "Jim";
        db.table("Person").then(result -> {
            return result.table.find(query(theColumn = thePersonName1 || theColumn = thePersonName2));
        }).then(result -> {
            Assert.equals(2, result.data.length);
            async.done();
        }, error -> {
            trace("error", error);
        });
    }

    function testBasicQuery_In(async:Async) {
        db.table("Person").then(result -> {
            return result.table.find(query($personId in [1]));
        }).then(result -> {
            Assert.equals(1, result.data.length);
            Assert.equals(1, result.data[0].field("personId"));
            Assert.equals("Ian", result.data[0].field("firstName"));
            Assert.equals("Harrigan", result.data[0].field("lastName"));
            Assert.equals(1, result.data[0].field("iconId"));
            Assert.equals(111.222, result.data[0].field("hourlyRate"));            
            async.done();
        }, error -> {
            trace("error", error);
        });
    }

    function testBasicQuery_InVar(async:Async) {
        var array = [1];
        db.table("Person").then(result -> {
            return result.table.find(query($personId in array));
        }).then(result -> {
            Assert.equals(1, result.data.length);
            Assert.equals(1, result.data[0].field("personId"));
            Assert.equals("Ian", result.data[0].field("firstName"));
            Assert.equals("Harrigan", result.data[0].field("lastName"));
            Assert.equals(1, result.data[0].field("iconId"));
            Assert.equals(111.222, result.data[0].field("hourlyRate"));            
            async.done();
        }, error -> {
            trace("error", error);
        });
    }

    function testBasicQuery_VarColumn(async:Async) {
        var columnName = "personId";
        db.table("Person").then(result -> {
            return result.table.find(query(columnName = 1));
        }).then(result -> {
            Assert.equals(1, result.data.length);
            Assert.equals(1, result.data[0].field("personId"));
            Assert.equals("Ian", result.data[0].field("firstName"));
            Assert.equals("Harrigan", result.data[0].field("lastName"));
            Assert.equals(1, result.data[0].field("iconId"));
            Assert.equals(111.222, result.data[0].field("hourlyRate"));            
            async.done();
        }, error -> {
            trace("error", error);
        });
    }

    function testBasicQuery_And_NoResults(async:Async) {
        db.table("Person").then(result -> {
            return result.table.find(query($personId = 1 && $personId = 2));
        }).then(result -> {
            Assert.equals(0, result.data.length);
            async.done();
        }, error -> {
            trace("error", error);
        });
    }

    function testBasicQuery_And_Results(async:Async) {
        db.table("Person").then(result -> {
            return result.table.find(query($personId = 1 && $firstName = "Ian" && $lastName = "Harrigan"));
        }).then(result -> {
            Assert.equals(1, result.data.length);
            Assert.equals(1, result.data[0].field("personId"));
            Assert.equals("Ian", result.data[0].field("firstName"));
            Assert.equals("Harrigan", result.data[0].field("lastName"));
            Assert.equals(1, result.data[0].field("iconId"));
            Assert.equals(111.222, result.data[0].field("hourlyRate"));            
            async.done();
        }, error -> {
            trace("error", error);
        });
    }

    function testBasicQuery_Or_Results(async:Async) {
        db.table("Person").then(result -> {
            return result.table.find(query($personId = 1 || $personId = 2));
        }).then(result -> {
            Assert.equals(2, result.data.length);

            Assert.equals(1, result.data[0].field("personId"));
            Assert.equals("Ian", result.data[0].field("firstName"));
            Assert.equals("Harrigan", result.data[0].field("lastName"));
            Assert.equals(1, result.data[0].field("iconId"));
            Assert.equals(111.222, result.data[0].field("hourlyRate"));            

            Assert.equals(2, result.data[1].field("personId"));
            Assert.equals("Bob", result.data[1].field("firstName"));
            Assert.equals("Barker", result.data[1].field("lastName"));
            Assert.equals(3, result.data[1].field("iconId"));
            Assert.equals(333.444, result.data[1].field("hourlyRate"));            
            
            async.done();
        }, error -> {
            trace("error", error);
        });
    }

    function testBasicQuery_AndOr_Results(async:Async) {
        db.table("Person").then(result -> {
            return result.table.find(query(($personId = 1 || $personId = 2) && $firstName = "Ian" && $lastName = "Harrigan"));
        }).then(result -> {
            Assert.equals(1, result.data.length);
            Assert.equals(1, result.data[0].field("personId"));
            Assert.equals("Ian", result.data[0].field("firstName"));
            Assert.equals("Harrigan", result.data[0].field("lastName"));
            Assert.equals(1, result.data[0].field("iconId"));
            Assert.equals(111.222, result.data[0].field("hourlyRate"));            
            
            async.done();
        }, error -> {
            trace("error", error);
        });
    }
}