import 'dart:async';

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:feeds2imap_mobile/model/item.dart';
import 'package:feeds2imap_mobile/model/folder.dart';
import 'package:feeds2imap_mobile/model/url.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = new DatabaseHelper.internal();

  factory DatabaseHelper() => _instance;

  static Database _db;

  DatabaseHelper.internal();

  Future<Database> get db async {
    if (_db != null) {
      return _db;
    }
    _db = await initDb();
    await _initData();

    return _db;
  }

  initDb() async {
    String databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'items.db');

//    await deleteDatabase(path); // just for testing

    var db = await openDatabase(path, version: 1, onCreate: _onCreate);
    db.execute('PRAGMA foreign_keys = ON');

    return db;
  }

  Future _initData() async {
    var folders = await getAllFolders();

    if (folders.length == 0) {
      var urls = <String>[
        'http://blog.racket-lang.org/feeds/all.atom.xml',
        'http://blog.gonzih.me/index.xml',
        'https://www.archlinux.org/feeds/news/',
        'http://blog.fikesfarm.com/feed.xml',
        'http://blog.fsck.com/atom.xml',
        'https://blog.golang.org/feed.atom',
        'https://dave.cheney.net/category/golang/feed',
        'http://spf13.com/topics/golang/index.xml',
      ];

      var fid = await saveFolder(Folder('Main'));
      var fs = urls.map((u) => saveUrlIfNotExists(Url(u, fid)));

      return Future.wait(fs);
    }

    return Future.value(0);
  }

  void _onCreate(Database db, int newVersion) async {
    print('on create');
    await db.execute("""
        CREATE TABLE IF NOT EXISTS folders (
          folder_id INTEGER PRIMARY KEY,
          name TEXT NOT NULL
        )
    """);
    await db.execute("""
        CREATE TABLE IF NOT EXISTS urls (
          url_id INTEGER PRIMARY KEY,
          url TEXT NOT NULL,
          folder_id INTEGER NOT NULL,
          FOREIGN KEY(folder_id) REFERENCES folders(folder_id) ON DELETE CASCADE,
          CONSTRAINT url_unique UNIQUE (url)
        )
    """);
    await db.execute("""
        CREATE TABLE IF NOT EXISTS items (
          item_id INTEGER PRIMARY KEY,
          title TEXT NOT NULL,
          description TEXT NOT NULL,
          guid TEXT NOT NULL,
          link TEXT NOT NULL,
          author TEXT,
          feed_title TEXT,
          published_at INTEGER NOT NULL,
          url_id INTEGER NOT NULL,
          read BOOLEAN NOT NULL DEFAULT FALSE,
          archived BOOLEAN NOT NULL DEFAULT FALSE,
          FOREIGN KEY(url_id) REFERENCES urls(url_id) ON DELETE CASCADE,
          CONSTRAINT guid_unique UNIQUE (guid)
        )
    """);
  }

  Future<int> saveFolder(Folder folder) async {
    var dbClient = await db;
    var result = await dbClient.insert('folders', folder.toMap());

    return result;
  }

  Future<int> saveUrl(Url url) async {
    var dbClient = await db;
    var result = await dbClient.insert('urls', url.toMap());

    return result;
  }

  Future<int> saveUrlIfNotExists(Url url) async {
    var dbClient = await db;

    var existingOne =
        await dbClient.rawQuery('SELECT * FROM urls WHERE url = ?', [url.url]);

    if (existingOne.length == 0) {
      var result = await dbClient.insert('urls', url.toMap());
      return result;
    }

    return Future.value(0);
  }

  Future<int> saveItem(Item item) async {
    var dbClient = await db;
    var result = await dbClient.insert('items', item.toMap());

    return result;
  }

  Future<int> saveItemIfNotExists(Item item) async {
    print('Trying to save item with guid ${item.guid}');
    var existingItem = await getItemByGUID(item.guid);
    if (existingItem == null) {
      print('Item with guid ${item.guid} does not exist, saving the new one');
      var dbClient = await db;
      var result = await dbClient.insert('items', item.toMap());
      return result;
    }

    return Future(() => 0);
  }

  Future<List<Item>> getAllItems() async {
    var dbClient = await db;
    var result = await dbClient.rawQuery(
        'SELECT * FROM items WHERE archived = 0 ORDER BY published_at DESC');

    return result.map((map) => Item.fromMap(map)).toList();
  }

  Future<List<Item>> getItemsForAFolder(int folderID) async {
    var dbClient = await db;
    var result = await dbClient.rawQuery(
        'SELECT * FROM items WHERE archived = 0 AND url_id IN (SELECT url_id FROM urls WHERE folder_id = ?) ORDER BY published_at DESC',
        [folderID]);

    return result.map((map) => Item.fromMap(map)).toList();
  }

  Future<int> getCount() async {
    var dbClient = await db;
    return Sqflite.firstIntValue(
        await dbClient.rawQuery('SELECT COUNT(*) FROM items'));
  }

  Future<Item> getItem(int id) async {
    var dbClient = await db;
    var result =
        await dbClient.rawQuery('SELECT * FROM items WHERE item_id = ?', [id]);

    if (result.length > 0) {
      return new Item.fromMap(result.first);
    }

    return null;
  }

  Future<Item> getItemByGUID(String guid) async {
    var dbClient = await db;
    var result =
        await dbClient.rawQuery('SELECT * FROM items WHERE guid = ?', [guid]);

    if (result.length > 0) {
      return new Item.fromMap(result.first);
    }

    return null;
  }

  Future<int> deleteItem(int id) async {
    var dbClient = await db;
    return await dbClient
        .rawDelete('DELETE FROM items WHERE item_id = ?', [id]);
  }

  Future<int> deleteUrl(int id) async {
    var dbClient = await db;
    return await dbClient.rawDelete('DELETE FROM urls WHERE url_id = ?', [id]);
  }

  Future<int> updateItem(Item item) async {
    var dbClient = await db;
    return await dbClient.update('items', item.toMap(),
        where: "itemID = ?", whereArgs: [item.itemID]);
  }

  Future<int> markItemAsRead(Item item) async {
    var dbClient = await db;
    return await dbClient.rawUpdate(
        'UPDATE items SET read = 1 WHERE item_id = ?', [item.itemID]);
  }

  Future<int> archiveItem(Item item) async {
    var dbClient = await db;
    return await dbClient.rawUpdate(
        'UPDATE items SET arhived = 1 WHERE item_id = ?', [item.itemID]);
  }

  Future<List<Folder>> getAllFolders() async {
    var dbClient = await db;
    var result = await dbClient.rawQuery('SELECT * FROM folders');

    return result.map((map) => Folder.fromMap(map)).toList();
  }

  Future<List<Url>> getAllUrls() async {
    var dbClient = await db;
    var result = await dbClient.rawQuery('SELECT * FROM urls');

    return result.map((map) => Url.fromMap(map)).toList();
  }

  Future<List<Url>> getUrlsForFolder(int folderID) async {
    var dbClient = await db;
    var result = await dbClient
        .rawQuery('SELECT * FROM urls WHERE folder_id = ?', [folderID]);

    return result.map((map) => Url.fromMap(map)).toList();
  }

  Future close() async {
    var dbClient = await db;
    return dbClient.close();
  }
}
