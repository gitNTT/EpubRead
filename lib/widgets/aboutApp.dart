import 'package:flutter/material.dart';

class AboutApp extends StatelessWidget {
  const AboutApp({
    Key? key,
    required this.titleName, required this.subName,

  }) : super(key: key);

  final String titleName;
  final String subName;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.transparent,
        ),
        borderRadius: const BorderRadius.all(Radius.circular(5)),
        color: Theme.of(context).primaryColor,
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(titleName, style: const TextStyle(fontSize: 16)),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(subName,),
          ),
        ],
      ),
    );
  }
}
