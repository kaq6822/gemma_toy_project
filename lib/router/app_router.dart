import 'package:go_router/go_router.dart';
import '../features/chat/presentation/chat_screen.dart';
import '../features/settings/presentation/settings_screen.dart';
import '../features/model_manager/presentation/model_download_screen.dart';
import '../features/sessions/presentation/session_list_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SessionListScreen(),
    ),
    GoRoute(
      path: '/chat/:sessionId',
      builder: (context, state) {
        final sessionId = int.parse(state.pathParameters['sessionId']!);
        return ChatScreen(sessionId: sessionId);
      },
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: '/model-download',
      builder: (context, state) => const ModelDownloadScreen(),
    ),
  ],
);
