import 'package:get_it/get_it.dart';
import 'features/card_game/data/repositories/firebase_game_repository.dart';
import 'features/card_game/domain/repositories/game_repository.dart';
import 'features/card_game/domain/services/game_logic_service.dart';
import 'features/card_game/presentation/bloc/card_game_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Bloc - Changed to LazySingleton to prevent auto-disposal during navigation
  sl.registerLazySingleton(
    () => CardGameBloc(repository: sl()),
  );

  // Repository - Using Firebase for real-time multiplayer
  sl.registerLazySingleton<GameRepository>(
    () => FirebaseGameRepository(gameLogic: sl()),
  );

  // Services
  sl.registerLazySingleton(() => GameLogicService());
}
