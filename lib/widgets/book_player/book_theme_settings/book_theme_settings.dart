import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';
import '../../epub_renderer/epub_renderer.dart';

class BookThemeSettings extends StatefulWidget {
  const BookThemeSettings({
    Key? key,
    required this.styleProperties,
    required this.onUpdateStyle,
  }) : super(key: key);

  final EpubStyleProperties styleProperties;
  final void Function() onUpdateStyle;

  @override
  _BookThemeSettingsState createState() => _BookThemeSettingsState();
}

class _BookThemeSettingsState extends State<BookThemeSettings> {
  final fonts = [
    "Mặc định",
    "Arial",
    "RobotoMono",
    "Literata",
    "Merriweather",
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      decoration: BoxDecoration(
        color: theme.primaryColor,
        borderRadius: const BorderRadius.all(Radius.circular(15)),
      ),
      child: SingleChildScrollView(
        child: Column(
          //scrollDirection: Axis.vertical,
          children: [
            Padding(
              padding: const EdgeInsets.all(15),
              child: Wrap(
                runSpacing: 15,
                children: [
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Chuyển trang",
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium!
                              .copyWith(fontSize: 18),
                        ),
                        10.heightBox,
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Column(
                                children: [
                                  IconButton(
                                    onPressed: () {
                                      setState(() {
                                        widget.styleProperties.isHorVerMode =
                                            true;
                                        //widget.onUpdateStyle();
                                      });
                                    },
                                    icon: ColorFiltered(
                                      colorFilter: ColorFilter.mode(
                                        widget.styleProperties.isHorVerMode
                                            ? Colors.blueAccent
                                            : Colors.black,
                                        BlendMode.srcIn,
                                      ),
                                      child: Image.asset(
                                          'assets/images/verticalIcon.png'),
                                    ),
                                    iconSize: 50,
                                  ),
                                  5.heightBox,
                                  Text(
                                    "Dọc",
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall!
                                        .copyWith(
                                            fontSize: 15,
                                            color: widget.styleProperties
                                                    .isHorVerMode
                                                ? Colors.blueAccent
                                                : Colors.black),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                children: [
                                  IconButton(
                                    onPressed: () {
                                      setState(() {
                                        widget.styleProperties.isHorVerMode =
                                            false;
                                        //widget.onUpdateStyle();
                                      });
                                    },
                                    icon: ColorFiltered(
                                      colorFilter: ColorFilter.mode(
                                        !widget.styleProperties.isHorVerMode
                                            ? Colors.blueAccent
                                            : Colors.black,
                                        BlendMode.srcIn,
                                      ),
                                      child: Image.asset(
                                          'assets/images/horizontalIcon.png'),
                                    ),
                                    iconSize: 50,
                                  ),
                                  5.heightBox,
                                  Text(
                                    "Ngang",
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium!
                                        .copyWith(
                                            fontSize: 15,
                                            color: !widget.styleProperties
                                                    .isHorVerMode
                                                ? Colors.blueAccent
                                                : Colors.black),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Divider(
                    color: Colors.black,
                  ),
                  Row(
                    children: [
                      Text(
                        "Chủ đề",
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                              fontSize: 18,
                            ),
                      ),
                      60.widthBox,
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            widget.styleProperties.theme =
                                EpubStyleThemes.light;
                            widget.onUpdateStyle();
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          shape: const CircleBorder(),
                          backgroundColor: Colors.white,
                          padding: const EdgeInsets.all(16),
                          side: const BorderSide(color: Colors.grey, width: 2),
                        ),
                        child: Icon(
                          Icons.check,
                          size: 20,
                          color: widget.styleProperties.theme ==
                                  EpubStyleThemes.light
                              ? Colors.black
                              : Colors.white,
                        ),
                      ),
                      10.widthBox,
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            widget.styleProperties.theme = EpubStyleThemes.dark;
                            widget.onUpdateStyle();
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          shape: const CircleBorder(),
                          backgroundColor: Colors.black,
                          padding: const EdgeInsets.all(16),
                          side: const BorderSide(color: Colors.grey, width: 2),
                        ),
                        child: Icon(
                          Icons.check,
                          size: 20,
                          color: widget.styleProperties.theme ==
                                  EpubStyleThemes.dark
                              ? Colors.white
                              : Colors.black,
                        ),
                      ),
                    ],
                  ),
                  _Scaler(
                    title: "Cỡ chữ",
                    decrease: Icon(
                      Icons.text_decrease_sharp,
                      color: theme.iconTheme.color,
                    ),
                    increase: Icon(
                      Icons.text_increase_sharp,
                      color: theme.iconTheme.color,
                    ),
                    valueDisplay:
                        "${(widget.styleProperties.fontSizeMultiplier * 100).round() - 30}%",
                    onDecrease: () {
                      if (widget.styleProperties.fontSizeMultiplier > 0.8) {
                        widget.styleProperties.fontSizeMultiplier -= 0.1;
                        widget.styleProperties.lineHeightMultiplier -= 0.1;
                        widget.onUpdateStyle();
                      }
                    },
                    onIncrease: () {
                      if (widget.styleProperties.fontSizeMultiplier < 2.5) {
                        widget.styleProperties.fontSizeMultiplier += 0.1;
                        widget.styleProperties.lineHeightMultiplier += 0.1;
                        widget.onUpdateStyle();
                      }
                    },
                  ),
                  Material(
                    color: Colors.transparent,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _AlignmentButton(
                          icon: Icons.format_align_left,
                          alignment: "left",
                          updateStyle: widget.onUpdateStyle,
                          style: widget.styleProperties,
                        ),
                        _AlignmentButton(
                          icon: Icons.format_align_center,
                          alignment: "center",
                          updateStyle: widget.onUpdateStyle,
                          style: widget.styleProperties,
                        ),
                        _AlignmentButton(
                          icon: Icons.format_align_right,
                          alignment: "right",
                          updateStyle: widget.onUpdateStyle,
                          style: widget.styleProperties,
                        ),
                        _AlignmentButton(
                          icon: Icons.format_align_justify,
                          alignment: "justify",
                          updateStyle: widget.onUpdateStyle,
                          style: widget.styleProperties,
                        ),
                      ],
                    ),
                  ),
                  DropdownButton<String>(
                    value: fonts.contains(widget.styleProperties.fontFamily)
                        ? widget.styleProperties.fontFamily
                        : fonts.first,
                    dropdownColor: theme.canvasColor,
                    onChanged: (String? newFont) {
                      if (newFont == null) {
                        return;
                      }

                      widget.styleProperties.fontFamily = newFont;
                      widget.onUpdateStyle();
                    },
                    icon: const Icon(Icons.text_format_rounded),
                    focusColor: Colors.transparent,
                    iconEnabledColor: theme.iconTheme.color,
                    items: fonts.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Text(
                            value,
                            style: theme.textTheme.bodyMedium!
                                .copyWith(fontSize: 20),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(15),
              child: Wrap(
                runSpacing: 15,
                children: [
                  _Scaler(
                    title: "Chiều cao dòng",
                    decrease: Icon(
                      Icons.remove,
                      color: theme.iconTheme.color,
                    ),
                    increase: Icon(
                      Icons.add,
                      color: theme.iconTheme.color,
                    ),
                    valueDisplay: (widget.styleProperties.lineHeightMultiplier)
                        .toStringAsFixed(1),
                    onDecrease: () {
                      if (widget.styleProperties.lineHeightMultiplier > 1) {
                        widget.styleProperties.lineHeightMultiplier -= 0.1;
                        widget.onUpdateStyle();
                      }
                    },
                    onIncrease: () {
                      if (widget.styleProperties.lineHeightMultiplier < 2) {
                        widget.styleProperties.lineHeightMultiplier += 0.1;
                        widget.onUpdateStyle();
                      }
                    },
                  ),
                  _Scaler(
                    title: "Khoảng cách từ",
                    decrease: Icon(
                      Icons.remove,
                      size: 17,
                      color: theme.iconTheme.color,
                    ),
                    increase: Icon(
                      Icons.add,
                      color: theme.iconTheme.color,
                    ),
                    valueDisplay: "${widget.styleProperties.wordSpacingAdder}",
                    onDecrease: () {
                      if (widget.styleProperties.wordSpacingAdder > -5) {
                        widget.styleProperties.wordSpacingAdder -= 1;
                        widget.onUpdateStyle();
                      }
                    },
                    onIncrease: () {
                      if (widget.styleProperties.wordSpacingAdder < 5) {
                        widget.styleProperties.wordSpacingAdder += 1;
                        widget.onUpdateStyle();
                      }
                    },
                  ),
                  _Scaler(
                    title: "Khoảng cách kí tự",
                    decrease: Icon(
                      Icons.remove,
                      size: 17,
                      color: theme.iconTheme.color,
                    ),
                    increase: Icon(
                      Icons.add,
                      color: theme.iconTheme.color,
                    ),
                    valueDisplay:
                        "${widget.styleProperties.letterSpacingAdder}",
                    onDecrease: () {
                      if (widget.styleProperties.letterSpacingAdder > -3) {
                        widget.styleProperties.letterSpacingAdder -= 1;
                        widget.onUpdateStyle();
                      }
                    },
                    onIncrease: () {
                      if (widget.styleProperties.letterSpacingAdder < 3) {
                        widget.styleProperties.letterSpacingAdder += 1;
                        widget.onUpdateStyle();
                      }
                    },
                  ),
                  _Scaler(
                    title: "Nét chữ",
                    decrease: Icon(
                      Icons.format_bold_sharp,
                      size: 17,
                      color: theme.iconTheme.color,
                    ),
                    increase: Icon(
                      Icons.format_bold,
                      color: theme.iconTheme.color,
                    ),
                    valueDisplay: widget.styleProperties.weightMultiplier == 1
                        ? "Bình thường"
                        : "In đậm",
                    onDecrease: () {
                      if (widget.styleProperties.weightMultiplier > 1) {
                        widget.styleProperties.weightMultiplier -= 0.3;
                        widget.onUpdateStyle();
                      }
                    },
                    onIncrease: () {
                      if (widget.styleProperties.weightMultiplier < 1.3) {
                        widget.styleProperties.weightMultiplier += 0.3;
                        widget.onUpdateStyle();
                      }
                    },
                  ),
                  Center(
                    child: TextButton(
                      onPressed: () {
                        widget.styleProperties.align = "left";
                        widget.styleProperties.fontSizeMultiplier = 1.3;
                        widget.styleProperties.lineHeightMultiplier = 1.5;
                        widget.styleProperties.weightMultiplier = 1;
                        widget.styleProperties.letterSpacingAdder = 0;
                        widget.styleProperties.wordSpacingAdder = 0;
                        widget.onUpdateStyle();
                      },
                      child: Text("Về mặc định"),
                      style: ButtonStyle(
                        minimumSize: MaterialStateProperty.all(Size(100, 35)),
                        foregroundColor:
                            MaterialStateProperty.all(Colors.white),
                        backgroundColor:
                            MaterialStateProperty.all(Colors.blueAccent),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Scaler extends StatelessWidget {
  const _Scaler({
    Key? key,
    required this.title,
    required this.valueDisplay,
    required this.decrease,
    required this.increase,
    required this.onDecrease,
    required this.onIncrease,
  }) : super(key: key);

  final String title;
  final String valueDisplay;
  final Widget decrease;
  final Widget increase;
  final void Function() onDecrease;
  final void Function() onIncrease;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title,
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      fontSize: 18,
                    )),
            5.heightBox,
            Text(valueDisplay,
                style: Theme.of(context).textTheme.bodySmall!.copyWith(
                      fontSize: 15,
                    )),
          ]),
        ),
        30.widthBox,
        Expanded(
          child: _ScalerButton(
            onPressed: onDecrease,
            child: decrease,
          ),
        ),
        20.widthBox,
        Expanded(
          child: _ScalerButton(
            onPressed: onIncrease,
            child: increase,
          ),
        ),
      ],
    );
  }
}

class _ScalerButton extends StatelessWidget {
  const _ScalerButton({
    Key? key,
    required this.child,
    required this.onPressed,
    this.backgroundColor,
  }) : super(key: key);

  final Widget child;
  final void Function() onPressed;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        maxWidth: 110,
        minHeight: 40.0,
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all<Color>(
            backgroundColor ?? Theme.of(context).dialogBackgroundColor,
          ),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
              side: BorderSide(
                color: Theme.of(context).iconTheme.color!,
              ),
            ),
          ),
        ),
        child: child,
      ),
    );
  }
}

class _AlignmentButton extends StatelessWidget {
  const _AlignmentButton({
    Key? key,
    required this.icon,
    required this.alignment,
    required this.style,
    required this.updateStyle,
  }) : super(key: key);

  final IconData icon;
  final String alignment;
  final EpubStyleProperties style;
  final void Function() updateStyle;

  @override
  Widget build(BuildContext context) {
    final active = style.align == alignment;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color:
              active ? Theme.of(context).iconTheme.color! : Colors.transparent,
          width: 1,
        ),
      ),
      child: IconButton(
        icon: Icon(icon),
        splashRadius: 23,
        iconSize: 32,
        onPressed: () {
          style.align = alignment;
          updateStyle();
        },
      ),
    );
  }
}
