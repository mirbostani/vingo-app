import 'dart:io' as Io;
import 'dart:convert' as Convert;
import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as Path;
import 'package:sqflite/sqflite.dart' as Sqflite;
import 'package:sqflite_common_ffi/sqflite_ffi.dart' as SqfliteFfi;
import 'package:vingo/util/file.dart' as Vingo;
import 'package:vingo/util/platform.dart' as Vingo;
import 'package:vingo/util/date_time.dart' as Vingo;
import 'package:vingo/util/string.dart' as Vingo;

class SqliteUtil {
  static Map<String, SqliteUtil> _instances = <String, SqliteUtil>{};
  static const String defaultDatabaseName = "vingo.db";
  final String databaseName; // "vingo.db";
  final int version; // 1
  late Future<Sqflite.Database> database;

  SqliteUtil({
    required this.databaseName,
    required this.version,
  });

  /// Get an instance. It's capable of creating multiple database instances
  /// based on the provided name.
  ///
  /// ```dart
  /// void main() async {
  ///   await Sqlite.getInstance(databaseName: "vingo.db", version: 1).open();
  /// }
  /// ```
  static SqliteUtil getInstance({
    String databaseName = SqliteUtil.defaultDatabaseName,
    int version = 1,
  }) {
    if (!_instances.containsKey(databaseName)) {
      _instances[databaseName] = new SqliteUtil(
        databaseName: databaseName,
        version: version,
      );
    }
    return _instances[databaseName]!;
  }

  /// Get database path based on the running platform.
  Future<String> getDatabasePath() async {
    if (Io.Platform.isLinux || Io.Platform.isMacOS || Io.Platform.isWindows) {
      return Path.join(await Vingo.FileUtil.getAppSupportDir(), databaseName);
    } else if (Io.Platform.isAndroid || Io.Platform.isIOS) {
      return Path.join(await Sqflite.getDatabasesPath(), databaseName);
    }
    assert(false, "SqliteUtil does not support $defaultDatabaseName");
    return "";
  }

  /// Create tables in the database
  /// @private
  FutureOr<void> _onCreate(Sqflite.Database db, int ver) async {
    Sqflite.Batch batch = db.batch();

    // Decks table
    batch.execute("""
    CREATE TABLE IF NOT EXISTS decks (
      id INTEGER PRIMARY KEY AUTOINCREMENT, 
      name TEXT NOT NULL,
      parent_id INTEGER NOT NULL,
      sort_id INTEGER NOT NULL,
      color_id INTEGER,
      settings TEXT
      ) 
    """);

    // Index for sorting decks by their name
    batch.execute("""
    CREATE INDEX IF NOT EXISTS idx_name
    ON decks(name)
    """);

    // Index for sorting decks by their sort id and then name
    batch.execute("""
    CREATE INDEX IF NOT EXISTS idx_sort_id__name
    ON decks(sort_id, name)
    """);

    // Cards table
    batch.execute("""
    CREATE TABLE IF NOT EXISTS cards (
      id INTEGER PRIMARY KEY AUTOINCREMENT, 
      deck_id INTEGER NOT NULL,
      front TEXT,
      back TEXT,
      attachment TEXT,
      sort_id INTEGER,
      iteration INTEGER,
      interval REAL,
      easiness_factor REAL,
      due_at INTEGER,
      tag TEXT,
      updated_at INTEGER,
      created_at INTEGER
      )          
    """);

    // Index for sorting cards of a deck based on their sort id
    batch.execute("""
    CREATE INDEX IF NOT EXISTS idx_deck_id__sort_id__front
    ON cards(deck_id, sort_id, front)
    """);

    // Index for searching duplicate cards between multiple or current deck
    batch.execute("""
    CREATE INDEX IF NOT EXISTS idx_front__deck_id
    ON cards(front, deck_id)
    """);

    // Index for searching cards of a deck by due for study purpose
    batch.execute("""
    CREATE INDEX IF NOT EXISTS idx_deck_id__due_at
    ON cards(deck_id, due_at)
    """);

    await batch.commit();
  }

  /// This method is only called when the database version is greater than the
  /// older version. Update `version` in `getInsance()` method for this method
  /// to be called.
  ///
  /// Example:
  ///
  /// ```dart
  /// if (oldVer <= 1) {
  ///   Vingo.PlatformUtil.log("Upgrading database to version 2.");
  ///   Sqflite.Batch batch = db.batch();
  ///   batch.execute("""
  ///   ALTER TABLE cards ADD COLUMN attachment TEXT
  ///   """);
  ///   await batch.commit();
  /// }
  /// ```
  FutureOr<void> _onUpgrade(
      Sqflite.Database db, int oldVer, int newVer) async {}

