import 'dart:io';
import 'package:epub_app/pages/home_settings.dart';
import 'package:epub_app/widgets/getToastCustom.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';
import 'package:http/http.dart';
import '../constants/strings.dart';
import '../managers/settings_manager.dart';
import '../models/book.dart';
import '../widgets/clean_app_bar.dart';
import 'book_reader.dart';
import '../widgets/upload_book.dart';
import 'library.dart';
import 'search.dart';

class Home extends StatefulWidget {
  const Home({Key? key, required this.settingsManager}) : super(key: key);

  final SettingsManager settingsManager;

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with TickerProviderStateMixin {
  final httpClient = Client();
  late AnimationController animationController;
  late Animation<double> opacityAnimation;
  int pageIndex = 0;
  final translatorModelManager = OnDeviceTranslatorModelManager();

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    opacityAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(animationController);

    animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDarkMode = brightness == Brightness.dark;

    final pages = [
      FutureBuilder(
        future: Future.wait([
          widget.settingsManager.loadAllBooks(),
          widget.settingsManager.loadShelves(),
        ]),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final books = (snapshot.data as List)[0] as List<Book>;
            final shelves = (snapshot.data as List)[1] as List<Shelf>;
            return Library(
              settingsManager: widget.settingsManager,
              onImageChanged: (book, newImageFile) async {
                await newImageFile.copy(book.savedData!.coverFile.path);

                final decodedImage = await decodeImageFromList(
                  newImageFile.readAsBytesSync(),
                );
                book.savedData!.data.coverSize = Size(
                  decodedImage.width.toDouble(),
                  decodedImage.height.toDouble(),
                );
                await book.savedData!.saveData();
                getCustomToast.show("Cập nhật ảnh bìa thành công", context);
                Phoenix.rebirth(context);
              },
              onBookInfoChanged: (book, name, authors, description) async {
                book.savedData!.data.name = name;
                book.savedData!.data.authors = authors.split(', ');
                book.savedData!.data.description = description;
                await book.savedData!.saveData();
                getCustomToast.show("Cập nhật sách thành công", context);
                Phoenix.rebirth(context);
              },
              onDeleteBook: (book) async {
                await widget.settingsManager.deleteBook(book.savedData!.bookId);
                getCustomToast.show('Xóa sách thành công', context);
                setState(() {});
              },
              books: books,
              shelves: shelves,
              onCreateShelf: (String name) async {
                int check =
                    await widget.settingsManager.createShelf(name.trim());
                if (check == 1) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(nameShelfEmpty),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                } else if (check == 2) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(nameShelfExists),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Đã thêm kệ"$name"'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  setState(() {});
                }
              },
              onUpdateShelf: (shelf, String name) async {
                String oldName = shelf.name;
                if (name.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(nameShelfEmpty),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                } else if (shelf.name.trim() == name.trim()) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Tên kệ sách không có thay đổi"),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                } else if (await shelf.updateShelf(name.trim())) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Đã cập nhật kệ"$oldName" sang "$name"'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  setState(() {});
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(nameShelfExists),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              onDeleteShelf: (shelf) async {
                await shelf.deleteConfig();
                setState(() {});

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('$deleteShelf"${shelf.name}"'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              onReadBook: (book) {
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
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      FutureBuilder(
        future: Future.wait([
          widget.settingsManager.loadShelves(),
        ]),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final shelves = (snapshot.data as List)[0] as List<Shelf>;
            return Search(
              shelves: shelves,
              settingsManager: widget.settingsManager,
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    ];

    return Scaffold(
      appBar: CleanAppBar(
        gradient: isDarkMode
            ? const LinearGradient(
                colors: [
                  Colors.black12,
                  Colors.black12,
                ],
              )
            : const LinearGradient(
                colors: [
                  Colors.blueAccent,
                  Colors.lightBlue,
                ],
              ),
        title: pageIndex == 0 ? library : search,
        canBack: false,
        actions: [
          IconButton(
            splashRadius: 20,
            icon: const Icon(
              Icons.add_outlined,
            ),
            onPressed: () async {
              try {
                final files = (await FilePicker.platform.pickFiles(
                  type: FileType.custom,
                  allowedExtensions: ['epub'],
                ))
                    ?.files;
                if (files?.isEmpty ?? true) {
                  return;
                }

                final getter = BookDownloaderInterfaceBytes(
                  bookFileBytes: await File(files!.single.path!).readAsBytes(),
                );


                await showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      content: BookDownloaderInterface(
                        getter: getter,
                        booksDirectory: widget.settingsManager.directory,
                        onDone: () {
                          Navigator.of(context).pop();
                          setState(() {});
                        },
                      ),
                    );
                  },
                );

                getCustomToast.show("Thêm sách thành công", context);
              } catch (e) {
                getCustomToast.show(
                    "Vui lòng cấp quyền truy cập bộ nhớ !", context);
              }
            },
          ),
          IconButton(
            splashRadius: 20,
            icon: const Icon(
              Icons.settings_outlined,
            ),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HomeSettings(
                    settingsManager: widget.settingsManager,
                  ),
                ),
              );
              setState(() {});
            },
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: animationController,
        builder: (context, child) {
          return Opacity(
            opacity: opacityAnimation.value,
            child: child,
          );
        },
        child: pages[pageIndex],
      ),
      bottomNavigationBar: NavigationBarTheme(
        data: Theme.of(context).navigationBarTheme,
        child: NavigationBar(
          selectedIndex: pageIndex,
          onDestinationSelected: (index) {
            setState(() {
              pageIndex = index;
            });
            animationController.reset();
            animationController.forward();
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.library_books),
              label: "Thư viện",
            ),
            NavigationDestination(
              icon: Icon(Icons.search),
              label: "Tìm kiếm",
            ),
          ],
        ),
      ),
    );
  }
}
