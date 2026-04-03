import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sharedPreferencesProvider = Provider<SharedPreferencesAsync>((ref) {
  return SharedPreferencesAsync();
});

final darkModeProvider = NotifierProvider<DarkModeNotifier, bool>(
  DarkModeNotifier.new,
);

class DarkModeNotifier extends Notifier<bool> {
  @override
  bool build() {
    _load();
    return false;
  }

  Future<void> _load() async {
    final prefs = ref.read(sharedPreferencesProvider);
    final value = await prefs.getBool('dark_mode') ?? false;
    state = value;
  }

  Future<void> toggle() async {
    state = !state;
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setBool('dark_mode', state);
  }
}

final selectedModelProvider = NotifierProvider<SelectedModelNotifier, String>(
  SelectedModelNotifier.new,
);

class SelectedModelNotifier extends Notifier<String> {
  @override
  String build() {
    _load();
    return 'gemma-3-1b';
  }

  Future<void> _load() async {
    final prefs = ref.read(sharedPreferencesProvider);
    final value = await prefs.getString('selected_model') ?? 'gemma-3-1b';
    state = value;
  }

  Future<void> setModel(String model) async {
    state = model;
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setString('selected_model', model);
  }
}

final maxTokensProvider = NotifierProvider<MaxTokensNotifier, int>(
  MaxTokensNotifier.new,
);

class MaxTokensNotifier extends Notifier<int> {
  @override
  int build() {
    _load();
    return 1024;
  }

  Future<void> _load() async {
    final prefs = ref.read(sharedPreferencesProvider);
    final value = await prefs.getInt('max_tokens') ?? 1024;
    state = value;
  }

  Future<void> setMaxTokens(int tokens) async {
    state = tokens;
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setInt('max_tokens', tokens);
  }
}
