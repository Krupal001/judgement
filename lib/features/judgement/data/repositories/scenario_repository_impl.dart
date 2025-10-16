import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/scenario.dart';
import '../../domain/repositories/scenario_repository.dart';
import '../datasources/scenario_local_data_source.dart';

class ScenarioRepositoryImpl implements ScenarioRepository {
  final ScenarioLocalDataSource localDataSource;

  ScenarioRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, List<Scenario>>> getScenarios() async {
    try {
      final scenarios = await localDataSource.getScenarios();
      return Right(scenarios);
    } catch (e) {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, Scenario>> getScenarioById(String id) async {
    try {
      final scenarios = await localDataSource.getScenarios();
      final scenario = scenarios.firstWhere((s) => s.id == id);
      return Right(scenario);
    } catch (e) {
      return Left(CacheFailure());
    }
  }
}
