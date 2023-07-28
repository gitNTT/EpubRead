import 'dart:io';
import 'package:archive/archive_io.dart';
import 'package:epub_app/widgets/clean_app_bar.dart';
import 'package:epub_app/widgets/confirm_popup.dart';
import 'package:epub_app/widgets/settings_switch.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';
import 'package:velocity_x/velocity_x.dart';
import '../managers/settings_manager.dart';
import '../widgets/aboutApp.dart';
import '../widgets/language_manager.dart';
import '../widgets/enum_theme.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class HomeSettings extends StatefulWidget {
  const HomeSettings({
    Key? key,
    required this.settingsManager,
  }) : super(key: key);

  final SettingsManager settingsManager;

  @override
  _HomeSettingsState createState() => _HomeSettingsState();
}

class _HomeSettingsState extends State<HomeSettings> {
  final translatorModelManager = OnDeviceTranslatorModelManager();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: CleanAppBar(
        title: 'Cài đặt',
        actions: [
          IconButton(
            splashRadius: 20,
            icon: const Icon(Icons.language_outlined),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LanguageManager(
                    modelManager: translatorModelManager,
                  ),
                ),
              );
              setState(() {});
            },
          ),
        ],
      ),
      body: Container(
        color: Theme.of(context).backgroundColor,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                const SizedBox(
                  height: 100,
                ),
                SettingsEnumDropdown<ThemeMode>(
                  settingName: 'Giao diện',
                  dropdownItems: const [
                    DropdownMenuItem(
                      value: ThemeMode.system,
                      child: Text("Mặc định",style: TextStyle(fontSize: 16)),
                    ),
                    DropdownMenuItem(
                      value: ThemeMode.light,
                      child: Text("Sáng",style: TextStyle(fontSize: 16)),
                    ),
                    DropdownMenuItem(
                      value: ThemeMode.dark,
                      child: Text("Tối",style: TextStyle(fontSize: 16)),
                    ),
                  ],
                  value: widget.settingsManager.config.themeMode,
                  onChange: (value) async {
                    setState(() {
                      widget.settingsManager.config.themeMode = value;
                    });
                    await widget.settingsManager.saveConfig();
                    Phoenix.rebirth(context);
                  },
                ),
                SettingsSwitch(
                  settingName: "Hiệu ứng chuyển trang",
                  value: widget.settingsManager.config.dragPageAnimation,
                  onChanged: (value) {
                    setState(() {
                      widget.settingsManager.config.dragPageAnimation = value;
                    });
                    widget.settingsManager.saveConfig();
                  },
                ),
                SettingsSwitch(
                  settingName: "Lắc để sang trang",
                  value: widget.settingsManager.config.nextPageOnShake,
                  onChanged: (value) {
                    setState(() {
                      widget.settingsManager.config.nextPageOnShake = value;
                    });
                    widget.settingsManager.saveConfig();
                  },
                ),
                const AboutApp(
                  titleName: "Phiên bản ứng dụng",
                  subName: "25.12.01",
                ),
                const AboutApp(
                  titleName: "",
                  subName: "ePubApp",
                ),
                50.heightBox,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      style: ButtonStyle(
                        minimumSize: MaterialStateProperty.all(const Size(100, 40)),
                        backgroundColor:
                        MaterialStateProperty.all(Colors.blueAccent),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          "Sao lưu",
                        ),
                      ),
                      onPressed: () async {
                        final tempDir = await getTemporaryDirectory();
                        final tempZipPath = p.join(tempDir.path, "data.zip");

                        final encoder = ZipFileEncoder();
                        await _zipDirectory(
                          encoder,
                          widget.settingsManager.directory,
                          filename: tempZipPath,
                        );

                        await FlutterFileDialog.saveFile(
                          params: SaveFileDialogParams(
                            fileName: "book-reader-data.zip",
                            mimeTypesFilter: ["application/zip"],
                            sourceFilePath: tempZipPath,
                          ),
                        );
                      },
                    ),
                    TextButton(
                      style: ButtonStyle(
                        minimumSize: MaterialStateProperty.all(const Size(100, 40)),
                        backgroundColor:
                        MaterialStateProperty.all(Colors.blueAccent),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          "Khôi phục",
                        ),
                      ),
                      onPressed: () async {
                        if (await confirmPopup(
                              context,
                              "Xác nhận",
                              "Bạn có chắc muốn thay thế tất cả dữ liệu hiện có không?",
                            ) !=
                            true) {
                          return;
                        }

                        final files = (await FilePicker.platform.pickFiles(
                          type: FileType.custom,
                          allowedExtensions: ['zip'],
                        ))
                            ?.files;

                        if (files?.isEmpty ?? true) {
                          return;
                        }

                        final dataZipFilePath = files!.single.path!;

                        // Delete the current data
                        final filesToDelete = await widget
                            .settingsManager.directory
                            .list()
                            .toList();
                        for (final file in filesToDelete) {
                          await file.delete(recursive: true);
                        }

                        await extractFileToDisk(
                          dataZipFilePath,
                          widget.settingsManager.directory.path,
                        );

                        Phoenix.rebirth(context);
                      },
                    ),
                    TextButton(
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          "Xóa dữ liệu",
                        ),
                      ),
                      onPressed: () async {
                        if (await confirmPopup(
                              context,
                              "Xóa dữ liệu",
                              "Bạn có chắc muốn xóa cả dữ liệu không?",
                            ) ==
                            true) {
                          // Delete the current data
                          final filesToDelete = await widget
                              .settingsManager.directory
                              .list()
                              .toList();
                          for (final file in filesToDelete) {
                            await file.delete(recursive: true);
                          }

                          Phoenix.rebirth(context);
                        }
                      },
                      style: ButtonStyle(
                        minimumSize: MaterialStateProperty.all(const Size(100, 40)),
                        backgroundColor:
                            MaterialStateProperty.all(Colors.redAccent),
                      ),
                    ),
                  ],
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

Future<void> _zipDirectory(ZipFileEncoder zipFileEncoder, Directory dir,
    {String? filename,
    int? level,
    bool followLinks = true,
    DateTime? modified}) async {
  final dirPath = dir.path;
  final zipPath = filename ?? '$dirPath.zip';
  level ??= ZipFileEncoder.GZIP;
  zipFileEncoder.create(zipPath, level: level, modified: modified);
  await zipFileEncoder.addDirectory(dir,
      includeDirName: false, level: level, followLinks: followLinks);
  zipFileEncoder.close();
}
