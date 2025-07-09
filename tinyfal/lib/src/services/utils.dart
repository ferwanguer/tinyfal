import 'dart:math';

String generateCode({int length = 20}) {
  // Generate random alphanumeric codes of length
  String pool = 'abcdefghijklmnopqrstuvwxyz0123456789';
  Random r = Random();
  String code = '';
  for (var j = 0; j < length; j++) {
    code += pool[r.nextInt(pool.length)];
  }
  return code;
}

int calculateReadingTime(String text) {
  const int wordsPerMinute = 200; // Average reading speed
  int wordCount = text.split(RegExp(r'\s+')).length;
  return (wordCount / wordsPerMinute).ceil();
}
