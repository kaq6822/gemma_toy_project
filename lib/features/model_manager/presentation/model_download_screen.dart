import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/model_repository.dart';
import 'model_provider.dart';

class ModelDownloadScreen extends ConsumerWidget {
  const ModelDownloadScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final modelState = ref.watch(modelStateProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('모델 다운로드')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Gemma 모델을 선택하세요',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              '모델 파일은 기기에 다운로드됩니다. Wi-Fi 환경에서 다운로드를 권장합니다.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ListView.builder(
                itemCount: ModelRepository.supportedModels.length,
                itemBuilder: (context, index) {
                  final model = ModelRepository.supportedModels[index];
                  final isActive = modelState.activeModelId == model.id;
                  final isDownloading =
                      modelState.status == ModelStatus.downloading;

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: Icon(
                        model.isMultimodal
                            ? Icons.image_search
                            : Icons.text_fields,
                        color: isActive
                            ? Theme.of(context).colorScheme.primary
                            : null,
                      ),
                      title: Text(model.name),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(model.description),
                          if (model.isMultimodal)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Chip(
                                label: const Text('멀티모달'),
                                labelStyle: const TextStyle(fontSize: 11),
                                padding: EdgeInsets.zero,
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                                visualDensity: VisualDensity.compact,
                              ),
                            ),
                        ],
                      ),
                      trailing: isActive
                          ? const Icon(Icons.check_circle, color: Colors.green)
                          : isDownloading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.download),
                      onTap: isDownloading
                          ? null
                          : () {
                              ref
                                  .read(modelStateProvider.notifier)
                                  .initializeAndLoadModel(model.id);
                            },
                    ),
                  );
                },
              ),
            ),
            if (modelState.status == ModelStatus.downloading) ...[
              LinearProgressIndicator(value: modelState.downloadProgress),
              const SizedBox(height: 8),
              Text(
                '다운로드 중... ${(modelState.downloadProgress * 100).toStringAsFixed(0)}%',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
            if (modelState.status == ModelStatus.error)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  modelState.errorMessage ?? '오류가 발생했습니다',
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.error),
                ),
              ),
            if (modelState.status == ModelStatus.ready)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => context.go('/'),
                    child: const Text('대화 시작하기'),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
