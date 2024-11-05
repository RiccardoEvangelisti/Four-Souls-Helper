// lib/main.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_markdown/flutter_markdown.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Four Souls Helper',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final List<Widget> _screens = [
    const TopicsScreen(),
    const FAQScreen(),
    const CardsErrataScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const SearchBarWidget(),
      ),
      drawer: DrawerMenu(
        selectedIndex: _selectedIndex,
        onItemSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
      body: _screens[_selectedIndex],
    );
  }
}

class SearchBarWidget extends StatelessWidget {
  const SearchBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: TextField(
        decoration: const InputDecoration(
          hintText: 'Cerca nel testo...',
          border: InputBorder.none,
          icon: Icon(Icons.search),
        ),
        onChanged: (value) {
          // Implementa la logica di ricerca qui
        },
      ),
    );
  }
}

class DrawerMenu extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const DrawerMenu({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Text(
              'Menu',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.book),
            title: const Text('Topics'),
            selected: selectedIndex == 0,
            onTap: () {
              Navigator.pop(context);
              onItemSelected(0);
            },
          ),
          ListTile(
            leading: const Icon(Icons.question_answer),
            title: const Text('FAQs'),
            selected: selectedIndex == 1,
            onTap: () {
              Navigator.pop(context);
              onItemSelected(1);
            },
          ),
          ListTile(
            leading: const Icon(Icons.error_outline),
            title: const Text('Cards Errata'),
            selected: selectedIndex == 2,
            onTap: () {
              Navigator.pop(context);
              onItemSelected(2);
            },
          ),
        ],
      ),
    );
  }
}

class ContentLoader {
  static Future<String> loadContent(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        return response.body;
      } else {
        throw Exception('Failed to load content');
      }
    } catch (e) {
      throw Exception('Error loading content: $e');
    }
  }
}

class Chapter {
  final String title;
  final String contentUrl;
  String? content;

  Chapter({
    required this.title,
    required this.contentUrl,
  });

  Future<void> loadContent() async {
    content = await ContentLoader.loadContent(contentUrl);
  }
}

class TopicsScreen extends StatefulWidget {
  const TopicsScreen({super.key});

  @override
  State<TopicsScreen> createState() => _TopicsScreenState();
}

class _TopicsScreenState extends State<TopicsScreen> {
  final List<Chapter> chapters = [
    Chapter(
      title: 'Setup',
      contentUrl:
      'https://raw.githubusercontent.com/RiccardoEvangelisti/Four-Souls-FAQ/refs/heads/main/content/1.setup.md',
    ),
    Chapter(
      title: 'Card Types',
      contentUrl:
      'https://raw.githubusercontent.com/RiccardoEvangelisti/Four-Souls-FAQ/refs/heads/main/content/2.card_types.md',
    ),
    // Aggiungi altri capitoli secondo necessità
  ];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAllContent();
  }

  Future<void> _loadAllContent() async {
    try {
      await Future.wait(
        chapters.map((chapter) => chapter.loadContent()),
      );
    } catch (e) {
      // Gestisci l'errore
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView.builder(
      itemCount: chapters.length,
      itemBuilder: (context, index) {
        return ChapterCard(chapter: chapters[index]);
      },
    );
  }
}

class ChapterCard extends StatelessWidget {
  final Chapter chapter;

  const ChapterCard({super.key, required this.chapter});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: ExpansionTile(
        title: Text(
          chapter.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: MarkdownBody(
              data: chapter.content ?? 'Contenuto non disponibile',
              selectable: true,
            ),
          ),
        ],
      ),
    );
  }
}

class FAQScreen extends StatefulWidget {
  const FAQScreen({super.key});

  @override
  State<FAQScreen> createState() => _FAQScreenState();
}

class _FAQScreenState extends State<FAQScreen> {
  final List<Chapter> faqs = [
    Chapter(
      title: 'Come si usa l\'applicazione?',
      contentUrl:
      'https://raw.githubusercontent.com/RiccardoEvangelisti/Four-Souls-FAQ/refs/heads/main/content/faqs/faq1.md',
    ),
    // Aggiungi altre FAQ secondo necessità
  ];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAllContent();
  }

  Future<void> _loadAllContent() async {
    try {
      await Future.wait(
        faqs.map((faq) => faq.loadContent()),
      );
    } catch (e) {
      // Gestisci l'errore
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView.builder(
      itemCount: faqs.length,
      itemBuilder: (context, index) {
        return ChapterCard(chapter: faqs[index]);
      },
    );
  }
}

class CardsErrataScreen extends StatefulWidget {
  const CardsErrataScreen({super.key});

  @override
  State<CardsErrataScreen> createState() => _CardsErrataScreenState();
}

class _CardsErrataScreenState extends State<CardsErrataScreen> {
  final List<Chapter> errata = [
    Chapter(
      title: 'Errata Corrige - Versione 1.0',
      contentUrl:
      'https://raw.githubusercontent.com/RiccardoEvangelisti/Four-Souls-FAQ/refs/heads/main/content/errata/errata1.md',
    ),
    // Aggiungi altri errata secondo necessità
  ];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAllContent();
  }

  Future<void> _loadAllContent() async {
    try {
      await Future.wait(
        errata.map((e) => e.loadContent()),
      );
    } catch (e) {
      // Gestisci l'errore
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView.builder(
      itemCount: errata.length,
      itemBuilder: (context, index) {
        return ChapterCard(chapter: errata[index]);
      },
    );
  }
}