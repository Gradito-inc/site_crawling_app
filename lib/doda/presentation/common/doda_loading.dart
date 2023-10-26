import 'package:hooks_riverpod/hooks_riverpod.dart';

// dodaページのローディング
final dodaLoadingProvider = NotifierProvider<DodaLoadingNotifier, bool>(
  DodaLoadingNotifier.new,
);

class DodaLoadingNotifier extends Notifier<bool> {
  @override
  bool build() => false;
  void show() => state = true;
  void hide() => state = false;
}
