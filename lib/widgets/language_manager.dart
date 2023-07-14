import 'package:epub_app/widgets/clean_app_bar.dart';
import 'package:epub_app/widgets/getToastCustom.dart';
import 'package:epub_app/widgets/message_popup.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';
import '../constants/strings.dart';

class LanguageManager extends StatefulWidget {
  const LanguageManager({
    Key? key,
    required this.modelManager,
  }) : super(key: key);

  final OnDeviceTranslatorModelManager modelManager;

  @override
  _LanguageManagerState createState() => _LanguageManagerState();
}

class _LanguageManagerState extends State<LanguageManager> {



  Map<String, bool> downloadingLanguages = {};

  Future<void> _downloadLanguage(String languageCode) async {
    setState(() {
      downloadingLanguages[languageCode] = true; // Đặt trạng thái tải xuống là true
    });

    if (await widget.modelManager.downloadModel(languageCode)) {
      messagePopup(
        context,
        "Tải hoàn tất",
        "Thành công tải xuống ${languageNames[languageCode]}.",
      );
    } else {
      messagePopup(
        context,
        "Lỗi khi tải xuống",
        "Không thể tải ${languageNames[languageCode]}.",
      );
    }

    setState(() {
      downloadingLanguages[languageCode] = false; // Đặt trạng thái tải xuống là false khi hoàn tất download
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CleanAppBar(title: "Gói ngôn ngữ"),
      body: ListView.builder(
        itemCount: TranslateLanguage.values.length,
        itemBuilder: (context, index) {
          final language = TranslateLanguage.values[index];
          final isDownloading = downloadingLanguages[language.bcpCode] ?? false; // Lấy trạng thái tải xuống của ngôn ngữ

          return ListTile(
            title: Text(languageNames[language.bcpCode]!),
            trailing: isDownloading
                ? const CircularProgressIndicator() // Hiển thị CircularProgressIndicator nếu đang tải xuống
                : FutureBuilder<bool>(
              future: widget.modelManager.isModelDownloaded(language.bcpCode),
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data == true) {
                  return const Icon(Icons.download_done);
                } else {
                  return const Icon(null);
                }
              },
            ),
            onTap: isDownloading
                ? null // Không cho phép nhấp vào nếu đang tải xuống
                : () {
              getCustomToast.show("Vui lòng không thoát màn hình khi đang tải", context,longDuration: true);
              _downloadLanguage(language.bcpCode);

            }
          );
        },
      ),
    );
  }
}
