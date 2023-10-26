import 'dart:async';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:site_crawling_app/doda/repository/doda_repository.dart';

final dodaController =
    AsyncNotifierProvider<DodaController, List<String>>(DodaController.new);

class DodaController extends AsyncNotifier<List<String>> {
  @override
  FutureOr<List<String>> build() => [];

  Future<void> fetchData(String keyword) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      return ref.read(dodaRepositoryProvider).fetchData(keyword);
    });
  }
}
