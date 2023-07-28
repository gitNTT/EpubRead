import 'dart:async';
import 'dart:math';
import 'package:epub_app/utils/get_files_from_epub_spine.dart';
import 'package:epub_app/widgets/epub_renderer/epub_location.dart';
import 'package:epub_app/widgets/getToastCustom.dart';
import 'package:epubz/epubz.dart';
import 'package:flutter/material.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart';
import '../utils/link_spine_file_to_chapter.dart';
import '../widgets/clean_app_bar.dart';

class SearchResults {
  final EpubLocation<int, EpubInnerTextNode> location;
  final String nearbyText;

  SearchResults({
    required this.location,
    required this.nearbyText,
  });
}

class BookPlayerSearch extends StatefulWidget {
  const BookPlayerSearch({
    Key? key,
    required this.epubBook,
    this.initialText,
  }) : super(key: key);

  final String? initialText;
  final EpubBook epubBook;

  @override
  _BookPlayerSearchState createState() => _BookPlayerSearchState();
}

class _BookPlayerSearchState extends State<BookPlayerSearch> {
  late TextEditingController textEditingController;
  Future<List<SearchResults>> results = Future.value([]);
  late final List<EpubContentFile> spineFiles;
  int numberOfResults = 0;

  @override
  void initState() {
    textEditingController = TextEditingController(
      text: widget.initialText ?? "",
    );

    spineFiles = getFilesFromEpubSpine(widget.epubBook);

    if (widget.initialText != null) {
      results = search(widget.initialText!);
    }

    super.initState();
  }

  List<dom.Node?> _nodesUnder(dom.Node node,
      {int nodeType = -1, bool leaveHoles = false}) {
    var all = <dom.Node?>[];
    for (var node in node.nodes) {
      if (nodeType == -1 || node.nodeType == nodeType) {
        all.add(node);
      } else if (leaveHoles) {
        all.add(null);
      }
      all += _nodesUnder(
        node,
        nodeType: nodeType,
        leaveHoles: leaveHoles,
      );
    }
    return all;
  }

  // Future<List<SearchResults>> search(String query) async {
  //   return spineFiles
  //       .asMap()
  //       .entries
  //       .map((entry) {
  //         final index = entry.key;
  //         final file = entry.value;
  //         final spineFileSearchResults = <SearchResults>[];
  //
  //         if (file is! EpubTextContentFile) {
  //           return spineFileSearchResults;
  //         }
  //
  //         final document = parse(file.Content);
  //         final topElement = document.getElementsByTagName("html").first;
  //
  //         final textNodes = _nodesUnder(topElement,
  //             nodeType: dom.Node.TEXT_NODE, leaveHoles: false);
  //
  //         for (var entry in textNodes.asMap().entries) {
  //           final textNodeIndex = entry.key;
  //           final textNode = entry.value;
  //
  //           if (textNode?.text == null) {
  //             continue;
  //           }
  //
  //           final matches =
  //               RegExp(query, caseSensitive: false).allMatches(textNode!.text!);
  //           for (var match in matches) {
  //             spineFileSearchResults.add(SearchResults(
  //               location: EpubLocation(
  //                   index, EpubInnerTextNode(textNodeIndex - 2, match.start)),
  //               nearbyText: textNode.text!.substring(
  //                 max(match.start - 20, 0),
  //                 min(match.end + 20, textNode.text!.length),
  //               ),
  //             ));
  //           }
  //         }
  //
  //         return spineFileSearchResults;
  //       })
  //       .expand((i) => i)
  //       .toList();
  // }

