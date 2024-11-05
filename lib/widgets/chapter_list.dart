import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../providers/rules_provider.dart';

class ChapterList extends StatelessWidget {
  final ScrollController scrollController;

  const ChapterList({
    super.key,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<RulesProvider>(
      builder: (context, rulesProvider, _) {
        return ListView.builder(
          controller: scrollController,
          addAutomaticKeepAlives: false,
          addRepaintBoundaries: true,
          itemCount: rulesProvider.chapters.length,
          itemBuilder: (context, index) {
            final chapter = rulesProvider.chapters[index];
            return Card(
              margin: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ListTile(
                    title: Text(chapter.title),
                    trailing: Icon(
                      chapter.isExpanded
                          ? Icons.expand_less
                          : Icons.expand_more,
                    ),
                    onTap: () => rulesProvider.toggleChapter(index),
                  ),
                  if (chapter.isExpanded)
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: MarkdownBody(
                        data: chapter.content,
                        selectable: true,
                        styleSheet: MarkdownStyleSheet(
                          code: const TextStyle(
                              color: Colors.black,
                              backgroundColor: Colors.yellow),
                          codeblockPadding: const EdgeInsets.all(8),
                          codeblockDecoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            color: Colors.yellow,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
