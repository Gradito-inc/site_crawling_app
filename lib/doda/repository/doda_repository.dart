import 'dart:developer';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:html/parser.dart';
import 'package:http/http.dart' as http;
import 'package:site_crawling_app/doda/data/doda_parse.dart';

final dodaRepositoryProvider = Provider<DodaRepository>(
  DodaRepositoryImpl.new,
);

// ignore: one_member_abstracts
abstract class DodaRepository {
  Future<List<String>> fetchData(String keyword);
}

class DodaRepositoryImpl implements DodaRepository {
  DodaRepositoryImpl(this.ref);

  final Ref ref;

  // キーワード一致した求人情報リスト(企業名)を取得する
  @override
  Future<List<String>> fetchData(String keyword) async {
    // 企業名リスト
    final companyNames = <String>[];

    final result = await _getCompanies(DodaParse.initialUrl, keyword);
    companyNames.addAll(result);

    return companyNames;
  }

  // 1ページごとに企業名リストを取得する
  Future<List<String>> _getCompanies(String url, String keyword) async {
    final companyNames = <String>[];
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final document = parse(response.body);
      // 企業情報リスト
      final companies = document.querySelectorAll('.layout');

      // 企業ごとに抽出を行う
      for (final company in companies) {
        // 企業IDを抽出する
        final companyUrl =
            company.querySelector('._JobListToDetail')?.attributes['href'] ??
                '';
        final regex = RegExp(r'j_jid__([\d]+)');
        final companyId = regex.firstMatch(companyUrl)?.group(1) ?? '';
        log('company id: $companyId');

        if (companyId.isNotEmpty) {
          // キーワードにマッチするかどうか
          final isMatch = await _containsKeyword(companyId, keyword);
          if (isMatch) {
            // マッチしたら企業名を保存
            final companyName = company.querySelector('.company')?.text ?? '';
            log('Company found: $companyName');
            companyNames.add(companyName);
          }
        }
      }

      // 次ページがあるかどうか
      final nextBtn = document.querySelector('.btn_r.last');
      final nextUrl = nextBtn?.querySelector('a')?.attributes['href'];
      if (nextUrl != null) {
        final result = await _getCompanies(nextUrl, keyword);
        companyNames.addAll(result);
      }
    } else {
      log('Failed to load data');
    }
    return companyNames;
  }

  // 企業情報がキーワードにマッチするか判定する
  Future<bool> _containsKeyword(String id, String keyword) async {
    final response = await http.get(Uri.parse(DodaParse.getDetailUrl(id)));
    log('text : ${DodaParse.getDetailUrl(id)}');
    if (response.statusCode == 200) {
      final document = parse(response.body);
      // 企業情報テキスト
      final contentText =
          document.querySelector('.recruitment_area')?.text ?? '';

      return contentText.contains(keyword);
    } else {
      log('Failed to load data');
      return false;
    }
  }
}