  Future<List<SearchResults>> search(String query) async {
    return spineFiles
        .asMap()
        .entries
        .map((entry) {
          final index = entry.key;
          final file = entry.value;
          final spineFileSearchResults = <SearchResults>[];

          if (file is! EpubTextContentFile) {
            return spineFileSearchResults;
          }

          final document = parse(file.Content);
          final topElement = document.getElementsByTagName("html").first;

          final plainTexts = _extractPlainTexts(topElement);

          for (int i = 0; i < plainTexts.length; i++) {
            final plainText = plainTexts[i];
            final matches =
                RegExp(query, caseSensitive: false).allMatches(plainText);
            for (var match in matches) {
              spineFileSearchResults.add(SearchResults(
                location:
                    EpubLocation(index, EpubInnerTextNode(i - 2, match.start)),
                nearbyText: plainText.substring(
                  max(match.start - 20, 0),
                  min(match.end + 20, plainText.length),
                ),
              ));
            }
          }

          return spineFileSearchResults;
        })
        .expand((i) => i)
        .toList();
  }

  List<String> _extractPlainTexts(dom.Element element) {
    final List<String> plainTexts = [];
    for (var node in element.nodes) {
      if (node.nodeType == dom.Node.TEXT_NODE) {
        plainTexts.add((node as dom.Text).data);
      } else if (node.nodeType == dom.Node.ELEMENT_NODE) {
        final element = node as dom.Element;
        if (element.localName != "script" && element.localName != "style") {
          plainTexts.addAll(_extractPlainTexts(element));
        }
      }
    }
    return plainTexts;
  }

  Widget _buildHighlightedText(String originalText, String query) {
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyText1!.color;
    final List<TextSpan> textSpans = [];

    final pattern = RegExp(query, caseSensitive: false);
    int start = 0;

    for (final match in pattern.allMatches(originalText)) {
      if (match.start > start) {
        final textBeforeMatch = originalText.substring(start, match.start);
        textSpans.add(TextSpan(text: textBeforeMatch));
      }

      final matchedText = originalText.substring(match.start, match.end);

      final isChapterTitle =
          linkSpineFileToChapter(widget.epubBook, 0, spineFiles: spineFiles)
              ?.Title
              ?.toLowerCase()
              .contains(matchedText.toLowerCase());

      textSpans.add(TextSpan(
        text: matchedText,
        style: TextStyle(
          fontWeight:
              isChapterTitle == true ? FontWeight.bold : FontWeight.normal,
          color: Colors.blue,
        ),
      ));
      start = match.end;
    }



    if (start < originalText.length) {
      final textAfterMatch = originalText.substring(start);
      textSpans.add(TextSpan(text: textAfterMatch));
    }


    return Text.rich(
      TextSpan(
        style: TextStyle(color: textColor),
        children: textSpans,
      ),
    );
  }

  void _updateNumberOfResults(List<SearchResults> searchResults) {
    setState(() {
      numberOfResults = searchResults.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CleanAppBar(
        title: 'Tìm kiếm',
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextFormField(
              controller: textEditingController,
              onFieldSubmitted: (String value) async {
                setState(() {
                  results = search(value);
                });
                List<SearchResults> searchResults = await results;
                _updateNumberOfResults(searchResults);
                getCustomToast.show("Số kết quả tìm được: $numberOfResults", context);

              },
            ),
            Expanded(
              child: FutureBuilder(
                future: results,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final results = snapshot.data as List<SearchResults>;
                    return ListView.builder(
                      itemCount: results.length,
                      itemBuilder: (context, index) {
                        final result = results[index];
                        return ListTile(
                          title: _buildHighlightedText(
                            linkSpineFileToChapter(
                                  widget.epubBook,
                                  result.location.page,
                                  spineFiles: spineFiles,
                                )?.Title ??
                                spineFiles[result.location.page].FileName!,
                            textEditingController.text,
                          ),
                          subtitle: _buildHighlightedText(
                            result.nearbyText,
                            textEditingController.text,
                          ),
                          onTap: () {
                            Navigator.of(context).pop(result.location);
                          },
                        );
                      },
                    );
                  } else if (snapshot.hasError) {
                    return Text("${snapshot.error}");
                  } else {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                },
              ),
            ),

          ],
        ),
      ),
    );
  }
}
