import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:html/parser.dart' as parser;
import 'package:html/parser.dart';
import 'package:http/http.dart' as http;

class DodaPage extends HookConsumerWidget {
  const DodaPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = useTextEditingController();
    final companies = useState(<String>[]);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                final result = await fetchData(controller.text);
                if (result.isNotEmpty) {
                  companies.value = result;
                }
              },
              child: const Text('検索'),
            ),
          ],
        ),
      ),
      body: Center(
        child: ListView(
          children: companies.value.map(Text.new).toList(),
        ),
      ),
    );
  }

  Future<void> getJobListings(String baseUrl, String keyword) async {
    var page = 1;
    var hasNextPage = true;

    while (hasNextPage) {
      final url = '$baseUrl/search?keyword=$keyword&page=$page';

      try {
        final dio = Dio();
        final response = await dio.get(url);
        final document = parser.parse(response.data);

        log('${document.body?.text}');

        // ここでデータ抽出ロジックを実装...

        // 次のページが存在するか確認
        final nextButton = document.querySelector('...'); // 適切なセレクタを指定
        hasNextPage = nextButton != null;

        // 次のページへ
        page++;
      } on Exception catch (e) {
        log(e.toString());
        hasNextPage = false; // エラー発生時には終了
      }
    }
  }

  Future<List<String>> fetchData(String keyword) async {
    try {
      final response = await http.get(Uri.parse(
          'https://doda.jp/DodaFront/View/JobSearchList/j_oc__03L/-preBtn__3/?usrclk=PC_logout_kyujinSearchOccupationArea_shokushuDetail_engineer'));
      if (response.statusCode == 200) {
        final document = parse(response.body);
        final layouts = document.querySelectorAll('.layout');
        final companyNames = <String>[];
        for (final company in layouts) {
          if (company.querySelector('.middle')?.text.contains(keyword) ??
              false) {
            log(company.querySelector('.middle')!.text);

            final companyName = company.querySelector('.company')?.text ?? '';
            log('Company found: $companyName');
            companyNames.add(companyName);
          }
        }
        return companyNames;
      } else {
        log('Failed to load data');
        return [];
      }
    } on Exception catch (e) {
      log('Error: $e');
      return [];
    }
  }
}

const selectors = [
  '#shStart > div > div > div.middle.clrFix > div.box01 > dl:nth-child(1)',
  '#shStart > div > div > div.middle.clrFix > div.box01 > dl:nth-child(2)',
  '#shStart > div > div > div.middle.clrFix > div.box01 > dl:nth-child(3)',
  '#shStart > div > div > div.middle.clrFix > div.box01 > dl:nth-child(4)',
  '#shStart > div > div > div.middle.clrFix > div.box01 > dl:nth-child(5)',
  '#shStart > div > div > div.middle.clrFix > div.box01 > dl:nth-child(6)',
];
