import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';
import 'package:path/path.dart' as p;
import 'dart:convert';
import 'package:uuid/uuid.dart';
import '../models/book.dart';
import '../models/book_saved_data/book_saved_data.dart';
import '../utils/enum_from_index.dart';
import '../widgets/books_viewer.dart';

class ConfigData {
  SortType sortType;
  ViewType viewType;
  double wordsPerPage;
  ThemeMode themeMode;
  TranslateLanguage translationFromLanguage;
  TranslateLanguage translationToLanguage;
  bool dragPageAnimation;
  bool nextPageOnShake;

  ConfigData({
    required this.sortType,
    required this.viewType,
    required this.wordsPerPage,
    required this.themeMode,
    required this.translationFromLanguage,
    required this.translationToLanguage,
    required this.dragPageAnimation,
    required this.nextPageOnShake,
  });

  factory ConfigData.fromJson(Map<String, dynamic> json) {
    return ConfigData(
      sortType: enumFromIndex(SortType.values, json['sortType']),
      viewType: enumFromIndex(ViewType.values, json['viewType']),
      wordsPerPage: json['wordsPerPage'] as double,
      themeMode: ThemeMode.values[json['themeMode']],
      translationFromLanguage:
          TranslateLanguage.values[json['translationFromLanguage']],
      translationToLanguage:
          TranslateLanguage.values[json['translationToLanguage']],
      dragPageAnimation: json['dragPageAnimation'] as bool? ?? true,
      nextPageOnShake: json['nextPageOnShake'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sortType': sortType.index,
      'viewType': viewType.index,
      'wordsPerPage': wordsPerPage,
      'themeMode': themeMode.index,
      'translationFromLanguage': translationFromLanguage.index,
      'translationToLanguage': translationToLanguage.index,
      'dragPageAnimation': dragPageAnimation,
      'nextPageOnShake': nextPageOnShake,
    };
  }
}

class SettingsManager {
  final Directory directory;
  final File _shelvesConfigFile;
  final File _configFile;
  late final ConfigData config;
  final _uuid = const Uuid();
  final _defaultConfigFile = ConfigData(
    sortType: SortType.title,
    viewType: ViewType.list,
    wordsPerPage: 250,
    themeMode: ThemeMode.system,
    translationFromLanguage: TranslateLanguage.english,
    translationToLanguage: TranslateLanguage.english,
    dragPageAnimation: true,
    nextPageOnShake: false,
  );

  SettingsManager({
    required this.directory,
  })  : _shelvesConfigFile = File(p.join(directory.path, "shelves.json")),
        _configFile = File(p.join(directory.path, "config.json"));

  Future<void> initialize() async {
    await directory.create();
    if (await _shelvesConfigFile.exists()) {
      final content = await _shelvesConfigFile.readAsString();
      try {
        json.decode(content);
      } on FormatException {
        await _shelvesConfigFile.writeAsString(jsonEncode([]));
      }
    } else {
      await _shelvesConfigFile.writeAsString(jsonEncode([]));
    }

    if (await _configFile.exists()) {
      final content = await _configFile.readAsString();
      try {
        json.decode(content);
      } on FormatException {
        await _configFile.writeAsString(jsonEncode(_defaultConfigFile));
      }
    } else {
      await _configFile.writeAsString(jsonEncode(_defaultConfigFile));
    }

    config = ConfigData.fromJson(
      json.decode(await _configFile.readAsString()),
    );
  }

  Future<void> saveConfig() async {
    await _configFile.writeAsString(jsonEncode(config));
  }

  Future<void> deleteBook(String bookId) async {
    final bookDirectory = Directory(p.join(directory.path, bookId));
    await bookDirectory.delete(recursive: true);

    final shelvesConfig = await getShelvesConfig();
    for (var config in shelvesConfig) {
      config.bookIds.removeWhere((id) => id == bookId);
    }
    setShelvesConfig(shelvesConfig);
  }

  Future<List<Book>> loadAllBooks() async {
    final List<Directory> bookDirectories =
        (await directory.list().toList()).whereType<Directory>().toList();

    final books = await Future.wait(bookDirectories.map(
      (bookDirectory) async {
        try {
          return (await BookSavedData.load(bookDirectory))
              .toBook(config.wordsPerPage);
        } catch (e) {
          await deleteBook(bookDirectory.uri.pathSegments.last);
          return null;
        }
      },
    ));

    return books.whereType<Book>().toList();
  }

