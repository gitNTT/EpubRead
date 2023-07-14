import 'package:flutter/material.dart';
import '../../models/book.dart';

class BookPlayerTopOptions extends StatefulWidget {
  const BookPlayerTopOptions({
    Key? key,
    required this.page,
    required this.pages,
    required this.book,
    required this.onPageChanged,
    required this.onChaptersViewPressed,
    required this.onExit,
    required this.onOptions,
    required this.onNotesPressed,
    required this.onLocationBack,
    required this.onSearch,
    required this.locationBackEnabled,
  }) : super(key: key);

  final int page;
  final int pages;
  final Book book;
  final void Function(int) onPageChanged;
  final void Function() onChaptersViewPressed;
  final void Function() onExit;
  final void Function() onOptions;
  final void Function() onNotesPressed;
  final void Function() onLocationBack;
  final void Function() onSearch;
  final bool locationBackEnabled;

  @override
  _BookPlayerTopOptionsState createState() =>
      _BookPlayerTopOptionsState();
}

class _BookPlayerTopOptionsState extends State<BookPlayerTopOptions> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8 + 20, left: 20),
      child: Row(
        children: [
          Expanded(
            child: Material(
              color: Colors.transparent,
              child: IconButton(
                splashRadius: 20,
                icon: const Icon(Icons.arrow_back),
                onPressed: widget.onExit,
              ),
            ),
          ),
          Expanded(
            child: Material(
              color: Colors.transparent,
              child: IconButton(
                splashRadius: 20,
                icon: const Icon(Icons.list),
                onPressed: widget.onChaptersViewPressed,
              ),
            ),
          ),
          Expanded(
            child: Material(
              color: Colors.transparent,
              child: IconButton(
                splashRadius: 20,
                icon: const Icon(Icons.edit_note_sharp),
                onPressed: widget.onNotesPressed,
              ),
            ),
          ),

          Expanded(
            child: Material(
              color: Colors.transparent,
              child: IconButton(
                splashRadius: 20,
                icon: const Icon(Icons.search),
                onPressed: widget.onSearch,
              ),
            ),
          ),
          Expanded(
            child: Material(
              color: Colors.transparent,
              child: IconButton(
                splashRadius: 20,
                icon: const Icon(Icons.settings_backup_restore),
                onPressed:
                    widget.locationBackEnabled ? widget.onLocationBack : null,
              ),
            ),
          ),
          // Expanded(
          //   child: Text(
          //     "${widget.page} / ${widget.pages}",
          //     style: Theme.of(context).textTheme.bodyText2,
          //     textAlign: TextAlign.center,
          //   ),
          // ),
          Expanded(
            child: Material(
              color: Colors.transparent,
              child: IconButton(
                splashRadius: 20,
                icon: const Icon(Icons.settings_suggest_outlined),
                onPressed: widget.onOptions,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
