import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:html/parser.dart' show parse;
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import '../services/write_to_spreadsheet.dart';

final searchProvider = FutureProvider.autoDispose.family<List<String>, String>(
  (ref, keyword) async {
    const tokyo = 'key=8syc6rza0fz6n3zko4hw';
    const kanagawa = 'key=dmapq71capkeg45zvgyp';
    const chiba = 'key=rr6emffiqqg06s5usioz';
    const saitama = 'key=okg8k28ujmfsw4ixefiz';

    final tokyoUrls = _getUrls(prefecture: tokyo, keyword: keyword);
    final kanagawaUrls = _getUrls(prefecture: kanagawa, keyword: keyword);
    final chibaUrls = _getUrls(prefecture: chiba, keyword: keyword);
    final saitamaUrls = _getUrls(prefecture: saitama, keyword: keyword);

    final companyList = <String>[];

    final tokyoCompanyList = await _fetchResponse(urls: tokyoUrls);
    companyList.addAll(tokyoCompanyList);
    final kanagawaCompanyList = await _fetchResponse(urls: kanagawaUrls);
    companyList.addAll(kanagawaCompanyList);
    final chibaCompanyList = await _fetchResponse(urls: chibaUrls);
    companyList.addAll(chibaCompanyList);
    final saitamaCompanyList = await _fetchResponse(urls: saitamaUrls);
    companyList.addAll(saitamaCompanyList);

    return companyList;
  },
);

Future<List<String>> _fetchResponse({required List<Future<Response>> urls}) async {
  final responses = await Future.wait(urls);
  final companyList = <String>[];

  for (final response in responses) {
    if (response.statusCode == 200) {
      final document = parse(response.body);
      for (final element in document.querySelectorAll('h3')) {
        final text = element.text;
        if (text.contains('株式会社')) {
          companyList.add(text);
        }
      }
      // ignore: lines_longer_than_80_chars
      await writeToSpreadsheet(siteType: SiteType.green, companyList: companyList);
    }
  }
  return companyList;
}

List<Future<Response>> _getUrls(
    {required String prefecture, required String keyword}) {
  return [
    http.get(Uri.parse(
        'https://www.green-japan.com/search_key?$prefecture&keyword=$keyword')),
    http.get(Uri.parse(
        'https://www.green-japan.com/search_key?$prefecture&keyword=$keyword&page=2')),
    http.get(Uri.parse(
        'https://www.green-japan.com/search_key?$prefecture&keyword=$keyword&page=3')),
    http.get(Uri.parse(
        'https://www.green-japan.com/search_key?$prefecture&keyword=$keyword&page=4')),
    http.get(Uri.parse(
        'https://www.green-japan.com/search_key?$prefecture&keyword=$keyword&page=5')),
    http.get(Uri.parse(
        'https://www.green-japan.com/search_key?$prefecture&keyword=$keyword&page=6')),
    http.get(Uri.parse(
        'https://www.green-japan.com/search_key?$prefecture&keyword=$keyword&page=7')),
    http.get(Uri.parse(
        'https://www.green-japan.com/search_key?$prefecture&keyword=$keyword&page=8')),
    http.get(Uri.parse(
        'https://www.green-japan.com/search_key?$prefecture&keyword=$keyword&page=9')),
    http.get(Uri.parse(
        'https://www.green-japan.com/search_key?$prefecture&keyword=$keyword&page=10')),
    http.get(Uri.parse(
        'https://www.green-japan.com/search_key?$prefecture&keyword=$keyword&page=11')),
    http.get(Uri.parse(
        'https://www.green-japan.com/search_key?$prefecture&keyword=$keyword&page=12')),
    http.get(Uri.parse(
        'https://www.green-japan.com/search_key?$prefecture&keyword=$keyword&page=13')),
    http.get(Uri.parse(
        'https://www.green-japan.com/search_key?$prefecture&keyword=$keyword&page=14')),
    http.get(Uri.parse(
        'https://www.green-japan.com/search_key?$prefecture&keyword=$keyword&page=15')),
  ];
}

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
