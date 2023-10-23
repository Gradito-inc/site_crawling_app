import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:html/parser.dart' show parse;

final searchProvider = FutureProvider.autoDispose.family<List<String>, String>(
  (ref, query) async {
    const urlString = 'https://www.green-japan.com/search_key?key=vdjgfsxscaxvtfi8fejf&keyword=%E3%83%97%E3%83%AD%E3%82%B0%E3%83%A9%E3%83%9F%E3%83%B3%E3%82%B0';
    final url = Uri.parse(urlString);
    final response = await http.get(url);
    if (response.statusCode == 200) {

      var document = parse(response.body);
      List<String> companyNames = [];
      for (var element in document.querySelectorAll('h3')) {
        final text = element.text;
        if (text.contains('株式会社')) {
          companyNames.add(text);
        }
      }
      print("株式会社の配列: $companyNames");
    }
    return ['text1'];
  },
  
);

class GreenScreen extends HookConsumerWidget {
  const GreenScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textController = useTextEditingController();
    final searchResponse = ref.watch(searchProvider(textController.text));

    return Scaffold(
      appBar: AppBar(
        title: const Text('リクナビ'),
      ),
      body: Column(
        children: [
          TextField(
            controller: textController,
            decoration: const InputDecoration(labelText: 'Enter Keyword'),
          ),
          ElevatedButton(
            onPressed: () {
              // ignore: unused_result
              ref.refresh(searchProvider(textController.text));
              // textController.value = TextEditingValue(
              //   text: textController.text,
              //   selection: textController.selection,
              // );
            },
            child: const Text('検索'),
          ),
          searchResponse.when(
            data: (items) => const Text('データ表示'),
            error: (error, stackTrace) => Text('Error: $error'),
            loading: () => const CircularProgressIndicator(),
          ),
        ],
      ),
    );
  }
}
