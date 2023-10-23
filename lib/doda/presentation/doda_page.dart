import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:site_crawling_app/doda/presentation/common/doda_loading.dart';
import 'package:site_crawling_app/doda/presentation/doda_controller.dart';

class DodaPage extends HookConsumerWidget {
  const DodaPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = useTextEditingController();
    final companies = useState<List<String>>(<String>[]);
    final isLoading = ref.watch(dodaLoadingProvider);

    ref.listen<AsyncValue<List<String>>>(dodaController, (_, next) async {
      final loadingNotifier = ref.read(dodaLoadingProvider.notifier);

      if (next.isLoading) {
        loadingNotifier.show();
      }
      next.when(
        data: (data) async {
          log('$data');
          companies.value = data;
          loadingNotifier.hide();
        },
        error: (e, s) async {
          loadingNotifier.hide();
        },
        loading: loadingNotifier.show,
      );
    });

    useEffect(
      () {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          // 全企業を取得する(コメントアウト外す)
          // ref.read(dodaController.notifier).fetchData('');
        });
        return null;
      },
      [],
    );

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
                await ref
                    .read(dodaController.notifier)
                    .fetchData(controller.text);
              },
              child: const Text('検索'),
            ),
          ],
        ),
      ),
      body: isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('企業情報取得中'),
                ],
              ),
            )
          : Center(
              child: ListView(
                children: companies.value.map(Text.new).toList(),
              ),
            ),
    );
  }
}
