import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:html/parser.dart' show parse;
import 'package:http/http.dart' as http;
import '../services/write_to_spreadsheet.dart';

final searchProvider = FutureProvider.autoDispose.family<List<String>, String>(
  (ref, query) async {
    final urls = [
      http.get(
          Uri.parse('https://www.green-japan.com/search_key?keyword=$query')),
      http.get(Uri.parse(
          'https://www.green-japan.com/search_key?keyword=$query&page=2')),
      http.get(Uri.parse(
          'https://www.green-japan.com/search_key?keyword=$query&page=3')),
      http.get(Uri.parse(
          'https://www.green-japan.com/search_key?keyword=$query&page=4')),
      http.get(Uri.parse(
          'https://www.green-japan.com/search_key?keyword=$query&page=5')),
      http.get(Uri.parse(
          'https://www.green-japan.com/search_key?keyword=$query&page=6')),
      http.get(Uri.parse(
          'https://www.green-japan.com/search_key?keyword=$query&page=7')),
      http.get(Uri.parse(
          'https://www.green-japan.com/search_key?keyword=$query&page=8')),
      http.get(Uri.parse(
          'https://www.green-japan.com/search_key?keyword=$query&page=9')),
      http.get(Uri.parse(
          'https://www.green-japan.com/search_key?keyword=$query&page=10')),
    ];

    final responses = await Future.wait(urls);
    final companyNames = <String>[];

    for (final response in responses) {
      if (response.statusCode == 200) {
        final document = parse(response.body);
        final companyList = <String>[];
        for (final element in document.querySelectorAll('h3')) {
          final text = element.text;
          if (text.contains('株式会社')) {
            companyList.add(text);
          }
        }
        companyNames.addAll(companyList);
        await writeToSpreadsheet(siteType: SiteType.green, companyList: companyList);
      }
    }
    return companyNames;
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
