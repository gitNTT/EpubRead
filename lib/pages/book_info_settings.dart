import 'dart:io';
import 'package:epub_app/widgets/clean_app_bar.dart';
import 'package:epub_app/widgets/getToastCustom.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';

import '../models/book.dart';
import '../widgets/confirm_popup.dart';

class BookInfoSettings extends StatefulWidget {
  const BookInfoSettings({
    Key? key,
    required this.book,
    required this.onImageChanged,
    required this.onBookChanged,
    required this.onDelete,
  }) : super(key: key);

  final Book book;
  final void Function() onDelete;
  final void Function(File) onImageChanged;
  final void Function(String, String, String) onBookChanged;

  @override
  _BookInfoSettingsState createState() => _BookInfoSettingsState();
}

class _BookInfoSettingsState extends State<BookInfoSettings> {
  final TextEditingController _bookName = TextEditingController();
  final TextEditingController _bookAuthors = TextEditingController();
  final TextEditingController _bookDescription = TextEditingController();

  @override
  void initState() {
    super.initState();
    _bookName.text = widget.book.name;
    _bookDescription.text = widget.book.description!;
    _bookAuthors.text = widget.book.authors.join(', ');
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDarkMode = brightness == Brightness.dark;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: const CleanAppBar(
        title: 'Cập nhật thông tin',
      ),
      body: SingleChildScrollView(
        child: Container(
          color: Theme.of(context).backgroundColor,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: <Widget>[
                100.heightBox,
                Container(
                  height: 400,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: isDarkMode ? Colors.white : Colors.blue,
                    ),
                    borderRadius: const BorderRadius.all(Radius.circular(5)),
                    color: Theme.of(context).primaryColor,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    children: [
                      5.widthBox,
                      Column(
                        children: [
                          SizedBox(
                            width: 110,
                            height: 170,
                            child: widget.book.coverProvider != null
                                ? Image(
                                    image: widget.book.coverProvider!,
                                    filterQuality: FilterQuality.high,
                                    fit: BoxFit.fill,
                                  )
                                : Container(
                                    color: Colors.purple,
                                  ),
                          ),
                          5.heightBox,
                          TextButton(
                            onPressed: () async {
                              final files = (await FilePicker.platform
                                      .pickFiles(type: FileType.image))
                                  ?.files;

                              if (files?.isEmpty ?? true) {
                                return;
                              }
                              final imageFile = File(files!.single.path!);
                              widget.onImageChanged(
                                imageFile,
                              );
                            },
                            style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.all(Colors.blueAccent),
                              foregroundColor:
                                  MaterialStateProperty.all(Colors.white),
                            ),
                            child: const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                "Đặt bìa mới",
                              ),
                            ),
                          )
                        ],
                      ),
                      20.widthBox,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextFormField(
                              controller: _bookName,
                              decoration: const InputDecoration(
                                labelText: 'Tên sách',
                              ),
                            ),
                            10.heightBox,
                            TextFormField(
                              controller: _bookAuthors,
                              decoration: const InputDecoration(
                                labelText: 'Tác giả',
                              ),
                            ),
                            10.heightBox,
                            // const Text("Mô tả"),
                            Expanded(
                              child: TextFormField(
                                controller: _bookDescription,
                                decoration: InputDecoration(
                                  // labelText: _bookDescription.text.isNotEmpty
                                  //     ? 'Mô tả'
                                  //     : 'Không có mô tả',
                                  labelText:'Mô tả',
                                ),
                                maxLines: null,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: isDarkMode ? Colors.white : Colors.blue,
                    ),
                    borderRadius: const BorderRadius.all(Radius.circular(5)),
                    color: Theme.of(context).primaryColor,
                  ),
                  child: Row(
                    children: [
                      const Spacer(),
                      50.heightBox,
                      TextButton(
                        style: ButtonStyle(
                          minimumSize:
                              MaterialStateProperty.all(const Size(100, 35)),
                          backgroundColor:
                              MaterialStateProperty.all(Colors.blueAccent),
                        ),
                        child: const Text('Cập nhật'),
                        onPressed: () async {
                          if (_bookName.text.trim().isEmpty) {
                            getCustomToast.show("Chưa nhập tên sách", context);
                          } else if (_bookAuthors.text.trim().isEmpty) {
                            getCustomToast.show(
                                "Chưa nhập tên tác giả", context);
                          } else {
                            widget.onBookChanged(
                              _bookName.text.trim(),
                              _bookAuthors.text.trim(),
                              _bookDescription.text.trim(),
                            );
                          }
                        },
                      ),
                      50.widthBox,
                      TextButton(
                        onPressed: () async {
                          if (await confirmPopup(
                                context,
                                "Xác nhận xóa",
                                "Bạn có chắc muốn xóa cuốn sách này không?",
                              ) ==
                              true) {
                            widget.onDelete();
                          }
                        },
                        style: ButtonStyle(
                          minimumSize:
                              MaterialStateProperty.all(const Size(100, 35)),
                          backgroundColor:
                              MaterialStateProperty.all(Colors.redAccent),
                        ),
                        child: const Text('Xóa'),
                      ),
                      const Spacer(),
                    ],
                  ),
                ),
              ]
                  .map(
                    (e) => Padding(
                      padding: const EdgeInsets.all(8),
                      child: e,
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
      ),
    );
  }
}