  /// Open database connection on app start up.
  ///
  /// ```dart
  /// void main() async {
  ///   await Sqlite.getInstance().open();
  /// }
  /// ```
  Future<void> open() async {
    String dbPath = await getDatabasePath();

    if (Io.Platform.isLinux || Io.Platform.isMacOS || Io.Platform.isWindows) {
      SqfliteFfi.sqfliteFfiInit();
      var databaseFactoryFfi = SqfliteFfi.databaseFactoryFfi;
      await databaseFactoryFfi.deleteDatabase(dbPath); // delete for test
      if (await Vingo.FileUtil.exists(dbPath)) {
        Vingo.PlatformUtil.log("Opening database: $dbPath");
        // To upgrade or downgrade the schema, you have to provide `version` as
        // an option, then provide one of the `onUpgrade` or `onDowngrade`
        // methods.
        final options = Sqflite.OpenDatabaseOptions(
          version: version, // upgrade `version` in `getInstance()` method
          onUpgrade: _onUpgrade,
        );
        database = databaseFactoryFfi.openDatabase(dbPath, options: options);
        return;
      }
      Vingo.PlatformUtil.log("Creating database: $dbPath");
      final options = Sqflite.OpenDatabaseOptions(
        version: version,
        onCreate: _onCreate,
      );
      database = databaseFactoryFfi.openDatabase(dbPath, options: options);
      return;
    } else if (Io.Platform.isAndroid || Io.Platform.isIOS) {
      await Sqflite.deleteDatabase(dbPath); // delete for test
      if (await Sqflite.databaseExists(dbPath)) {
        Vingo.PlatformUtil.log("Opening database: $dbPath");
        database = Sqflite.openDatabase(
          dbPath,
          version: version, // update `version` in `getInstance()` method
          onUpgrade: _onUpgrade,
        );
        return;
      }
      Vingo.PlatformUtil.log("Creating database: $dbPath");
      database = Sqflite.openDatabase(
        dbPath,
        version: version,
        onCreate: _onCreate,
      );
      return;
    }

    throw UnimplementedError(
        "SqliteUtil does not support $defaultTargetPlatform");
  }
}

////////////////////////////////////////////////////////////////////////////////

class DeckList {
  List<Deck> decks;
  bool hasMore;

  DeckList({
    required this.decks,
    this.hasMore = false,
  });

  DeckList.fromMaps(List<Map<String, dynamic>> maps) 
  : decks = const <Deck>[], 
  hasMore = false
  {
    for (var map in maps) {
      Deck deck = Deck.fromMap(map);
      decks.add(deck);
    }
  }

  void removeLast() {
    decks.removeLast();
  }
}

////////////////////////////////////////////////////////////////////////////////

class Deck {
  static final String tableName = "decks";
  static const int nameMaxLength = 64;
  static const int defaultParentId = -1;
  static const int defaultSortId = -1;
  static const String defaultSettings = "{}";
  int? id;
  String name;
  int parentId;
  int? sortId;
  int? colorId;
  String? settings;

  Deck({
    this.id,
    required String name,
    int? parentId,
    int? sortId,
    this.colorId,
  })  : this.name = validateName(name),
        this.parentId = validateParentId(parentId),
        this.sortId = validateSortId(sortId);

  @override
  String toString() {
    return """{
      id: $id,
      name: $name,
      parent_id: $parentId,
      sort_id: $sortId,
      color_id: $colorId,
      settings: $settings,
    }""";
  }

