import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../providers/rules_provider.dart';
import '../widgets/search_bar.dart';
import '../widgets/chapter_list.dart';

class ExtendedRulesScreen extends StatefulWidget {
  const ExtendedRulesScreen({super.key});

  @override
  State<ExtendedRulesScreen> createState() => _ExtendedRulesScreenState();
}

class _ExtendedRulesScreenState extends State<ExtendedRulesScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<RulesProvider>(context, listen: false).loadLocalChapters());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Extended Rules'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              Provider.of<RulesProvider>(context, listen: false).fetchChapters();
            },
            tooltip: 'Refresh rules from GitHub',
          ),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(60),
          child: CustomSearchBar(),
        ),
      ),
      body: Consumer<RulesProvider>(
        builder: (context, rulesProvider, child) {
          if (rulesProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          return ChapterList(scrollController: _scrollController);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Provider.of<RulesProvider>(context, listen: false).closeAllChapters();
        },
        child: const Icon(Icons.close),
        tooltip: 'Close all chapters',
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}