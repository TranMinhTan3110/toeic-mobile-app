import '../models/writing_question_model.dart';

class MockWritingQuestions {
  static final List<WritingQuestion> mockQuestions = [
    // Write Sentence (Task 1-5)
    WritingQuestion(
      id: 'write_1',
      taskNumber: 1,
      taskType: 'write_sentence',
      promptText: 'Describe the image using the given words.',
      promptImageUrl:
          'https://images.unsplash.com/photo-1509042239860-f550ce710b93',
      givenWords: ['coffee', 'table'],
      emailContent: null,
      emailQuestions: [],
      timeLimit: 5,
      minWords: 10,
      maxWords: 20,
      maxScore: 10,
      scoringCriteria: ['grammar', 'vocabulary'],
      sampleAnswer: 'There is a cup of coffee on the table.',
      topic: null,
      difficulty: 'easy',
      examSetId: null,
      isPractice: true,
    ),
    WritingQuestion(
      id: 'write_2',
      taskNumber: 2,
      taskType: 'write_sentence',
      promptText: 'Describe the image using the given words.',
      promptImageUrl:
          'https://images.unsplash.com/photo-1552664730-d307ca884978',
      givenWords: ['people', 'meeting'],
      emailContent: null,
      emailQuestions: [],
      timeLimit: 5,
      minWords: 10,
      maxWords: 20,
      maxScore: 10,
      scoringCriteria: ['grammar', 'vocabulary'],
      sampleAnswer: 'Two people are having a meeting in the office.',
      topic: null,
      difficulty: 'easy',
      examSetId: null,
      isPractice: true,
    ),

    // Email Response (Task 6-7)
    WritingQuestion(
      id: 'email_1',
      taskNumber: 6,
      taskType: 'respond_email',
      promptText: 'Respond to this email',
      promptImageUrl: null,
      givenWords: [],
      emailContent:
          'Hi,\n\nI hope this email finds you well. I wanted to discuss the project timeline with you.\n\nBest regards,\nJohn',
      emailQuestions: [
        'When can you meet to discuss the project?',
        'What are your thoughts on the proposed timeline?'
      ],
      timeLimit: 10,
      minWords: 30,
      maxWords: 100,
      maxScore: 25,
      scoringCriteria: ['grammar', 'vocabulary', 'cohesion', 'relevance'],
      sampleAnswer: null,
      topic: null,
      difficulty: 'medium',
      examSetId: null,
      isPractice: true,
    ),
    WritingQuestion(
      id: 'email_2',
      taskNumber: 7,
      taskType: 'respond_email',
      promptText: 'Respond to this email',
      promptImageUrl: null,
      givenWords: [],
      emailContent:
          'Dear Ms. Anderson,\n\nWe would like to schedule a meeting to review the quarterly results.\n\nRegards,\nMr. Smith',
      emailQuestions: [
        'Confirm your availability for the meeting.',
        'Suggest an alternative date if you are not available.'
      ],
      timeLimit: 10,
      minWords: 30,
      maxWords: 100,
      maxScore: 25,
      scoringCriteria: ['grammar', 'vocabulary', 'cohesion', 'relevance'],
      sampleAnswer: null,
      topic: null,
      difficulty: 'medium',
      examSetId: null,
      isPractice: true,
    ),

    // Opinion Essay (Task 8)
    WritingQuestion(
      id: 'essay_1',
      taskNumber: 8,
      taskType: 'opinion_essay',
      promptText:
          'Do you agree or disagree with the following statement? It is better to work in a team than to work alone. Use specific reasons and examples to support your answer.',
      promptImageUrl: null,
      givenWords: [],
      emailContent: null,
      emailQuestions: [],
      timeLimit: 30,
      minWords: 200,
      maxWords: 300,
      maxScore: 30,
      scoringCriteria: ['grammar', 'vocabulary', 'cohesion', 'relevance'],
      sampleAnswer: null,
      topic: 'Teamwork vs Individual Work',
      difficulty: 'hard',
      examSetId: null,
      isPractice: true,
    ),
    WritingQuestion(
      id: 'essay_2',
      taskNumber: 8,
      taskType: 'opinion_essay',
      promptText:
          'Some people think that success in life comes from hard work and determination. Others believe that success is more related to money and connections. Which point of view do you agree with?',
      promptImageUrl: null,
      givenWords: [],
      emailContent: null,
      emailQuestions: [],
      timeLimit: 30,
      minWords: 200,
      maxWords: 300,
      maxScore: 30,
      scoringCriteria: ['grammar', 'vocabulary', 'cohesion', 'relevance'],
      sampleAnswer: null,
      topic: 'Success in Life',
      difficulty: 'hard',
      examSetId: null,
      isPractice: true,
    ),
  ];

  static List<WritingQuestion> getByTaskType(String taskType) {
    return mockQuestions
        .where((q) => q.taskType.toLowerCase() == taskType.toLowerCase())
        .toList();
  }

  static List<WritingQuestion> getByTaskNumber(int taskNumber) {
    return mockQuestions.where((q) => q.taskNumber == taskNumber).toList();
  }

  static List<WritingQuestion> getByDifficulty(String difficulty) {
    return mockQuestions
        .where((q) => q.difficulty.toLowerCase() == difficulty.toLowerCase())
        .toList();
  }

  static List<WritingQuestion> getPracticeQuestions() {
    return mockQuestions.where((q) => q.isPractice).toList();
  }

  static List<String> getAvailableTaskTypes() {
    return ['write_sentence', 'respond_email', 'opinion_essay'];
  }
}