  Deck.fromMap(Map<String, dynamic> map)
      : id = map["id"],
        name = map["name"],
        parentId = map["parent_id"],
        sortId = map["sort_id"],
        colorId = map["color_id"],
        settings = map["settings"];

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "name": validateName(name),
      "parent_id": validateParentId(parentId),
      "sort_id": sortId,
      "color_id": colorId,
      "settings": validateSettings(settings),
    };
  }

  //----------------------------------------------------------------------------

  static String validateName(String name) {
    if (name.isEmpty || name.length == 0) {
      return "deck_${Vingo.DateTimeUtil.getSecondsSinceEpoch().toString()}";
    }
    name = name.substring(
      0,
      name.length < nameMaxLength ? name.length : nameMaxLength,
    );
    return name;
  }

  static int validateParentId(int? parentId) {
    return parentId ?? defaultParentId;
  }

  static int validateSortId(int? sortId) {
    return sortId ?? defaultSortId;
  }

  static String validateSettings(String? settings) {
    return settings ?? defaultSettings;
  }

  //----------------------------------------------------------------------------

  static Future<int> insertDeck({
    required Deck deck,
    String databaseName = SqliteUtil.defaultDatabaseName,
  }) async {
    Vingo.PlatformUtil.log("Inserting deck: deck=${deck.toString()}");
    final Sqflite.Database db = await SqliteUtil.getInstance(
      databaseName: databaseName,
    ).database;
    return await db.insert(
      tableName,
      deck.toMap(),
      conflictAlgorithm: Sqflite.ConflictAlgorithm.replace,
    );
  }

  static Future<int> updateDeck({
    required Deck deck,
    String databaseName = SqliteUtil.defaultDatabaseName,
  }) async {
    Vingo.PlatformUtil.log("Updating deck: deck=${deck.toString()}");
    final Sqflite.Database db = await SqliteUtil.getInstance(
      databaseName: databaseName,
    ).database;
    return await db.update(
      tableName,
      deck.toMap(),
      where: "id=?",
      whereArgs: [deck.id],
    );
  }

  static Future<int> deleteDeck({
    required int deckId,
    String databaseName = SqliteUtil.defaultDatabaseName,
  }) async {
    Vingo.PlatformUtil.log("Deleting deck: deckId=$deckId");
    final Sqflite.Database db = await SqliteUtil.getInstance(
      databaseName: databaseName,
    ).database;
    await Card.deleteCards(deckId: deckId, databaseName: databaseName);
    return await db.delete(
      tableName,
      where: "id=?",
      whereArgs: [deckId],
    );
  }

  static Future<Deck?> selectDeck({
    required int deckId,
    String databaseName = SqliteUtil.defaultDatabaseName,
  }) async {
    Vingo.PlatformUtil.log("Seleting deck: deckId=$deckId");
    final Sqflite.Database db = await SqliteUtil.getInstance(
      databaseName: databaseName,
    ).database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: "id=?",
      whereArgs: [deckId],
    );
    if (maps.length == 0) {
      return null;
    }
    Deck deck = Deck.fromMap(maps[0]);
    // TODO: Count cards
    return deck;
  }

  static Future<DeckList> selectDecks({
    String name = "",
    int limit = 50,
    int offset = 0,
    OrderType orderByName = OrderType.ASCENDING,
    String databaseName = SqliteUtil.defaultDatabaseName,
  }) async {
    Vingo.PlatformUtil.log("Selecting decks: name=$name");

    final Sqflite.Database db = await SqliteUtil.getInstance(
      databaseName: databaseName,
    ).database;

    String? where;
    name = Vingo.StringUtil.escapeSql(name);
    if (name.isNotEmpty) {
      where = "name LIKE '%$name%'";
    }

    String? orderBy;
    switch (orderByName) {
      case OrderType.ASCENDING:
        orderBy = "name ASC";
        break;
      case OrderType.DESCENDING:
        orderBy = "name DESC";
        break;
      case OrderType.NONE:
      default:
        break;
    }

    List<Map<String, dynamic>> maps = await db.query(
      tableName,
      limit: limit + 1, // +1 is used for "hasMore"
      offset: offset,
      orderBy: orderBy,
      where: where,
    );

    DeckList deckList = DeckList.fromMaps(maps);
    deckList.hasMore = maps.length > limit;
    if (deckList.hasMore) {
      deckList.removeLast();
    }

    return deckList;
  }

  //----------------------------------------------------------------------------

  Future<int> insert({
    String databaseName = SqliteUtil.defaultDatabaseName,
  }) async {
    int deckId = await Deck.insertDeck(
      deck: this,
      databaseName: databaseName,
    );
    this.id = deckId;
    return deckId;
  }

  //----------------------------------------------------------------------------

  void setSettings(Map<String, dynamic> map) {
    settings = Convert.json.encode(map);
  }

  void setSetting(String key, dynamic value) {
    Map<String, dynamic> map = getSettings();
    map[key] = value;
    setSettings(map);
  }

  Map<String, dynamic> getSettings() {
    return Convert.json.decode(settings!);
  }

  dynamic getSetting(String key) {
    return getSettings()[key];
  }

  void removeSettings() {
    settings = '{}';
  }

  void removeSetting(String key) {
    Map<String, dynamic> map = getSettings();
    map.remove(key);
    setSettings(map);
  }

  //----------------------------------------------------------------------------

  set spellCheckEnabled(bool value) {
    setSetting('spell_check_enabled', value);
  }

  bool get spellCheckEnabled {
    return getSetting('spell_check_enabled') ?? false;
  }
}

////////////////////////////////////////////////////////////////////////////////

class Card {
  static final String tableName = "cards";

  static Future<int> deleteCards({
    required int deckId,
    String databaseName = SqliteUtil.defaultDatabaseName,
  }) async {
    Vingo.PlatformUtil.log("Deleting cards: dekcId=$deckId");
    final Sqflite.Database db = await SqliteUtil.getInstance(
      databaseName: databaseName,
    ).database;
    return await db.delete(
      tableName,
      where: "deck_id=?",
      whereArgs: [deckId],
    );
  }
}

////////////////////////////////////////////////////////////////////////////////

enum OrderType {
  NONE,
  ASCENDING,
  DESCENDING,
}
