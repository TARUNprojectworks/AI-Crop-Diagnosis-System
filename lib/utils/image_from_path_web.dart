import 'package:flutter/widgets.dart';

Widget imageFromPath(
  String path, {
  BoxFit fit = BoxFit.cover,
}) {
  return Image.network(path, fit: fit);
}
