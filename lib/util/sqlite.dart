import 'dart:io' as Io;
import 'dart:convert' as Convert;
import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as Path;
import 'package:sqflite/sqflite.dart' as Sqflite;
import 'package:sqflite_common_ffi/sqflite_ffi.dart' as SqfliteFfi;
import 'package:vingo/util/util.dart' as Vingo;

////////////////////////////////////////////////////////////////////////////////

enum OrderType {
  NONE,
  ASCENDING,
  DESCENDING,
}

enum CardsOrderType {
  IN_ORDER_ADDED,
  IN_RANDOM_ORDER,
}

////////////////////////////////////////////////////////////////////////////////

class SqliteUtil {
  /// Debug
  static bool debugDeleteDatabaseOnStart = false;

  /// Properties
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
      front TEXT NOT NULL,
      back TEXT,
      attachment TEXT,
      deck_id INTEGER NOT NULL,
      sort_id INTEGER NOT NULL,
      iteration INTEGER NOT NULL,
      interval REAL NOT NULL,
      easiness_factor REAL NOT NULL,
      due_at INTEGER NOT NULL,
      tag TEXT,
      updated_at INTEGER NOT NULL,
      created_at INTEGER NOT NULL
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
      if (debugDeleteDatabaseOnStart) {
        await databaseFactoryFfi.deleteDatabase(dbPath);
      }
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
      if (debugDeleteDatabaseOnStart) {
        await Sqflite.deleteDatabase(dbPath);
      }
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

class Decks {
  List<Deck> items;
  bool hasMore;
  bool loading = false;
  int limit = 25;
  int offset = 0;
  OrderType orderBy = OrderType.ASCENDING;
  String databaseName = SqliteUtil.defaultDatabaseName;

  Decks({
    List<Deck>? items,
    this.hasMore = false,
  }) : this.items = items ?? <Deck>[];

  Decks.fromMaps(List<Map<String, dynamic>> maps)
      : items = <Deck>[],
        hasMore = false {
    for (var map in maps) {
      Deck deck = Deck.fromMap(map);
      items.add(deck);
    }
  }

  void removeLast() {
    items.removeLast();
  }

  Future<void> removeAt(int index) async {
    if (index < 0 || index >= items.length) return;
    Deck deck = items.removeAt(index);
    if (offset != 0) offset -= 1;
    await deck.delete();
  }

  Future<int> refresh({
    String? name,
  }) async {
    loading = true;
    offset = 0;
    Decks selectedDecks = await Deck.selectDecks(
      name: name ?? "",
      limit: limit,
      offset: offset,
      orderByName: orderBy,
      databaseName: databaseName,
    );
    items = selectedDecks.items;
    hasMore = selectedDecks.hasMore;
    offset = items.length;
    loading = false;
    return selectedDecks.items.length;
  }

