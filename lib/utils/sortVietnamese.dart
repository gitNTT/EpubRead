class VietnameseComparator {
  static int compare(String a, String b) {
    const vietnameseAccents = {
      'a': 'áàạảãâấầậẩẫăắằặẳẵ',
      'e': 'éèẹẻẽêếềệểễ',
      'i': 'íìịỉĩ',
      'o': 'óòọỏõôốồộổỗơớờợởỡ',
      'u': 'úùụủũưứừựửữ',
      'y': 'ýỳỵỷỹ',
      'd': 'đ',
    };

    String removeAccent(String s) {
      for (var key in vietnameseAccents.keys) {
        for (var value in vietnameseAccents[key]!.split('')) {
          s = s.replaceAll(value, key);
        }
      }
      return s;
    }

    String normalizeString(String s) {
      return removeAccent(s.toLowerCase());
    }

    return normalizeString(a).compareTo(normalizeString(b));
  }
}
