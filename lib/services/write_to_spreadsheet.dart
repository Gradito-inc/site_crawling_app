import 'dart:convert';

// import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:googleapis/sheets/v4.dart';
import 'package:googleapis_auth/auth_io.dart';

enum SiteType { green, doda }

// ignore: lines_longer_than_80_chars
Future<void> writeToSpreadsheet({required SiteType siteType, required List<String> companyList}) async {
  var sheetName = '';
  switch (siteType) {
    case SiteType.green:
      sheetName = 'Green';
    case SiteType.doda:
      sheetName = 'Doda';
  }

  await dotenv.load(
    fileName: '/Users/tsubasa.kogoma/development/site_crawling_app/.env',
  );

  final rawJson = dotenv.env['SERVICE_ACCOUNT_JSON']!;
  final jsonCredentials = jsonDecode(rawJson) as Map<String, dynamic>;

  final credentials = await clientViaServiceAccount(
    ServiceAccountCredentials.fromJson(jsonCredentials),
    ['https://www.googleapis.com/auth/spreadsheets'],
  );

  final api = SheetsApi(credentials);
  // Spreadsheet ID and the range to write data.
  final spreadsheetId = dotenv.env['YOUR_SPREADSHEET_ID']!;

  // データ読み取り
  final readRange = '$sheetName!A2:A';
  final response = await api.spreadsheets.values.get(spreadsheetId, readRange);
  final values = response.values;
  var lastRow = 2;
  if (values != null && values.isNotEmpty) {
    lastRow = values.length + 1;
  }

  // 記載済みの値を削除する
  if (values != null) {
    // ignore: lines_longer_than_80_chars
    final existingCompanies = values.where((row) => row.isNotEmpty && row[0] != null).map((row) => row[0]).toSet();
    companyList.removeWhere(existingCompanies.contains);
  }

  // Write data
  final range = '$sheetName!A${lastRow + 1}:A${lastRow + companyList.length}';

  // Data to write
  final companyValues = companyList.map((item) => [item]).toList();
  final valueRange = ValueRange.fromJson({
    'range': range,
    'values': companyValues,
  });

  await api.spreadsheets.values
      .update(valueRange, spreadsheetId, range, valueInputOption: 'RAW')
      .then((result) {});
}
