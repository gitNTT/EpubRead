import 'dart:io';
import 'package:epub_app/widgets/books_viewer.dart';
import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';
import '../managers/settings_manager.dart';
import '../models/book.dart';
import '../widgets/add_book_to_shelf.dart';
import '../widgets/book_3d.dart';
import '../widgets/book_shelf.dart';
import 'book_info.dart';
import 'book_info_settings.dart';

class CustomPageRoute extends MaterialPageRoute {
  @override
  Duration get transitionDuration => const Duration(milliseconds: 1000);

  CustomPageRoute({builder}) : super(builder: builder);
}

class Library extends StatefulWidget {
  const Library({
    Key? key,
    required this.books,
    required this.shelves,
    required this.onCreateShelf,
    required this.onUpdateShelf,
    required this.onDeleteShelf,
    required this.onReadBook,
    required this.onDeleteBook,
    required this.onImageChanged,
    required this.settingsManager,
    required this.onBookInfoChanged,
  }) : super(key: key);

  final List<Book> books;
  final List<Shelf> shelves;
  final void Function(String name) onCreateShelf;
  final void Function(Shelf shelf, String name) onUpdateShelf;
  final void Function(Shelf shelf) onDeleteShelf;
  final void Function(Book book) onReadBook;
  final void Function(Book book) onDeleteBook;
  final void Function(Book book, File file) onImageChanged;
  final void Function(
          Book book, String name, String authors, String description)
      onBookInfoChanged;
  final SettingsManager settingsManager;

  @override
  _LibraryState createState() => _LibraryState();
}

class _LibraryState extends State<Library> with SingleTickerProviderStateMixin {
  late TabController tabController;
  TextEditingController newShelfController = TextEditingController();

  @override
  void initState() {
    tabController = TabController(
      length: 2,
      initialIndex: 0,
      vsync: this,
    );
    super.initState();
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
          onPressRead: () => widget.onReadBook(book),
          onPressSettings: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => BookInfoSettings(
                  book: book,
                  onBookChanged:(name, authors, description) {
                    widget.onBookInfoChanged(book,name,authors,description);
                  },
                  onImageChanged: (file) {
                    widget.onImageChanged(book, file);
                  },
                  onDelete: () {
                    widget.onDeleteBook(book);
                    Navigator.of(context)
                      ..pop()
                      ..pop();
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void onPressAddShelf() {
    newShelfController.text = "";
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Kệ sách mới"),
          content: TextField(
            controller: newShelfController,
            decoration: const InputDecoration(
              labelText: "Tên kệ sách",
            ),
          ),
          actions: [
            SizedBox(
              width: 80,
              height: 40,
              child: TextButton(
                child: const Text("Thêm"),
                onPressed: () {
                  widget.onCreateShelf(newShelfController.text);
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  void onPressDeleteShelf(Shelf shelf) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Xóa kệ sách \"${shelf.name}\"?"),
          actions: [
            SizedBox(
              width: 100,
              height: 40,
              child: TextButton(
                style: TextButton.styleFrom(
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(5)),
                  ),
                ),
                child: const Text("Xóa"),
                onPressed: () {
                  widget.onDeleteShelf(shelf);
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  void onUpdateNameBookShelves(Shelf shelf) {
    newShelfController.text = shelf.name;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Cập nhật kệ sách"),
          content: TextField(
            controller: newShelfController,
            decoration: const InputDecoration(
              labelText: "Tên kệ sách",
            ),
          ),
          actions: [
            SizedBox(
              width: 80,
              height: 40,
              child: TextButton(
                child: const Text("Cập nhật"),
                onPressed: () {
                  widget.onUpdateShelf(shelf, newShelfController.text);
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        );
      },
    );
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

  @override
  Widget build(BuildContext context) {
    final books3dData = {
      for (var book in widget.books) book: Book3DData.fromSavedData(book)
    };

    return Scaffold(
      body: Column(
        children: [
          SizedBox(
            child: TabBar(
              controller: tabController,
              labelStyle: Theme.of(context)
                  .textTheme
                  .titleSmall!
                  .copyWith(fontSize: 17),
              tabs: const [
                Tab(
                  //text: "Tất cả",
                  icon: Icon(Icons.menu_book),
                ),
                Tab(
                  //text: "Kệ sách",
                  icon: Icon(Icons.shelves),
                ),
              ],
            ),
          ),
          10.heightBox,
          Expanded(
            child: ScrollConfiguration(
              behavior:
                  ScrollConfiguration.of(context).copyWith(scrollbars: false),
              child: TabBarView(
                controller: tabController,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: BooksViewer(
                      settingsManager: widget.settingsManager,
                      books: widget.books,
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
                      onLongPressBook: onChangeBookShelves,
                    ),
                  ),
                  Scaffold(
                    floatingActionButton: FloatingActionButton(
                      onPressed: onPressAddShelf,
                      child: const Icon(Icons.add_outlined),
                    ),
                    body: ListView.separated(
                      scrollDirection: Axis.vertical,
                      itemCount: widget.shelves.length + 1,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        if (index == widget.shelves.length) {
                          return const SizedBox(height: 80);
                        }
                        final shelf = widget.shelves[index];
                        return BookShelf(
                          height: 200,
                          shelf: shelf,
                          onBookSelected: onBookSelected,
                          onPressDelete: () => onPressDeleteShelf(shelf),
                          onChangeBookShelves: onChangeBookShelves,
                          onUpdateNameBookShelves: () =>
                              onUpdateNameBookShelves(shelf),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