  Future<Book> loadBookFromId(String bookId) async {
    final bookDirectory = p.join(directory.path, bookId);
    return (await BookSavedData.load(Directory(bookDirectory)))
        .toBook(config.wordsPerPage);
  }

  Future<int> createShelf(String name, {List<String>? initialBookIds}) async {
    if (name.trim().isEmpty) {
      return 1;
    }
    final shelvesConfig = await getShelvesConfig();
    final existingShelves = shelvesConfig.where((shelfConfig) => shelfConfig.name == name).toList();
    if (existingShelves.isNotEmpty) {
      return 2; // Shelf name already exists
    }

    final newShelfConfig = ShelfConfig(
      id: _uuid.v4(),
      name: name,
      bookIds: initialBookIds ?? [],
    );
    await setShelvesConfig(
      [...shelvesConfig, newShelfConfig],
    );
    return 3;
  }

  Future<void> updateShelfConfig(Shelf shelf) async {
    final shelvesConfig = await getShelvesConfig();
    final shelfConfig = shelvesConfig.firstWhere((conf) => conf.id == shelf.id);
    shelfConfig.name = shelf.name;
    shelfConfig.bookIds = shelf.books.map((book) => book.savedData!.bookId).toList();

    await setShelvesConfig(shelvesConfig);
  }

  Future<List<ShelfConfig>> getShelvesConfig() async {
    final data = await _shelvesConfigFile.readAsString();

    return (await json.decode(data) as List)
        .map((entry) => ShelfConfig.fromJson(entry))
        .toList();
  }

  Future<void> setShelvesConfig(List<ShelfConfig> shelfConfigs) async {
    await _shelvesConfigFile.writeAsString(
      jsonEncode(
          shelfConfigs.map((shelfConfig) => shelfConfig.toJson()).toList()),
    );
  }

  Future<List<Shelf>> loadShelves() async {
    final shelfConfigs = await getShelvesConfig();

    return await Future.wait(shelfConfigs.map((shelfConfig) async {
      return await Shelf.fromConfig(this, shelfConfig);
    }));
  }
}

class Shelf {
  final SettingsManager settingsManager;
  final String id;
  String name;
  List<Book> books;

  Shelf({
    required this.settingsManager,
    required this.id,
    required this.name,
    required this.books,
  });

  Future<void> deleteConfig() async {
    final shelvesConfig = await settingsManager.getShelvesConfig();
    shelvesConfig.removeWhere((conf) => conf.id == id);
    await settingsManager.setShelvesConfig(shelvesConfig);
  }

  Future<void> updateConfig() async {
    final shelvesConfig = await settingsManager.getShelvesConfig();

    final shelfConfig = shelvesConfig.firstWhere((conf) => conf.id == id);
    shelfConfig.name = name;
    shelfConfig.bookIds = books.map((book) => book.savedData!.bookId).toList();

    await settingsManager.setShelvesConfig(shelvesConfig);
  }

  static Future<Shelf> fromConfig(
      SettingsManager settingsManager, ShelfConfig shelfConfig) async {
    return Shelf(
      settingsManager: settingsManager,
      id: shelfConfig.id,
      name: shelfConfig.name,
      books: await Future.wait(shelfConfig.bookIds.map((bookId) async {
        return await settingsManager.loadBookFromId(bookId);
      })),
    );
  }

  Future<bool> updateShelf(String newName) async {
    final shelvesConfig = await settingsManager.getShelvesConfig();

    final existingShelves = shelvesConfig.where((shelfConfig) => shelfConfig.name == newName).toList();
    if (existingShelves.isNotEmpty) {
      return false; // Shelf name already exists
    }
    name = newName;
    await settingsManager.updateShelfConfig(this);
    return true; // Shelf updated successfully
  }


}

class ShelfConfig {
  final String id;
  String name;
  List<String> bookIds;

  ShelfConfig({
    required this.id,
    required this.name,
    required this.bookIds,
  });

  ShelfConfig.fromJson(Map<String, dynamic> json)
      : id = json["id"],
        name = json["name"],
        bookIds =
            json["bookIds"].map<String>((name) => name.toString()).toList();

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'bookIds': bookIds,
      };
}
