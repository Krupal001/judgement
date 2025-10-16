import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/scenario.dart';

abstract class ScenarioRepository {
  Future<Either<Failure, List<Scenario>>> getScenarios();
  Future<Either<Failure, Scenario>> getScenarioById(String id);
}
