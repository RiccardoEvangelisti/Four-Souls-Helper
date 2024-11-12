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
  String? _error;
  late SharedPreferences _prefs;
  bool _isInitialized = false;
  Map<String, String> _imageCache = {};

  List<Chapter> get chapters => _searchTerm.isEmpty ? _chapters : _filteredChapters;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // GitHub API configuration
  final String owner = 'RiccardoEvangelisti';
  final String repo = 'Four-Souls-FAQ';
  final String path = 'content';

  // Keys for SharedPreferences
  static const String _chaptersKey = 'chapters_data';
  static const String _lastUpdateKey = 'last_update';
  static const String _imageCacheKey = 'image_cache';

  // Initialize SharedPreferences
  Future<void> init() async {
    if (_isInitialized) return;
    _prefs = await SharedPreferences.getInstance();
    _isInitialized = true;
    await _loadImageCache();
    await loadLocalChapters();
  }

  Future<void> _loadImageCache() async {
    final String? imageCacheJson = _prefs.getString(_imageCacheKey);
    if (imageCacheJson != null) {
      final Map<String, dynamic> cacheData = json.decode(imageCacheJson);
      _imageCache = Map<String, String>.from(cacheData);
    }
  }

  Future<void> _saveImageCache() async {
    await _prefs.setString(_imageCacheKey, json.encode(_imageCache));
  }

  String _getBaseImageUrl(String fullUrl) {
    // Estrae l'URL base dell'immagine rimuovendo eventuali parametri dopo # o ?
    final hashIndex = fullUrl.indexOf('#');
    final questionIndex = fullUrl.indexOf('?');

    if (hashIndex != -1 && questionIndex != -1) {
      return fullUrl.substring(0, hashIndex < questionIndex ? hashIndex : questionIndex);
    } else if (hashIndex != -1) {
      return fullUrl.substring(0, hashIndex);
    } else if (questionIndex != -1) {
      return fullUrl.substring(0, questionIndex);
    }

    return fullUrl;
  }

  Future<String> _processMarkdownImages(String content) async {
    final RegExp imageRegex = RegExp(r'!\[([^\]]*)\]\(([^)]+)\)');
    String processedContent = content;

    for (Match match in imageRegex.allMatches(content)) {
      final String originalImageUrl = match.group(2)!;
      if (!originalImageUrl.startsWith('http')) continue;

      // Estrai l'URL base dell'immagine
      final String baseImageUrl = _getBaseImageUrl(originalImageUrl);

      try {
        if (!_imageCache.containsKey(baseImageUrl)) {
          final response = await http.get(Uri.parse(baseImageUrl));
          if (response.statusCode == 200) {
            final String base64Image = base64Encode(response.bodyBytes);
            _imageCache[baseImageUrl] = base64Image;
            await _saveImageCache();
          }
        }

        if (_imageCache.containsKey(baseImageUrl)) {
          final String base64Image = _imageCache[baseImageUrl]!;
          // Sostituisce solo l'URL dell'immagine mantenendo eventuali parametri
          final String newImageUrl = originalImageUrl.replaceAll(
              RegExp(RegExp.escape(baseImageUrl)),
              'data:image/png;base64,$base64Image'
          );
          processedContent = processedContent.replaceAll(
              originalImageUrl,
              newImageUrl
          );
        }
      } catch (e) {
        print('Error processing image $baseImageUrl: $e');
      }
    }
    return processedContent;
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
        _error = null;
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
    _error = null;
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
              // Process and cache images in the markdown content
              content = await _processMarkdownImages(content);

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
        _error = null;
        notifyListeners();
      } else {
        throw Exception('Failed to load file list: ${response.statusCode}');
      }
    } catch (error) {
      _error = 'Failed to load content. Please check your internet connection and try again.';
      print('Error fetching chapters: $error');
      _isLoading = false;
      notifyListeners();
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