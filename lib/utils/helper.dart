String shortenString(String text) {
  const int maxLength = 40;

  if (text.length <= maxLength) {
    return text;
  } else {
    return text.substring(0, maxLength) + '...';
  }
}
