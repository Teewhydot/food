import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;

// Core
import '../network/network_info.dart';

// Data sources
import '../../data/datasources/remote/ai_service_remote_datasource.dart';
import '../../data/datasources/remote/chat_remote_datasource.dart';

// Repositories
import '../../data/repositories/ai_service_repository_impl.dart';
import '../../data/repositories/chat_repository_impl.dart';
import '../../domain/repositories/ai_service_repository.dart';
import '../../domain/repositories/chat_repository.dart';

// Use cases
import '../../domain/usecases/chat_room_usecases.dart';
import '../../domain/usecases/get_messages_usecase.dart';
import '../../domain/usecases/send_ai_message_usecase.dart';
import '../../domain/usecases/send_message_usecase.dart';
import '../../domain/usecases/update_message_usecase.dart';

// Presentation
import '../../presentation/manager/chat_bloc/chat_bloc.dart';
import '../../presentation/manager/chat_room_bloc/chat_room_bloc.dart';
import '../../presentation/services/ai_function_registry.dart';

final sl = GetIt.instance;

class AIChatInjectionContainer {
  static Future<void> init() async {
    // External
    sl.registerLazySingleton(() => http.Client());
    sl.registerLazySingleton(() => Connectivity());
    sl.registerLazySingleton(() => FirebaseFirestore.instance);
    sl.registerLazySingleton(() => FirebaseAuth.instance);

    // Core
    sl.registerLazySingleton<NetworkInfo>(
      () => NetworkInfoImpl(sl()),
    );

    // Data sources
    sl.registerLazySingleton<AIServiceRemoteDataSource>(
      () => OpenAIServiceRemoteDataSource(
        client: sl(),
        apiKey: '', // Configure with your API key
        model: 'gpt-4',
      ),
    );

    sl.registerLazySingleton<ChatRemoteDataSource>(
      () => ChatRemoteDataSourceImpl(
        firestore: sl(),
        firebaseAuth: sl(),
      ),
    );

    // Repositories
    sl.registerLazySingleton<AIServiceRepository>(
      () => AIServiceRepositoryImpl(
        remoteDataSource: sl(),
        networkInfo: sl(),
      ),
    );

    sl.registerLazySingleton<ChatRepository>(
      () => ChatRepositoryImpl(
        remoteDataSource: sl(),
        networkInfo: sl(),
      ),
    );

    // Use cases
    sl.registerLazySingleton(() => GetMessagesUseCase(sl()));
    sl.registerLazySingleton(() => SendMessageUseCase(sl()));
    sl.registerLazySingleton(() => SendAIMessageUseCase(sl()));
    sl.registerLazySingleton(() => SendAIMessageWithFunctionsUseCase(sl()));
    sl.registerLazySingleton(() => SendStreamingAIMessageUseCase(sl()));
    sl.registerLazySingleton(() => GetUserChatRoomsUseCase(sl()));
    sl.registerLazySingleton(() => CreateChatRoomUseCase(sl()));
    sl.registerLazySingleton(() => GetChatRoomUseCase(sl()));
    sl.registerLazySingleton(() => UpdateChatRoomUseCase(sl()));
    sl.registerLazySingleton(() => MarkMessagesAsReadUseCase(sl()));
    sl.registerLazySingleton(() => UpdateMessageUseCase(sl()));

    // Services
    sl.registerLazySingleton(() => AIFunctionRegistry());

    // BLoCs - These will need to be updated based on actual ChatBloc constructor
    // Note: You'll need to check the actual ChatBloc constructors and update accordingly
    sl.registerFactory(() => ChatBloc(
          getMessages: sl<GetMessagesUseCase>(),
          sendMessage: sl<SendMessageUseCase>(),
          sendAIMessage: sl<SendAIMessageUseCase>(),
          sendAIMessageWithFunctions: sl<SendAIMessageWithFunctionsUseCase>(),
          sendStreamingAIMessage: sl<SendStreamingAIMessageUseCase>(),
          markMessagesAsRead: sl<MarkMessagesAsReadUseCase>(),
          firebaseAuth: sl(),
          functionRegistry: sl(),
        ));

    sl.registerFactory(() => ChatRoomBloc(
          getUserChatRooms: sl<GetUserChatRoomsUseCase>(),
          createChatRoom: sl<CreateChatRoomUseCase>(),
          getChatRoom: sl<GetChatRoomUseCase>(),
          updateChatRoom: sl<UpdateChatRoomUseCase>(),
        ));
  }
}