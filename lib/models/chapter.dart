class Chapter {
  final String title;
  final String content;
  bool isExpanded;

  Chapter({
    required this.title,
    required this.content,
    this.isExpanded = false,
  });

  bool containsSearchTerm(String searchTerm) {
    return title.toLowerCase().contains(searchTerm.toLowerCase()) ||
        content.toLowerCase().contains(searchTerm.toLowerCase());
  }
}