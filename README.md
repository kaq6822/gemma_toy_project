# Gemma Chat

Google Gemma 모델을 on-device로 실행하는 Flutter AI 채팅봇 앱입니다.

## 주요 기능

- **Gemma 대화** - On-device에서 Gemma 모델과 실시간 스트리밍 대화
- **멀티모달 지원** - 이미지를 첨부하여 Gemma3n 모델에 질문 (Gemma3n E2B/E4B)
- **파일 업로드** - PDF, TXT, DOC 파일 첨부
- **대화 세션 관리** - 새 대화 생성, 세션 간 전환, 삭제
- **모델 선택** - 설정에서 AI 모델 변경 가능
- **다크 모드** - 라이트/다크 테마 지원

## 지원 모델

| 모델 | 파라미터 | 멀티모달 |
|------|----------|----------|
| Gemma 3 1B | 1B | 텍스트 전용 |
| Gemma3n E2B | 2B | 텍스트 + 이미지 |
| Gemma3n E4B | 4B | 텍스트 + 이미지 |
| Gemma 4 E2B | 2B | 텍스트 전용 |

## 기술 스택

| 영역 | 패키지 |
|------|--------|
| AI 추론 | `flutter_gemma` ^0.13.0 |
| 상태관리 | `flutter_riverpod` ^3.3.1 |
| 로컬 DB | `drift` ^2.32.1 |
| 네비게이션 | `go_router` ^17.2.0 |
| 이미지 선택 | `image_picker` ^1.2.1 |
| 파일 선택 | `file_picker` ^10.3.10 |
| 설정 저장 | `shared_preferences` ^2.3.4 |

## 프로젝트 구조

```
lib/
├── main.dart                     # 앱 진입점
├── app.dart                      # MaterialApp 설정
├── router/app_router.dart        # GoRouter 라우트
├── core/
│   ├── database/app_database.dart  # Drift DB (chat_sessions, messages)
│   ├── providers/                  # DB 프로바이더
│   └── theme/app_theme.dart        # Material 3 테마
├── features/
│   ├── chat/                     # 채팅 기능
│   ├── sessions/                 # 세션 관리
│   ├── settings/                 # 설정 화면
│   └── model_manager/            # 모델 다운로드/관리
└── shared/widgets/               # 공용 위젯
```

## 시작하기

### 요구 사항

- Flutter 3.29+
- Dart 3.7+
- Android: minSdk 24 (Android 7.0+)
- iOS: 16.0+

### 설치 및 실행

```bash
# 의존성 설치
flutter pub get

# Drift 코드 생성
dart run build_runner build --delete-conflicting-outputs

# 실행
flutter run
```

### 모델 설정

앱 실행 후 Gemma 모델 `.task` 파일이 필요합니다.

1. [LiteRT Community HuggingFace](https://huggingface.co/litert-community)에서 모델 다운로드
2. 앱 내 모델 다운로드 화면에서 모델 URL 입력
3. 다운로드 완료 후 대화 시작

## 참고 사항

- 모델 파일은 1~4GB로, Wi-Fi 환경에서 다운로드를 권장합니다
- 멀티모달 입력은 Gemma3n 모델에서만 지원됩니다
- 추천 기기: Android Pixel 7+ / iOS iPhone 13+
- 에뮬레이터에서는 실행이 지원되지 않습니다 (실제 기기 필요)
