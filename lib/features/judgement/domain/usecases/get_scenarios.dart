import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/scenario.dart';
import '../repositories/scenario_repository.dart';

class GetScenarios implements UseCase<List<Scenario>, NoParams> {
  final ScenarioRepository repository;

  GetScenarios(this.repository);

  @override
  Future<Either<Failure, List<Scenario>>> call(NoParams params) async {
    return await repository.getScenarios();
  }
}
