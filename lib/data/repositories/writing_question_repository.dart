import '../models/writing_question_model.dart';
import '../services/writing_question_service.dart';

class WritingQuestionRepository {
  final WritingQuestionService _service;

  WritingQuestionRepository(this._service);

  Future<List<WritingQuestion>> getAllQuestions() =>
      _service.getAllQuestions();

  Future<WritingQuestion> getQuestionById(String id) =>
      _service.getQuestionById(id);

  Future<List<WritingQuestion>> getByTaskType(String taskType) =>
      _service.getByTaskType(taskType);

  Future<List<WritingQuestion>> getByTaskNumber(int taskNumber) =>
      _service.getByTaskNumber(taskNumber);

  Future<List<WritingQuestion>> getByDifficulty(String difficulty) =>
      _service.getByDifficulty(difficulty);

  Future<List<WritingQuestion>> getPracticeQuestions() =>
      _service.getPracticeQuestions();

  Future<List<String>> getAvailableTaskTypes() =>
      _service.getAvailableTaskTypes();
}
