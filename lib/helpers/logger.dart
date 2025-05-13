import 'package:logger/logger.dart';

final logger = Logger(
  printer: PrettyPrinter(
    methodCount: 0,
    errorMethodCount: 3,
    lineLength: 80,
    colors: true,
    printEmojis: true,
    // ignore: deprecated_member_use
    printTime: true,
  ),
);
