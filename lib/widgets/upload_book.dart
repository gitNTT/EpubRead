import 'dart:async';
import 'dart:io';
import 'package:epub_app/models/book.dart';
import 'package:epub_app/models/book_saved_data/book_saved_data.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

enum Stage {
  idle,
  download,
  processing,
  error,
  done,
}

class BookDownloaderInterfaceGetter {}

class BookDownloaderInterfaceDownloader
    implements BookDownloaderInterfaceGetter {
  final BookIdentifier bookIdentifier;

  BookDownloaderInterfaceDownloader({
    required this.bookIdentifier,
  });
}

class BookDownloaderInterfaceBytes implements BookDownloaderInterfaceGetter {
  final List<int> bookFileBytes;

  BookDownloaderInterfaceBytes({
    required this.bookFileBytes,
  });
}

class BookDownloaderInterface extends StatefulWidget {
  const BookDownloaderInterface({
    Key? key,
    this.description,
    required this.getter,
    required this.booksDirectory,
    this.onDone,
  }) : super(key: key);

  final String? description;
  final BookDownloaderInterfaceGetter getter;
  final Directory booksDirectory;
  final void Function()? onDone;

  @override
  _BookDownloaderInterfaceState createState() =>
      _BookDownloaderInterfaceState();
}

class _BookDownloaderInterfaceState extends State<BookDownloaderInterface> {
  //final Client httpClient = Client();
  final uuid = const Uuid();
  double? downloadProgress;
  Stage stage = Stage.idle;

  @override
  void initState() {
    super.initState();
    begin();
  }

  Future<void> begin() async {
    final status = await Permission.storage.status;
    switch (status) {
      case PermissionStatus.denied:
        //print("loi 1--------------------------");
        await Permission.storage.request();
        return;
      case PermissionStatus.granted:
        break;
      case PermissionStatus.restricted:
       //print("loi 2--------------------------");
      case PermissionStatus.limited:
        //print("loi 3--------------------------");
      case PermissionStatus.permanentlyDenied:
        //print("loi 4--------------------------");

        setState(() {
          stage = Stage.error;
        });

        return;
    }

    setState(() {
      stage = Stage.download;
      downloadProgress = 0;
    });

    List<int>? epubBytes;

    epubBytes = (widget.getter as BookDownloaderInterfaceBytes).bookFileBytes;

    if (epubBytes == null) {
      setState(() {
        stage = Stage.error;
      });
      return;
    }

    // await File("${widget.booksDirectory.path}/test.epub")
    //     .writeAsBytes(epubBytes);

    setState(() {
      stage = Stage.processing;
      downloadProgress = 0.5;
    });

    await BookSavedData.writeFromEpub(
      epubBytes: epubBytes,
      description: widget.description,
      directory: Directory(
        p.join(widget.booksDirectory.path, uuid.v4()),
      ),
    );

    setState(() {
      stage = Stage.done;
    });

    widget.onDone?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (stage == Stage.download) const Text("Đang tải lên..."),
        if (stage == Stage.processing) const Text("Đang xử lý..."),
        if (stage == Stage.error) const Text("Lỗi."),
        if (stage == Stage.done) const Text("Thành công"),
        Visibility(
          visible: stage == Stage.download || stage == Stage.processing,
          child: LinearProgressIndicator(
            value: downloadProgress,
          ),
        )
      ],
    );
  }
}
