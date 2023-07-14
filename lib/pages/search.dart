import 'package:epub_app/widgets/book_3d.dart';
import 'package:epub_app/widgets/getToastCustom.dart';

import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../managers/settings_manager.dart';
import '../models/book.dart';
import '../widgets/add_book_to_shelf.dart';
import '../widgets/books_viewer.dart';
import 'book_info.dart';
import 'book_info_settings.dart';
import 'book_player.dart';

class Search extends StatefulWidget {
  const Search({
    Key? key,
    required this.settingsManager,
    required this.shelves,
  }) : super(key: key);

  final SettingsManager settingsManager;
  final List<Shelf> shelves;

  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  List<Book> searchResults = [];
  bool hasSearched = false;
  final translatorModelManager = OnDeviceTranslatorModelManager();

  @override
  void initState() {
    super.initState();
  }

  // Future<List<Book>> searchBooksByName(String name) async {
  //   final allBooks = await widget.settingsManager.loadAllBooks();
  //   final filteredBooks = allBooks
  //       .where((book) => book.name.toLowerCase().contains(name.toLowerCase()))
  //       .toList();
  //   return filteredBooks;
  // }

  Future<List<Book>> searchBooksByNameAndAuthor(String query) async {
    final allBooks = await widget.settingsManager.loadAllBooks();

    final filteredBooks = allBooks.where((book) {
      final lowerCaseQuery = query.toLowerCase();
      final lowerCaseName = book.name.toLowerCase();
      final lowerCaseAuthors = book.authors.map((author) => author.toLowerCase()).toList();

      return lowerCaseName.contains(lowerCaseQuery) ||
          lowerCaseAuthors.any((author) => author.contains(lowerCaseQuery));
    }).toList();

    return filteredBooks;
  }

  void onChangeBookShelves(Book book) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AddBookToShelf(
          shelves: widget.shelves,
          book: book,
          onChange: (shelf, selected) {
            if (selected) {
              shelf.books.add(book);
            } else {
              shelf.books.removeWhere(
                (shelfBook) =>
                    book.savedData!.bookId == shelfBook.savedData!.bookId,
              );
            }
            shelf.updateConfig();
          },
        );
      },
    );

    setState(() {});
  }

  void onBookSelected(
    Book book,
    Book3DData book3dData, {
    BookInfoPreviousBookData? previousBookData,
  }) {
    Navigator.push(
      context,
      createBookInfoPageRoute(
        BookInfo(
          wordsPerPage: widget.settingsManager.config.wordsPerPage,
          book: book,
          book3dData: book3dData,
          previousBookData: previousBookData,
          onPressAddToShelf: () => onChangeBookShelves(book),
          onPressRead: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BookPlayer(
                  translatorModelManager: translatorModelManager,
                  initialStyle: book.savedData!.data.styleProperties,
                  book: book,
                  bookOptions: BookOptions(
                    BookThemeData(
                      backgroundColor: Colors.blueGrey[900]!,
                      textColor: Colors.grey[400]!,
                    ),
                  ),
                  settingsManager: widget.settingsManager,
                  wordsPerPage: widget.settingsManager.config.wordsPerPage,
                ),
              ),
            );
          },
          onPressSettings: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => BookInfoSettings(
                  book: book,
                  onBookChanged:(name, authors, description) async{
                    book.savedData!.data.name = name;
                    book.savedData!.data.authors = authors.split(', ');
                    book.savedData!.data.description = description;
                    await book.savedData!.saveData();
                    getCustomToast.show("Cập nhật sách thành công", context);
                    Phoenix.rebirth(context);
                  },
                  onImageChanged: (newImageFile) async {
                    await newImageFile.copy(book.savedData!.coverFile.path);

                    final decodedImage = await decodeImageFromList(
                      newImageFile.readAsBytesSync(),
                    );

                    book.savedData!.data.coverSize = Size(
                      decodedImage.width.toDouble(),
                      decodedImage.height.toDouble(),
                    );
                    await book.savedData!.saveData();
                    getCustomToast.show("Cập nhật sách thành công", context);
                    Phoenix.rebirth(context);
                  },
                  onDelete: () async {
                    await widget.settingsManager
                        .deleteBook(book.savedData!.bookId);
                    searchResults.remove(book);
                    getCustomToast.show("Xóa sách thành công", context);
                    Navigator.of(context)
                      ..pop()
                      ..pop();
                    setState(() {});
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final books3dData = {
      for (var book in searchResults) book: Book3DData.fromSavedData(book)
    };

    return Scaffold(
      body: Container(
        padding: const EdgeInsets.only(
          left: 10,
          right: 10,
          top: 10,
        ),
        color: Theme.of(context).backgroundColor,
        child: Column(
          children: [
            TextField(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Tìm',
              ),
              onSubmitted: (searchQuery) async {
                final trimmedQuery = searchQuery.trim();
                if (trimmedQuery.isNotEmpty) {
                  searchResults = await searchBooksByNameAndAuthor(trimmedQuery);
                  hasSearched = true;
                } else {
                  searchResults = [];
                  hasSearched = false;
                }
                setState(() {});
              },
            ),
            Expanded(
              child: !hasSearched
                  ? Container()
                  : searchResults.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.search),
                              Text(
                                'Không có kết quả',
                                style: TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        )
                      : BooksViewer(
                          settingsManager: widget.settingsManager,
                          books: searchResults,
                          canSort: false,
                          onLongPressBook: onChangeBookShelves,
                          books3dData: books3dData,
                          onPressBook: (book) => onBookSelected(
                            book,
                            books3dData[book]!,
                            previousBookData: BookInfoPreviousBookData(
                              heroTag: "book3d-${book.savedData!.bookId}",
                              rotateY: 0,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
