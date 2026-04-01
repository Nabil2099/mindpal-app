import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:mindpal_app/constants.dart';
import 'package:mindpal_app/features/chat/domain/models.dart';
import 'package:mindpal_app/shared/providers/core_providers.dart';

part 'chat_repository.g.dart';

class ChatRepository {
  ChatRepository(this._dio);

  final Dio _dio;

  Future<List<Conversation>> fetchConversations() async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/conversations',
      queryParameters: <String, Object?>{'user_id': kUserId},
    );
    final raw =
        response.data?['conversations'] as List<dynamic>? ?? const <dynamic>[];
    return raw
        .whereType<Map<String, dynamic>>()
        .map(Conversation.fromJson)
        .toList(growable: false);
  }

  Future<Conversation> createConversation() async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/conversations',
      data: <String, Object?>{'user_id': kUserId},
    );
    return Conversation.fromJson(response.data ?? <String, dynamic>{});
  }

  Future<void> deleteConversation(String conversationId) async {
    await _dio.delete<void>(
      '/conversations/$conversationId',
      queryParameters: <String, Object?>{'user_id': kUserId},
    );
  }

  Future<String> sendMessage({
    required String conversationId,
    required String message,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/chat',
      data: <String, Object?>{
        'user_id': kUserId,
        'conversation_id': conversationId,
        'message': message,
      },
    );

    final data = response.data ?? const <String, dynamic>{};
    return data['response']?.toString() ?? data['message']?.toString() ?? '';
  }
}

@riverpod
ChatRepository chatRepository(Ref ref) {
  final dio = ref.watch(dioProvider);
  return ChatRepository(dio);
}
