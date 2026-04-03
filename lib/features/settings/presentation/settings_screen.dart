import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../model_manager/data/model_repository.dart';
import 'settings_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(darkModeProvider);
    final selectedModel = ref.watch(selectedModelProvider);
    final maxTokens = ref.watch(maxTokensProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('설정')),
      body: ListView(
        children: [
          _buildSectionHeader(context, 'AI 모델'),
          ...ModelRepository.supportedModels.map((model) {
            final isSelected = selectedModel == model.id;
            return ListTile(
              leading: Icon(
                isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                color: isSelected ? Theme.of(context).colorScheme.primary : null,
              ),
              title: Row(
                children: [
                  Text(model.name),
                  if (model.isMultimodal) ...[
                    const SizedBox(width: 8),
                    Chip(
                      label: const Text('멀티모달'),
                      labelStyle: const TextStyle(fontSize: 10),
                      padding: EdgeInsets.zero,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ],
              ),
              subtitle: Text(model.description),
              trailing: isSelected
                  ? Icon(Icons.check_circle,
                      color: Theme.of(context).colorScheme.primary)
                  : null,
              onTap: () {
                ref.read(selectedModelProvider.notifier).setModel(model.id);
              },
            );
          }),
          const Divider(),
          _buildSectionHeader(context, '모델 관리'),
          ListTile(
            leading: const Icon(Icons.download),
            title: const Text('모델 다운로드'),
            subtitle: const Text('Gemma 모델 파일을 다운로드합니다'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/model-download'),
          ),
          const Divider(),
          _buildSectionHeader(context, '생성 설정'),
          ListTile(
            leading: const Icon(Icons.token),
            title: const Text('최대 토큰 수'),
            subtitle: Text('$maxTokens 토큰'),
            trailing: SizedBox(
              width: 200,
              child: Slider(
                value: maxTokens.toDouble(),
                min: 256,
                max: 4096,
                divisions: 15,
                label: '$maxTokens',
                onChanged: (value) {
                  ref
                      .read(maxTokensProvider.notifier)
                      .setMaxTokens(value.round());
                },
              ),
            ),
          ),
          const Divider(),
          _buildSectionHeader(context, '외관'),
          SwitchListTile(
            secondary: const Icon(Icons.dark_mode),
            title: const Text('다크 모드'),
            value: isDarkMode,
            onChanged: (_) {
              ref.read(darkModeProvider.notifier).toggle();
            },
          ),
          const Divider(),
          _buildSectionHeader(context, '정보'),
          const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('Gemma Chat'),
            subtitle: Text('v1.0.0 - On-device AI chatbot powered by Gemma'),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
      ),
    );
  }
}
