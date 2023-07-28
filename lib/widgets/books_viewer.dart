import 'package:epub_app/widgets/book_3d.dart';
import 'package:flutter/material.dart';
import 'package:responsive_grid_list/responsive_grid_list.dart';
import 'package:velocity_x/velocity_x.dart';
import '../managers/settings_manager.dart';
import '../models/book.dart';
import '../utils/sortVietnamese.dart';

enum ViewType {
  grid,
  list,
}

enum SortType {
  title,
  author,
}

final _viewTypeStrings = {
  ViewType.grid: "Lưới",
  ViewType.list: "Danh sách",
};

final _sortTypeStrings = {
  SortType.title: 'Tiêu đề',
  SortType.author: 'Tác giả',
};

class BooksViewer extends StatefulWidget {
  const BooksViewer({
    Key? key,
    required this.books,
    this.books3dData,
    bool? canSort,
    this.onPressBook,
    this.onLongPressBook,
    this.settingsManager,
  })  : canSort = canSort ?? true,
        super(key: key);

  final List<Book> books;
  final Map<Book, Book3DData>? books3dData;
  final bool canSort;
  final void Function(Book book)? onPressBook;
  final void Function(Book book)? onLongPressBook;
  final SettingsManager? settingsManager;

  @override
  _BooksViewerState createState() => _BooksViewerState();
}

class _BooksViewerState extends State<BooksViewer> {
  late ViewType viewType;
  late SortType sortType = SortType.title;

  @override
  Widget build(BuildContext context) {
    late Widget view;
    final List<Book> books = [...widget.books];

    viewType = widget.settingsManager?.config.viewType ?? ViewType.list;
    sortType = widget.settingsManager?.config.sortType ?? SortType.title;

    if (widget.canSort) {
      books.sort((a, b) {
        switch (sortType) {
          case SortType.title:
            return VietnameseComparator.compare(a.name, b.name);
          case SortType.author:
            return VietnameseComparator.compare(a.getAuthors(), b.getAuthors());
        }
      });
    }

    List<Widget> bookImagesGrid = books.map((book) {
      return book.coverProvider == null
          ? const Text("No image")
          : widget.books3dData == null
              ? Image(
                  image: book.coverProvider!,
                  filterQuality: FilterQuality.medium,
                  fit: BoxFit.cover,
                )
              : Hero(
                  tag: "book3d-${book.savedData?.bookId ?? book.name}",
                  child: Book3D(
                    book3dData: widget.books3dData![book]!,
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
    }).toList();

    List<Widget> bookImages = books.map((book) {
      return book.coverProvider == null
          ? const Text("No image")
          : SizedBox(
              width: 110,
              height: 170,
              child: book.coverProvider == null
                  ? const Text("No image")
                  : widget.books3dData == null
                      ? Image(
                          image: book.coverProvider!,
                          filterQuality: FilterQuality.high,
                          fit: BoxFit.fill,
                        )
                      : Hero(
                          tag: "book3d-${book.savedData?.bookId ?? book.name}",
                          child: Book3D(
                            book3dData: widget.books3dData![book]!,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
            );
    }).toList();

    switch (viewType) {
      case ViewType.grid:
        view = ResponsiveGridList(
          minItemsPerRow: 3,
          horizontalGridSpacing: 0,
          verticalGridMargin: 0,
          minItemWidth: 150,
          children: books.asMap().entries.map(
            (entry) {
              final index = entry.key;
              final book = entry.value;
              return InkWell(
                onTap: () => widget.onPressBook?.call(book),
                onLongPress: () => widget.onLongPressBook?.call(book),
                borderRadius: BorderRadius.circular(4),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  child: book.coverProvider == null
                      ? Text(book.name)
                      : Column(
                          children: [
                            SizedBox(
                              width: 150,
                              height: 170,
                              child: Center(child: bookImages[index]),
                            ),
                            const SizedBox(
                              height: 4,
                            ),
                            Text(
                              book.name,
                              maxLines: 2,
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                ),
              );
            },
          ).toList(),
        );
        break;
      case ViewType.list:
        view = ListView.builder(
          itemCount: books.length,
          itemBuilder: (context, index) {
            final book = books[index];
            return InkWell(
              onTap: () => widget.onPressBook?.call(book),
              onLongPress: () => widget.onLongPressBook?.call(book),
              borderRadius: BorderRadius.circular(4),
              child: Container(
                padding: const EdgeInsets.all(8),
                height: 80,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    bookImagesGrid[index],
                    const SizedBox(width: 10),
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            book.name,
                            maxLines: 2,
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall!
                                .merge(const TextStyle(
                                    fontWeight: FontWeight.bold)),
                          ),
                          Text(
                            book.getAuthors(),
                            style: Theme.of(context).textTheme.bodySmall,
                            maxLines: 1,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
        break;
    }

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (widget.canSort)
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(5.0),
                    child: Text("Sắp xếp", style: TextStyle(fontSize: 15)),
                  ),
                  InkWell(
                    borderRadius: BorderRadius.circular(4),
                    onTap: () {
                      setState(() {
                        sortType = SortType.values[
                            (sortType.index + 1) % SortType.values.length];
                      });

                      if (widget.settingsManager == null) {
                        return;
                      }

                      widget.settingsManager!.config.sortType = sortType;
                      widget.settingsManager!.saveConfig();
                    },
                    child: Text("${_sortTypeStrings[sortType]}",
                        style: const TextStyle(fontSize: 15)),
                  ),
                ],
              ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Padding(
                  padding: EdgeInsets.all(5.0),
                  child: Text(
                    "Xem kiểu",
                    style: TextStyle(fontSize: 15),
                  ),
                ),
                InkWell(
                  borderRadius: BorderRadius.circular(4),
                  onTap: () {
                    setState(() {
                      viewType = ViewType.values[
                          (viewType.index + 1) % ViewType.values.length];
                    });
                    if (widget.settingsManager == null) {
                      return;
                    }

                    widget.settingsManager!.config.viewType = viewType;
                    widget.settingsManager!.saveConfig();
                  },
                  child: Text(
                    "${_viewTypeStrings[viewType]}",
                    style: const TextStyle(fontSize: 15),
                  ),
                ),
              ],
            ),
          ],
        ),
        10.heightBox,
        Expanded(child: view),
      ],
    );
  }
}