  Future<int> loadMore({
    String? name,
  }) async {
    if (!hasMore) return 0;
    int count = 0;
    loading = true;
    Decks selectedDecks = await Deck.selectDecks(
        name: name ?? "",
        limit: limit,
        offset: offset,
        orderByName: orderBy,
        databaseName: databaseName);
    if (selectedDecks.items.length > 0) {
      count = selectedDecks.items.length;
      items.addAll(selectedDecks.items);
      offset = items.length;
    }
    hasMore = selectedDecks.hasMore;
    loading = false;
    return count;
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

  factory Deck.fromDeck(Deck deck) {
    return Deck.fromMap(deck.toMap());
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

  Deck fromDeck(Deck deck) {
    this.id = deck.id;
    this.name = deck.name;
    this.parentId = deck.parentId;
    this.sortId = deck.sortId;
    this.colorId = deck.colorId;
    this.settings = deck.settings;
    return this;
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
    bool countCards = true,
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

    if (countCards) {
      await deck.countStudyCards(
        // tags: tags, // todo
        databaseName: databaseName,
      );
      await deck.update(databaseName: databaseName);
    }

    return deck;
  }

  static Future<Decks> selectDecks({
    String name = "",
    int limit = 50,
    int offset = 0,
    OrderType orderByName = OrderType.ASCENDING,
    bool countCards = true,
    String databaseName = SqliteUtil.defaultDatabaseName,
  }) async {
    Vingo.PlatformUtil.log("Selecting decks: name=$name");

    final Sqflite.Database db = await SqliteUtil.getInstance(
      databaseName: databaseName,
    ).database;

    String? where;
    name = Vingo.StringUtil.escapeSql(name);
    if (name.isNotEmpty) {
      // where = "";
      // name.split(" ").forEach((el) {
      //   where = where! + (where!.isNotEmpty ? " OR" : "") + " name LIKE '%$el%'";
      // });
      // where = where!.trim();
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

    Decks decks = Decks.fromMaps(maps);
    decks.hasMore = maps.length > limit;
    if (decks.hasMore) {
      decks.removeLast();
    }

    if (countCards) {
      decks.items.forEach((deck) async {
        bool isUpdated = await deck.countStudyCards(
          // tags: tags, // todo
          databaseName: databaseName,
        );
        if (isUpdated) {
          await deck.update(databaseName: databaseName);
        }
      });
    }

    return decks;
  }

  /// Count total number of decks.
  /// @see `Cards.countCards`
  static Future<Map<String, int>> countDecks({
    required int collectionId,
    String databaseName = SqliteUtil.defaultDatabaseName,
  }) async {
    final Sqflite.Database db = await SqliteUtil.getInstance(
      databaseName: databaseName,
    ).database;
    String sql = """
    SELECT
    total_decks.count AS total_decks_count
    FROM
    (SELECT COUNT(*) as count FROM $tableName) AS total_decks
    """;
    final List<Map<String, dynamic>> maps = await db.rawQuery(sql);
    Map<String, int> result = {
      "total_decks_count": 0,
    };
    if (maps.length == 0) {
      return result;
    }
    result['total_decks_count'] = maps[0]['total_decks_count'];
    return result;
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

  Future<int> update({
    String databaseName = SqliteUtil.defaultDatabaseName,
  }) async {
    Vingo.PlatformUtil.log("Updating deck: name=${this.name}");
    return await Deck.updateDeck(deck: this, databaseName: databaseName);
  }

  Future<int> delete({
    String databaseName = SqliteUtil.defaultDatabaseName,
  }) async {
    if (this.id == null) return -1;
    Vingo.PlatformUtil.log("Deleting deck: name=${this.name}");
    return await Deck.deleteDeck(deckId: this.id!, databaseName: databaseName);
  }

  Future<void> select({
    bool countCards = true,
    String databaseName = SqliteUtil.defaultDatabaseName,
  }) async {
    if (this.id == null) return;
    Deck? deck = await Deck.selectDeck(
      deckId: this.id!,
      countCards: countCards,
      databaseName: databaseName,
    );
    if (deck == null) return;
    this.fromDeck(deck);
  }

  Future<bool> countStudyCards({
    List<String>? tags,
    String databaseName = SqliteUtil.defaultDatabaseName,
  }) async {
    Map<String, int> result = await Card.countStudyCards(
      deckId: this.id!,
      tags: tags,
      databaseName: databaseName,
    );
    bool isUpdated = false;
    if (this.newCardsCount != result['new_cards_count']) {
      this.newCardsCount = result['new_cards_count']!;
      isUpdated = true;
    }
    if (this.reviewCardsCount != result['review_cards_count']) {
      this.reviewCardsCount = result['review_cards_count']!;
      isUpdated = true;
    }
    if (this.learningCardsCount != result['learning_cards_count']) {
      this.learningCardsCount = result['learning_cards_count']!;
      isUpdated = true;
    }
    if (this.totalCardsCount != result['total_cards_count']) {
      this.totalCardsCount = result['total_cards_count']!;
      isUpdated = true;
    }
    return isUpdated;
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

  set totalCardsCount(int value) {
    setSetting('total_cards_count', value);
  }

  int get totalCardsCount {
    return getSetting('total_cards_count') ?? 0;
  }

  set newCardsCount(int value) {
    setSetting('new_cards_count', value);
  }

  int get newCardsCount {
    return getSetting('new_cards_count') ?? 0;
  }

  set reviewCardsCount(int value) {
    setSetting('review_cards_count', value);
  }

  int get reviewCardsCount {
    return getSetting('review_cards_count') ?? 0;
  }

  set learningCardsCount(int value) {
    setSetting('learning_cards_count', value);
  }

  int get learningCardsCount {
    return getSetting('learning_cards_count') ?? 0;
  }

  set autoplayPronunciationEnabled(bool value) {
    setSetting('autoplay_pronunciation_enabled', value);
  }

  bool get autoplayPronunciationEnabled {
    return getSetting('autoplay_pronunciation_enabled') ?? false;
  }

  set spellCheckEnabled(bool value) {
    setSetting('spell_check_enabled', value);
  }

  bool get spellCheckEnabled {
    return getSetting('spell_check_enabled') ?? false;
  }

  set newCardsOrderId(int value) {
    setSetting('new_cards_order_id', value);
  }

  int get newCardsOrderId {
    return getSetting('new_cards_order_id') ?? 0; // 0 is 'in order added'
  }

  set newCardsPerDay(int value) {
    value = value < 0 ? 0 : (value > 9999 ? 9999 : value);
    setSetting('new_cards_per_day', value);
  }

  int get newCardsPerDay {
    return getSetting('new_cards_per_day') ?? 25;
  }

  // set reviewsOrderId(int value) {
  //   setSetting('reviews_order_id', value);
  // }

  // int get reviewsOrderId {
  //   return getSetting('reviews_order_id') ?? 0; // 0 is 'in order added'
  // }

  set reviewsPerDay(int value) {
    value = value < 0 ? 0 : (value > 9999 ? 9999 : value);
    setSetting('reviews_per_day', value);
  }

  int get reviewsPerDay {
    return getSetting('reviews_per_day') ?? 100;
  }
}

////////////////////////////////////////////////////////////////////////////////

class Cards {
  List<Card> items;
  bool hasMore;
  bool loading = false;
  int limit = 25;
  int offset = 0;
  OrderType orderBy = OrderType.ASCENDING;
  String databaseName = SqliteUtil.defaultDatabaseName;

  Cards({
    List<Card>? items,
    this.hasMore = false,
  }) : this.items = items ?? <Card>[];

  Cards.fromMaps(List<Map<String, dynamic>> maps)
      : items = <Card>[],
        hasMore = false {
    for (var map in maps) {
      Card card = Card.fromMap(map);
      items.add(card);
    }
  }

  void removeLast() {
    items.removeLast();
  }

  Future<void> removeAt(int index) async {
    if (index < 0 || index >= items.length) return;
    Card card = items.removeAt(index);
    if (offset != 0) offset -= 1;
    await card.delete();
  }

  Future<int> refresh({
    int? deckId,
    String? search,
  }) async {
    loading = true;
    offset = 0;
    Cards selectedCards = await Card.selectCards(
      deckId: deckId,
      search: search ?? "",
      limit: limit,
      offset: offset,
      orderByFront: orderBy,
      databaseName: databaseName,
    );
    items = selectedCards.items;
    hasMore = selectedCards.hasMore;
    offset = items.length;
    loading = false;
    return selectedCards.items.length;
  }

  Future<int> loadMore({
    int? deckId,
    String? search,
  }) async {
    if (!hasMore) return 0;
    int count = 0;
    loading = true;
    Cards selectedCards = await Card.selectCards(
      deckId: deckId,
      search: search ?? "",
      limit: limit,
      offset: offset,
      orderByFront: orderBy,
      databaseName: databaseName,
    );
    if (selectedCards.items.length > 0) {
      count = selectedCards.items.length;
      items.addAll(selectedCards.items);
      offset = items.length;
    }
    hasMore = selectedCards.hasMore;
    loading = false;
    return count;
  }
}

////////////////////////////////////////////////////////////////////////////////

class Card {
  static final String tableName = "cards";
  int? id;
  String front;
  String? back;
  int deckId;

  /// Card attachments
  Map<String, dynamic>? attachment;
  static const String defaultAttachment = "{}";

  /// Sort cards based on an id
  int? sortId;
  static const int defaultSortId = -1;

  /// Iteration (or n) is a counter which starts from 1 to n.
  /// I(1) = 1
  /// I(2) = 6
  /// I(n):=I(n-1)*EF
  int? iteration;

  /// First iteration (n = 1)
  /// I(n) = I(1) = 1 day
  static const int iteration1 = 1;

  /// Interval between the previous and the next repetition (in days) starts
  /// from I(1) which means next interval for repetition is in 1 day. The next
  /// interval after the first one will be I(2) which is in 6 days and so on.
  /// I(1) = 1
  /// I(2) = 6
  /// I(n):=I(n-1)*EF
  double? interval; // I(n)
  static const double interval1 = 1.0; // I(1)
  static const double interval2 = 6.0; // I(2)

  /// Easiness factor. Entry (default) value is 2.5.
  /// EF':=EF+(0.1-(5-q)*(0.08+(5-q)*0.02))
  double? easinessFactor;

  /// Default entry value for easiness factor.
  static const easinessFactorEntryValue = 2.5;

  /// Minimum possible value for easiness factor. Easiness factor should always
  /// be greater than 1.3 (hardest).
  static const double easinessFactorMin = 1.3;

  /// Maximum possible value for easiness quality.
  /// 5 - perfect response
  /// 4 - correct response after a hesitation
  /// 3 - correct response recalled with serious difficulty
  /// 2 - incorrect response; where the correct on seemed easy to recall
  /// 1 - incorrect response; the correct one remembered
  /// 0 - complete blackout
  static const int easinessQualityMax = 5;

  /// Card's due in seconds since epoch.
  int? dueAt;

  /// New/Learning/Review cards' default values.
  /// new = 0
  /// learning = -1
  /// 0 < review < now
  static const int dueAtNew = 0;
  static const int dueAtLearning = -1;

  // Card's creation and update date time in seconds since epoch.
  int? updatedAt;
  int? createdAt;

  int get dueInSeconds {
    if (dueAt == null) return dueAtNew;
    return (dueAt! - Vingo.DateTimeUtil.getSecondsSinceEpoch());
  }

  int get dueInMinutes {
    return dueInSeconds ~/ 60;
  }

  int get dueInHours {
    return dueInSeconds ~/ (60 * 60);
  }

  int get dueInDays {
    return dueInSeconds ~/ (60 * 60 * 24);
  }

  Card({
    this.id,
    required this.deckId,
    required this.front,
    this.back,
    Map<String, dynamic>? attachment,
    int? sortId,
    int? iteration,
    double? interval,
    double? easinessFactor,
    int? dueAt,
    int? updatedAt,
    int? createdAt,
  })  : this.attachment = attachment ?? Convert.json.decode(defaultAttachment),
        this.sortId = sortId ?? defaultSortId,
        this.iteration = iteration ?? iteration1,
        this.interval = interval ?? interval1,
        this.easinessFactor = easinessFactor ?? easinessFactorEntryValue,
        this.dueAt = dueAt ?? dueAtNew,
        this.updatedAt = updatedAt ?? Vingo.DateTimeUtil.getSecondsSinceEpoch(),
        this.createdAt = createdAt ?? Vingo.DateTimeUtil.getSecondsSinceEpoch();

  factory Card.fromCard(Card card) {
    return Card.fromMap(card.toMap());
  }

  @override
  String toString() {
    return """{
      id: $id,
      deck_id: $deckId,
      front: $front,
      back: $back,
      attachment: $attachment,
      sort_id: $sortId,
      iteration: $iteration,
      interval: $interval,
      easiness_factor: $easinessFactor,
      due_at: $dueAt,
      updated_at: $updatedAt,
      created_at: $createdAt,
    }""";
  }

  Card.fromMap(Map<String, dynamic> map)
      : id = map["id"],
        deckId = map["deck_id"],
        front = map["front"],
        back = map["back"],
        attachment = Convert.json.decode(map["attachment"]),
        sortId = map["sort_id"],
        iteration = map["iteration"],
        interval = map["interval"],
        easinessFactor = map["easiness_factor"],
        dueAt = map["due_at"],
        updatedAt = map["updated_at"],
        createdAt = map["created_at"];

  Future<Card> fromMap(Map<String, dynamic> map) async {
    Map<String, dynamic> attachment = Convert.json.decode(map["attachment"]);

    return new Card(
      id: map["id"],
      deckId: map["deck_id"],
      front: map["front"],
      back: map["back"],
      attachment: attachment,
      sortId: map["sort_id"],
      iteration: map["iteration"],
      interval: map["interval"],
      easinessFactor: map["easiness_factor"],
      dueAt: map["due_at"],
      updatedAt: map["updated_at"],
      createdAt: map["created_at"],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "deck_id": deckId,
      "front": front,
      "back": back,
      "attachment": Convert.json.encode(attachment ?? defaultAttachment),
      "sort_id": sortId ?? defaultSortId,
      "iteration": iteration ?? iteration1,
      "interval": interval ?? interval,
      "easiness_factor": easinessFactor ?? easinessFactorEntryValue,
      "due_at": dueAt ?? dueAtNew,
      "updated_at": updatedAt ?? Vingo.DateTimeUtil.getSecondsSinceEpoch(),
      "created_at": createdAt ?? Vingo.DateTimeUtil.getSecondsSinceEpoch(),
    };
  }

  Card fromCard(Card card) {
    this.id = card.id;
    this.deckId = card.deckId;
    this.front = card.front;
    this.back = card.back;
    this.attachment = card.attachment;
    this.sortId = card.sortId;
    this.iteration = card.iteration;
    this.interval = card.interval;
    this.easinessFactor = card.easinessFactor;
    this.dueAt = card.dueAt;
    this.updatedAt = card.updatedAt;
    this.createdAt = card.createdAt;
    return this;
  }

  //----------------------------------------------------------------------------

  static Future<int> insertCard({
    required Card card,
    String databaseName = SqliteUtil.defaultDatabaseName,
  }) async {
    Vingo.PlatformUtil.log("Inserting card: card=${card.toString()}");
    final Sqflite.Database db = await SqliteUtil.getInstance(
      databaseName: databaseName,
    ).database;
    card.updatedAt = Vingo.DateTimeUtil.getSecondsSinceEpoch();
    card.createdAt = Vingo.DateTimeUtil.getSecondsSinceEpoch();
    card.attachment!.removeWhere((key, value) {
      return (!card.front.contains(key) && !card.back!.contains(key));
    });
    return await db.insert(
      tableName,
      card.toMap(),
      conflictAlgorithm: Sqflite.ConflictAlgorithm.replace,
    );
  }

  static Future<int> updateCard({
    required Card card,
    String databaseName = SqliteUtil.defaultDatabaseName,
  }) async {
    Vingo.PlatformUtil.log("Updating card: card=${card.toString()}");
    final Sqflite.Database db = await SqliteUtil.getInstance(
      databaseName: databaseName,
    ).database;
    card.updatedAt = Vingo.DateTimeUtil.getSecondsSinceEpoch();
    card.attachment!.removeWhere((key, value) {
      return (!card.front.contains(key) && !card.back!.contains(key));
    });
    return await db.update(
      tableName,
      card.toMap(),
      where: "id=?",
      whereArgs: [card.id],
    );
  }

  static Future<int> deleteCard({
    required int cardId,
    String databaseName = SqliteUtil.defaultDatabaseName,
  }) async {
    Vingo.PlatformUtil.log("Deleting card: cardId=$cardId");
    final Sqflite.Database db = await SqliteUtil.getInstance(
      databaseName: databaseName,
    ).database;
    return await db.delete(
      tableName,
      where: "id=?",
      whereArgs: [cardId],
    );
  }

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

  static Future<Card?> selectCard({
    required int cardId,
    String databaseName = SqliteUtil.defaultDatabaseName,
  }) async {
    Vingo.PlatformUtil.log("Selecting card: cardId=$cardId");
    final Sqflite.Database db = await SqliteUtil.getInstance(
      databaseName: databaseName,
    ).database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: "id=?",
      whereArgs: [cardId],
    );
    if (maps.length == 0) {
      return null;
    }
    Card card = Card.fromMap(maps[0]);
    return card;
  }

  static Future<Cards> selectCards({
    int? deckId,
    String search = "",
    int limit = 50,
    int offset = 0,
    OrderType orderByFront = OrderType.ASCENDING,
    String databaseName = SqliteUtil.defaultDatabaseName,
  }) async {
    Vingo.PlatformUtil.log("""Selecting cards: 
    deckId=$deckId, 
    search=$search,
    limit=$limit,
    offset=$offset,
    orderByFront=$orderByFront,
    """);

    final Sqflite.Database db = await SqliteUtil.getInstance(
      databaseName: databaseName,
    ).database;

    String? where;

    if (deckId != null && deckId >= 0) {
      where = "deck_id=$deckId";
    }

    search = Vingo.StringUtil.escapeSql(search);
    if (search.isNotEmpty) {
      String w = "";
      search.split(" ").forEach((keyword) {
        w += (w.isNotEmpty ? " OR " : "") + "front LIKE '%$keyword%'";
      });
      where = where == null ? w : where + " AND ($w)";
      // where += "front LIKE '%$search%'";
    }

    String? orderBy;
    switch (orderByFront) {
      case OrderType.ASCENDING:
        orderBy = "front ASC";
        break;
      case OrderType.DESCENDING:
        orderBy = "front DESC";
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

    Cards cards = Cards.fromMaps(maps);
    cards.hasMore = maps.length > limit;
    if (cards.hasMore) {
      cards.removeLast();
    }

    return cards;
  }

  static String _prepareTagsWhere({
    List<String>? tags,
  }) {
    String where = "";
    if (tags != null && tags.length > 0) {
      tags = tags.where((element) => element.trim().isNotEmpty).toList();
    }
    if (tags != null && tags.length > 0) {
      String frontWhere = "";
      String backWhere = "";
      for (int i = 0; i < tags.length; i++) {
        frontWhere +=
            "front LIKE '%${tags[i]}%'" + (i != tags.length - 1 ? " OR " : "");
        backWhere +=
            "back LIKE '%${tags[i]}%'" + (i != tags.length - 1 ? " OR " : "");
      }
      where += "($frontWhere OR $backWhere)";
    }
    return where;
  }

  static Future<Map<String, int>> countStudyCards({
    required int deckId,
    List<String>? tags,
    String databaseName = SqliteUtil.defaultDatabaseName,
  }) async {
    final Sqflite.Database db = await SqliteUtil.getInstance(
      databaseName: databaseName,
    ).database;

    String where = "";
    String tagsWhere = _prepareTagsWhere(tags: tags);
    if (tagsWhere.isNotEmpty) {
      where = "AND $tagsWhere";
    }

    String sql = """
    SELECT 
    new_cards.count AS new_cards_count, 
    review_cards.count AS review_cards_count,
    learning_cards.count AS learning_cards_count,
    total_cards.count AS total_cards_count
    FROM
    (SELECT COUNT(*) as count FROM $tableName WHERE deck_id = $deckId AND due_at = 0 $where) AS new_cards,
    (SELECT COUNT(*) as count FROM $tableName WHERE deck_id = $deckId AND due_at > 0 AND due_at < ${Vingo.DateTimeUtil.getSecondsSinceEpoch()} $where) AS review_cards,
    (SELECT COUNT(*) as count FROM $tableName WHERE deck_id = $deckId AND due_at = -1 $where) AS learning_cards,
    (SELECT COUNT(*) as count FROM $tableName WHERE deck_id = $deckId $where) AS total_cards
    """;
    final List<Map<String, dynamic>> maps = await db.rawQuery(sql);
    Map<String, int> result = {
      "new_cards_count": 0,
      "review_cards_count": 0,
      "learning_cards_count": 0,
      "total_cards_count": 0,
    };
    if (maps.length == 0) {
      return result;
    }
    result['new_cards_count'] = maps[0]['new_cards_count'];
    result['review_cards_count'] = maps[0]['review_cards_count'];
    result['learning_cards_count'] = maps[0]['learning_cards_count'];
    result['total_cards_count'] = maps[0]['total_cards_count'];
    return result;
  }

  static Future<int> countAssetUsage({
    required String assetName, // e.g. "image.png"
    String databaseName = SqliteUtil.defaultDatabaseName,
  }) async {
    final Sqflite.Database db = await SqliteUtil.getInstance(
      databaseName: databaseName,
    ).database;
    final List<Map<String, dynamic>> maps = await db.rawQuery(
      "SELECT COUNT(*) AS count FROM cards WHERE back LIKE '%$assetName%' OR front LIKE '%$assetName%'",
    );
    return maps[0]['count'];
  }

  static Future<int> countAllCards({
    String databaseName = SqliteUtil.defaultDatabaseName,
  }) async {
    final Sqflite.Database db = await SqliteUtil.getInstance(
      databaseName: databaseName,
    ).database;
    final List<Map<String, dynamic>> maps =
        await db.rawQuery("SELECT COUNT(*) as count FROM $tableName");
    if (maps.length == 0) {
      return -1;
    }
    return maps[0]['count'];
  }

  static Future<List<Card>> selectNewCards({
    int? deckId,
    required int newCardsPerDay,
    List<String>? tags,
    CardsOrderType? newCardsOrderType,
    String databaseName = SqliteUtil.defaultDatabaseName,
  }) async {
    Vingo.PlatformUtil.log("[Sqlite] Selecting new cards");
    final Sqflite.Database db = await SqliteUtil.getInstance(
      databaseName: databaseName,
    ).database;

    String tagsWhere = _prepareTagsWhere(tags: tags);

    final List<Map<String, dynamic>> maps = await db.query(tableName,
        where: "deck_id = ? AND due_at = 0" +
            (tagsWhere.isNotEmpty ? " AND $tagsWhere" : ""),
        whereArgs: [deckId],
        limit: newCardsPerDay); // new cards due is 0
    // List<Card> cards = List.generate(
    //   maps.length,
    //   (i) => Card.fromMap(maps[i]),
    // );
    List<Card> cards = <Card>[];
    for (int i = 0; i < maps.length; i++) {
      cards.add(Card.fromMap(maps[i]));
    }
    switch (newCardsOrderType) {
      case CardsOrderType.IN_RANDOM_ORDER:
        cards.shuffle();
        break;
      case CardsOrderType.IN_ORDER_ADDED:
      default:
        // do nothing
        break;
    }
    return cards;
  }

  static Future<List<Card>> selectReviewCards({
    required int deckId,
    required int reviewsPerDay,
    List<String>? tags,
    String databaseName = SqliteUtil.defaultDatabaseName,
  }) async {
    final Sqflite.Database db = await SqliteUtil.getInstance(
      databaseName: databaseName,
    ).database;

    String tagsWhere = _prepareTagsWhere(tags: tags);

    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: "deck_id = ? AND due_at > 0 AND due_at < ?" +
          (tagsWhere.isNotEmpty ? " AND $tagsWhere" : ""),
      whereArgs: [deckId, Vingo.DateTimeUtil.getSecondsSinceEpoch()],
      limit: reviewsPerDay,
    );
    // return List.generate(maps.length, (i) => Card.fromMap(maps[i]));
    List<Card> cards = <Card>[];
    for (int i = 0; i < maps.length; i++) {
      cards.add(Card.fromMap(maps[i]));
    }
    return cards;
  }

  static Future<List<Card>> selectLearningCards({
    required int deckId,
    List<String>? tags,
    String databaseName = SqliteUtil.defaultDatabaseName,
  }) async {
    final Sqflite.Database db = await SqliteUtil.getInstance(
      databaseName: databaseName,
    ).database;

    String tagsWhere = _prepareTagsWhere(tags: tags);

    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: "deck_id = ? AND due_at = -1" +
          (tagsWhere.isNotEmpty ? " AND $tagsWhere" : ""),
      whereArgs: [deckId],
    );
    // return List.generate(maps.length, (i) => Card.fromMap(maps[i]));
    List<Card> cards = <Card>[];
    for (int i = 0; i < maps.length; i++) {
      cards.add(Card.fromMap(maps[i]));
    }
    return cards;
  }

  //----------------------------------------------------------------------------

  /// Update easiness factor (EF) of the card based on the answered easiness
  /// quality.
  ///
  /// @param easinessQuality - Answer easiness quality
  ///
  /// SM2 Algorithm:
  ///
  /// 1. Split the knowledge into smallest possible items.
  ///
  /// 2. With all items associate an E-Factor equal to 2.5.
  ///
  /// 3. Repeat items using the following intervals:
  ///    I(1):=1
  ///    I(2):=6
  ///    for n>2: I(n):=I(n-1)*EF
  ///    where:
  ///    I(n) - inter-repetition interval after the n-th repetition (in
  ///           days)
  ///    EF - E-Factor of a given item
  ///    If interval is a fraction, round it up to the nearest integer
  ///
  /// 4. After each repetition assess the quality of repetition response
  ///    in 0-5 grade scale:
  ///    5 - perfect response
  ///    4 - correct response after a hesitation
  ///    3 - correct response recalled with serious difficulty
  ///    2 - incorrect response; where the correct one seemed easy to recall
  ///    1 - incorrect response; the correct one remembered
  ///    0 - complete blackout.
  ///
  /// 5. After each repetition modify the E-Factor of the recently repeated
  ///    item according to the formula:
  ///    EF':=EF+(0.1-(5-q)*(0.08+(5-q)*0.02))
  ///    where:
  ///    EF' - new value of the E-Factor
  ///    EF - old value of the E-Factor
  ///    q - quality of the response in the 0-5 grade scale
  ///    If EF is less than 1.3 then let EF be 1.3
  ///
  /// 6. If the quality response was lower than 3 then start repetitions
  ///    for the item from the beginning without changing the E-Factor
  ///    (i.e. use intervals I(1), I(2) etc. as if the item was memorized
  ///    anew).
  ///
  /// 7. After each repetition session of a given day repeat again all
  ///    items that scored below four in the quality assessment. Continue
  ///    the repetitions until all of these items score at least four.
  void updateSRS(int easinessQuality) {
    Vingo.PlatformUtil.log("""
    Updating SRS:
      easiness_quality: $easinessQuality
      interval: $interval
      iteration: $iteration
      easiness_factor: $easinessFactor
      due_at: $dueAt
    """);

    if (interval == null || easinessFactor == null || iteration == null) {
      return;
    }

    double ef = easinessFactor!;
    // (5-q)
    int k = easinessQualityMax - easinessQuality;
    // EF':=EF+(0.1-(5-q)*(0.08+(5-q)*0.02))
    // q = 5, delta_EF = 0.1
    // q = 4, delta_EF = 0.0
    // q = 3, delta_EF = -0.139
    // q = 2, delta_EF = -0.320 Start iteration from the beginning if q < 3
    // q = 1, delta_EF = -0.540
    // q = 0, delta_EF = -0.799
    ef += 0.1 - k * (0.08 + k * 0.02);
    // Easiness factor should not be less than 1.3 (hardest)
    ef = ef < easinessFactorMin ? easinessFactorMin : ef;

    // Do not change ef if reponse quality is less than 3.
    if (easinessQuality < 3) {
      iteration = iteration1; // n=1
      interval = interval1; // I(n)=I(1)=1 day
      dueAt = -1;

      Vingo.PlatformUtil.log("""
      Updated:
        easiness_quality: $easinessQuality
        interval: $interval
        iteration: $iteration
        easiness_factor: $easinessFactor
        due_at: $dueAt
      """);

      return;
    }

    // Calculate next interval
    if (iteration == 1) {
      // First iteration is initialized by 1 (24h). Do nothing.
      // interval = _interval1; // I(n)=I(1)=1 day
    } else if (iteration == 2) {
      // interval = _interval2; // I(2)=6

      // @update
      if (easinessFactor == 5) {
        interval = interval2; // I(2)=6
      } else if (easinessFactor == 4) {
        interval = interval2 - 1; // I(2)=5
      } else if (easinessFactor == 3) {
        interval = interval2 - 2; // I(2)=4
      }
    } else if (iteration! > 2) {
      interval = interval! * ef; // I(n):=I(n-1)*EF
    }
    iteration = iteration! + 1;
    easinessFactor = ef;

    // Update due datetime based on interval
    dueAt = Vingo.DateTimeUtil.getSecondsSinceEpoch() +
        (interval! * 24 * 60 * 60).toInt();

    Vingo.PlatformUtil.log("[Sqlite] Updated: interval: $interval");
    Vingo.PlatformUtil.log("[Sqlite] Updated: iteration: $iteration");
    Vingo.PlatformUtil.log("[Sqlite] Updated: easinessFactor: $easinessFactor");
    Vingo.PlatformUtil.log("[Sqlite] Updated: dueAt: $dueAt");

    Vingo.PlatformUtil.log("""
    Updated:
      easiness_quality: $easinessQuality
      interval: $interval
      iteration: $iteration
      easiness_factor: $easinessFactor
      due_at: $dueAt
    """);
  }

  Future<int> scheduleInDays({
    required int days,
    bool resetStudyCycle = false,
    String databaseName = SqliteUtil.defaultDatabaseName,
  }) async {
    if (resetStudyCycle) {
      iteration = iteration1;
      interval = interval1;
      easinessFactor = easinessFactorEntryValue;
    }
    // 10 seconds shift to left is required for refresh stats to work properly
    this.dueAt = Vingo.DateTimeUtil.getSecondsSinceEpoch() +
        (days * 24 * 60 * 60).toInt() -
        10;
    this.updatedAt = Vingo.DateTimeUtil.getSecondsSinceEpoch();
    return await Card.updateCard(card: this, databaseName: databaseName);
  }

  static Future<dynamic> scheduleCardsByIdInDays({
    required List<int> cardIds,
    required int days,
    bool resetStudyCycle = false,
    String databaseName = SqliteUtil.defaultDatabaseName,
  }) async {
    final Sqflite.Database db = await SqliteUtil.getInstance(
      databaseName: databaseName,
    ).database;
    Sqflite.Batch batch = db.batch();
    int updatedAt = Vingo.DateTimeUtil.getSecondsSinceEpoch();
    // 10 seconds shift to left is required for refresh stats to work properly
    int dueAt = Vingo.DateTimeUtil.getSecondsSinceEpoch() +
        (days * 24 * 60 * 60).toInt() -
        10;
    int iteration = iteration1;
    double interval = interval1;
    double easinessFactor = easinessFactorEntryValue;
    cardIds.forEach((cardId) {
      String sql = "";
      if (resetStudyCycle) {
        sql = """
        UPDATE $tableName
        SET due_at = $dueAt, 
            iteration = $iteration, 
            interval = $interval,
            easiness_factor = $easinessFactor,
            updated_at = $updatedAt
        WHERE id = $cardId 
        """;
      } else {
        sql = """
        UPDATE $tableName
        SET due_at = $dueAt,
            updated_at = $updatedAt
        WHERE id = $cardId
        """;
      }
      batch.execute(sql);
    });
    return await batch.commit(noResult: true);
  }

  //----------------------------------------------------------------------------

  Future<int> insert({
    String databaseName = SqliteUtil.defaultDatabaseName,
  }) async {
    int cardId = await Card.insertCard(
      card: this,
      databaseName: databaseName,
    );
    this.id = cardId;
    return cardId;
  }

  Future<int> update({
    String databaseName = SqliteUtil.defaultDatabaseName,
  }) async {
    Vingo.PlatformUtil.log("Updating card: card:${this.toString()}");
    return await Card.updateCard(card: this, databaseName: databaseName);
  }

  Future<int> delete({
    String databaseName = SqliteUtil.defaultDatabaseName,
  }) async {
    if (this.id == null) return -1;
    Vingo.PlatformUtil.log("Deleting card: id=${this.id}");
    return await Card.deleteCard(cardId: this.id!, databaseName: databaseName);
  }

  Future<void> select({
    String databaseName = SqliteUtil.defaultDatabaseName,
  }) async {
    if (this.id == null) return;
    Card? card = await Card.selectCard(
      cardId: this.id!,
      databaseName: databaseName,
    );
    if (card == null) return;
    this.fromCard(card);
  }
}
