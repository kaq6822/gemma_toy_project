import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/model_repository.dart';

final modelRepositoryProvider = Provider<ModelRepository>((ref) {
  return ModelRepository();
});

enum ModelStatus { notDownloaded, downloading, ready, error }

class ModelState {
  final ModelStatus status;
  final double downloadProgress;
  final String? errorMessage;
  final String? activeModelId;

  const ModelState({
    this.status = ModelStatus.notDownloaded,
    this.downloadProgress = 0.0,
    this.errorMessage,
    this.activeModelId,
  });

  ModelState copyWith({
    ModelStatus? status,
    double? downloadProgress,
    String? errorMessage,
    String? activeModelId,
  }) {
    return ModelState(
      status: status ?? this.status,
      downloadProgress: downloadProgress ?? this.downloadProgress,
      errorMessage: errorMessage,
      activeModelId: activeModelId ?? this.activeModelId,
    );
  }
}

final modelStateProvider =
    NotifierProvider<ModelNotifier, ModelState>(ModelNotifier.new);

class ModelNotifier extends Notifier<ModelState> {
  @override
  ModelState build() {
    return const ModelState();
  }

  Future<void> initializeAndLoadModel(String modelId,
      {int maxTokens = 1024}) async {
    try {
      final repo = ref.read(modelRepositoryProvider);
      await repo.initializeGemma();

      state = state.copyWith(
        status: ModelStatus.ready,
        activeModelId: modelId,
      );
    } catch (e) {
      state = state.copyWith(
        status: ModelStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> installModel(GemmaModel model, String url) async {
    state = state.copyWith(
      status: ModelStatus.downloading,
      downloadProgress: 0.0,
    );
    try {
      final repo = ref.read(modelRepositoryProvider);
      await repo.installModelFromUrl(
        model: model,
        url: url,
        onProgress: (progress) {
          state = state.copyWith(downloadProgress: progress);
        },
      );
      state = state.copyWith(
        status: ModelStatus.ready,
        downloadProgress: 1.0,
        activeModelId: model.id,
      );
    } catch (e) {
      state = state.copyWith(
        status: ModelStatus.error,
        errorMessage: e.toString(),
      );
    }
  }
}
