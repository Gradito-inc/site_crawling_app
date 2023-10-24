import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:html/parser.dart' show parse;
import 'package:http/http.dart' as http;
import '../services/write_to_spreadsheet.dart';

final searchProvider = FutureProvider.autoDispose.family<List<String>, String>(
  (ref, query) async {
    final urlString = 'https://www.green-japan.com/search_key?keyword=$query';
    final url = Uri.parse(urlString);
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final document = parse(response.body);
      final companyNames = <String>[];
      for (final element in document.querySelectorAll('h3')) {
        final text = element.text;
        if (text.contains('株式会社')) {
          companyNames.add(text);
        }
      }
      unawaited(
        writeToSpreadsheet(
          siteType: SiteType.green,
          companyList: companyNames,
        ),
      );
      return companyNames;
    }
    return [''];
  },
);

final isRefreshingProvider = StateProvider<bool>((ref) => false);

class GreenScreen extends HookConsumerWidget {
  const GreenScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textController = useTextEditingController();
    final searchResponse = ref.watch(searchProvider(textController.text));
    ref.listen(searchProvider(textController.text), (previous, next) {
      ref.read(isRefreshingProvider.notifier).state = next.isRefreshing;
    });
    final isRefreshing = ref.watch(isRefreshingProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Green'),
      ),
      body: Column(
        children: <Widget>[
          TextField(
            controller: textController,
            decoration: const InputDecoration(labelText: 'Enter Keyword'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(isRefreshingProvider.notifier).state = true;
              // ignore: unused_result
              ref.refresh(searchProvider(textController.text));
            },
            child: const Text('検索'),
          ),
          isRefreshing
              ? const CircularProgressIndicator()
              : searchResponse.when(
                  data: (items) {
                    return Expanded(
                      child: ListView.builder(
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          return ListTile(title: Text(items[index]));
                        },
                      ),
                    );
                  },
                  error: (error, stackTrace) => Text('Error: $error'),
                  loading: () => const CircularProgressIndicator(),
                ),
        ],
      ),
    );
  }
}
