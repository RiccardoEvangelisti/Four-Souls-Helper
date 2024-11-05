import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/chapter.dart';

class RulesProvider with ChangeNotifier {
  List<Chapter> _chapters = [];
  List<Chapter> _filteredChapters = [];
  String _searchTerm = '';
  bool _isLoading = true;
  late SharedPreferences _prefs;
  bool _isInitialized = false;

  List<Chapter> get chapters => _searchTerm.isEmpty ? _chapters : _filteredChapters;
  bool get isLoading => _isLoading;

  // GitHub API configuration
  final String owner = 'RiccardoEvangelisti';
  final String repo = 'Four-Souls-Helper';
  final String path = 'content';

  // Keys for SharedPreferences
  static const String _chaptersKey = 'chapters_data';
  static const String _lastUpdateKey = 'last_update';

  // Initialize SharedPreferences
  Future<void> init() async {
    if (_isInitialized) return;
    _prefs = await SharedPreferences.getInstance();
    _isInitialized = true;
    await loadLocalChapters();
  }

  // Load chapters from local storage
  Future<void> loadLocalChapters() async {
    await init();
    final String? chaptersJson = _prefs.getString(_chaptersKey);

    if (chaptersJson != null) {
      try {
        final List<dynamic> chaptersData = json.decode(chaptersJson);
        _chapters = chaptersData.map((data) => Chapter(
          title: data['title'],
          content: data['content'],
          isExpanded: false,
        )).toList();
        _isLoading = false;
        notifyListeners();
      } catch (e) {
        print('Error loading local chapters: $e');
        await fetchChapters();
      }
    } else {
      await fetchChapters();
    }
  }

  // Save chapters to local storage
  Future<void> _saveChaptersLocally() async {
    await init();
    final List<Map<String, String>> chaptersData = _chapters.map((chapter) => {
      'title': chapter.title,
      'content': chapter.content,
    }).toList();

    await _prefs.setString(_chaptersKey, json.encode(chaptersData));
    await _prefs.setString(_lastUpdateKey, DateTime.now().toIso8601String());
  }

  String _extractTitleFromMarkdown(String content) {
    final RegExp headerRegex = RegExp(r'^\s*#\s+(.+)$', multiLine: true);
    final match = headerRegex.firstMatch(content);

    if (match != null && match.groupCount >= 1) {
      return match.group(1)!.trim();
    }
    return '';
  }

  Future<void> fetchChapters() async {
    _isLoading = true;
    notifyListeners();

    try {
      final String apiUrl = 'https://api.github.com/repos/$owner/$repo/contents/$path';

      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {'Accept': 'application/vnd.github.v3+json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> files = json.decode(response.body);
        List<MapEntry<String, Chapter>> chaptersWithFiles = [];

        for (var file in files) {
          if (file['name'].endsWith('.md')) {
            final String rawUrl = 'https://raw.githubusercontent.com/$owner/$repo/main/$path/${file['name']}';

            final contentResponse = await http.get(Uri.parse(rawUrl));

            if (contentResponse.statusCode == 200) {
              String content = utf8.decode(contentResponse.bodyBytes);
              String title = _extractTitleFromMarkdown(content);

              if (title.isEmpty) {
                title = file['name']
                    .replaceAll('.md', '')
                    .replaceAll('-', ' ')
                    .split(' ')
                    .map((word) => word[0].toUpperCase() + word.substring(1))
                    .join(' ');
              }

              chaptersWithFiles.add(
                  MapEntry(
                      file['name'],
                      Chapter(
                        title: title,
                        content: content,
                        isExpanded: false,
                      )
                  )
              );
            }
          }
        }

        chaptersWithFiles.sort((a, b) => a.key.compareTo(b.key));
        _chapters = chaptersWithFiles.map((entry) => entry.value).toList();

        // Save the fetched chapters locally
        await _saveChaptersLocally();

        _isLoading = false;
        notifyListeners();
      } else {
        throw Exception('Failed to load file list: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching chapters: $error');
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  void searchChapters(String searchTerm) {
    _searchTerm = searchTerm.trim();
    closeAllChapters();

    if (_searchTerm.isEmpty) {
      _filteredChapters = [];
    } else {
      _filteredChapters = _chapters
          .where((chapter) => chapter.containsSearchTerm(_searchTerm))
          .toList();
    }
    notifyListeners();
  }

  void clearSearch() {
    _searchTerm = '';
    _filteredChapters = [];
    notifyListeners();
  }

  void toggleChapter(int index) {
    final chapters = _searchTerm.isEmpty ? _chapters : _filteredChapters;
    chapters[index].isExpanded = !chapters[index].isExpanded;
    notifyListeners();
  }

  void closeAllChapters() {
    for (var chapter in _chapters) {
      chapter.isExpanded = false;
    }
    for (var chapter in _filteredChapters) {
      chapter.isExpanded = false;
    }
    notifyListeners();
  }
}