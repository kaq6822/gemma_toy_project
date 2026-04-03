import 'package:flutter_gemma/flutter_gemma.dart';

class GemmaModel {
  final String id;
  final String name;
  final String description;
  final String downloadUrl;
  final bool isMultimodal;
  final ModelType modelType;

  const GemmaModel({
    required this.id,
    required this.name,
    required this.description,
    required this.downloadUrl,
    required this.modelType,
    this.isMultimodal = false,
  });
}

class ModelRepository {
  static const List<GemmaModel> supportedModels = [
    GemmaModel(
      id: 'gemma-3-1b',
      name: 'Gemma 3 1B',
      description: '텍스트 전용, 가벼운 모델 (1B 파라미터)',
      downloadUrl: '',
      modelType: ModelType.gemmaIt,
    ),
    GemmaModel(
      id: 'gemma3n-e2b',
      name: 'Gemma3n E2B',
      description: '멀티모달 (텍스트+이미지), 2B 파라미터',
      downloadUrl: '',
      modelType: ModelType.gemmaIt,
      isMultimodal: true,
    ),
    GemmaModel(
      id: 'gemma3n-e4b',
      name: 'Gemma3n E4B',
      description: '멀티모달 고성능 (텍스트+이미지), 4B 파라미터',
      downloadUrl: '',
      modelType: ModelType.gemmaIt,
      isMultimodal: true,
    ),
    GemmaModel(
      id: 'gemma-4-e2b',
      name: 'Gemma 4 E2B',
      description: '최신 세대, 2B 파라미터',
      downloadUrl: '',
      modelType: ModelType.gemmaIt,
    ),
  ];

  static GemmaModel? getModelById(String id) {
    try {
      return supportedModels.firstWhere((m) => m.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> initializeGemma() async {
    await FlutterGemma.initialize();
  }

  Future<bool> isModelInstalled(String modelId) async {
    return await FlutterGemma.isModelInstalled(modelId);
  }

  Future<List<String>> listInstalledModels() async {
    return await FlutterGemma.listInstalledModels();
  }

  Future<void> installModelFromUrl({
    required GemmaModel model,
    required String url,
    void Function(double progress)? onProgress,
  }) async {
    await FlutterGemma.installModel(
      modelType: model.modelType,
    ).fromNetwork(url).install();
  }
}
