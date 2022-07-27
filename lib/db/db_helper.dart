import 'package:sqflite/sqflite.dart';

class Tables {
  static String shop = "shop";
  static String customer = "customer";
  static String supplier = "supplier";
  static String expense = "expense";
  static String category = "category";
  static String payment = "payment";
  static String product = "product";
  static String order = "orderProduct";
  static String cart = "cart";

}

class DBHelper {
  static Database? _db;
  static final int _version = 2;
  static final String _database = "pos.db";

  static Future<Database> initDB() async {
    String _path = await getDatabasesPath() + "/$_database";
    return openDatabase(
      _path,
      version: _version,
      onCreate: (db, version) async {
        await createTables(db);
        await storeDefaultData(db);
      },
    );
  }

  static Future<void> storeDefaultData(Database db) async {
    db.transaction((txn) async {
      // save Default pay type
      await txn.rawInsert("""
        INSERT INTO ${Tables.payment} (name)
        VALUES ("CASH")
      """);

      // save Default customer
      await txn.rawInsert("""
        INSERT INTO ${Tables.customer} (name)
        VALUES ("WALK IN CUSTOMER")
      """);
    });
  }

  static Future<void> createTables(Database database) async {
    print("TABLE CREATING......");
    String id = "id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL";
    String createdAt = "createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP";
    await database.execute("""
      CREATE TABLE ${Tables.shop} (
        $id ,
        name TEXT,
        phone TEXT,
        email TEXT,
        address TEXT,
        currencySymbol TEXT,
        tax REAL,
        $createdAt
      )
    """);

    await database.execute("""
      CREATE TABLE ${Tables.customer} (
        $id ,
        name TEXT,
        phone TEXT,
        email TEXT,
        address TEXT,
        $createdAt
      )
    """);

    await database.execute("""
      CREATE TABLE ${Tables.supplier} (
        $id ,
        name TEXT,
        phone TEXT,
        email TEXT,
        address TEXT,
        $createdAt
      )
    """);

    await database.execute("""
      CREATE TABLE ${Tables.expense} (
        $id ,
        name TEXT,
        amount REAL,
        date TEXT,
        time TEXT,
        note TEXT,
        $createdAt
      )
    """);

    await database.execute("""
      CREATE TABLE ${Tables.category} (
        $id ,
        name TEXT,
        
        $createdAt
      )
    """);

    await database.execute("""
      CREATE TABLE ${Tables.payment} (
        $id ,
        name TEXT,
        
        $createdAt
      )
    """);

    await database.execute("""
      CREATE TABLE ${Tables.product} (
        $id ,
        name TEXT,
        code TEXT,
        image BLOB,
        qty INTEGER,
        description TEXT,
        buyPrice REAL,
        sellPrice REAL,
        weight TEXT,
        weightUnit TEXT,
        category TEXT,
        supplier TEXT,
        
        $createdAt
      )
    """);

    await database.execute("""
      CREATE TABLE ${Tables.cart} (
        $id ,
        name TEXT,
        code TEXT,
        image BLOB,
        qty INTEGER,
        description TEXT,
        buyPrice REAL,
        sellPrice REAL,
        weight TEXT,
        weightUnit TEXT,
        category TEXT,
        supplier TEXT,
        
        $createdAt
      )
    """);

    await database.execute("""
      CREATE TABLE ${Tables.order} (
        $id ,
        orderId TEXT,
        date TEXT,
        subTotal REAL,
        total REAL,
        totalTax REAL,
        totalDiscount REAL,
        products TEXT,
        customer TEXT,
        orderType TEXT,
        payType TEXT,
        payAmount REAL,
        change REAL,
        status TEXT,
        orderDate TEXT,
        
        $createdAt
      )
    """);
  }
}
