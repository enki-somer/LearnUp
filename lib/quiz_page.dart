import 'package:flutter/material.dart';

class Question {
  final String text;
  final List<String> options;
  final int correctAnswerIndex;

  Question({
    required this.text,
    required this.options,
    required this.correctAnswerIndex,
  });
}

class QuizPage extends StatefulWidget {
  final String courseTitle;
  final Color courseColor;

  const QuizPage({
    super.key,
    required this.courseTitle,
    required this.courseColor,
  });

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  final List<Question> questions = [
    Question(
      text: "What is Python?",
      options: [
        "A snake species",
        "A high-level programming language",
        "A database management system"
      ],
      correctAnswerIndex: 1,
    ),
    Question(
      text: "Which of these is NOT a Python data type?",
      options: ["String", "Integer", "Varchar"],
      correctAnswerIndex: 2,
    ),
    Question(
      text: "What is the correct way to create a function in Python?",
      options: [
        "function myFunction():",
        "def myFunction():",
        "create myFunction():"
      ],
      correctAnswerIndex: 1,
    ),
    Question(
      text: "How do you start a comment in Python?",
      options: ["//", "/* */", "#"],
      correctAnswerIndex: 2,
    ),
    Question(
      text: "Which operator is used for exponentiation in Python?",
      options: ["^", "**", "^^"],
      correctAnswerIndex: 1,
    ),
  ];

  List<int?> selectedAnswers = List.filled(5, null);
  bool showResults = false;

  int getScore() {
    int score = 0;
    for (int i = 0; i < questions.length; i++) {
      if (selectedAnswers[i] == questions[i].correctAnswerIndex) {
        score++;
      }
    }
    return score;
  }

  String getGrade(int score) {
    double percentage = (score / questions.length) * 100;
    if (percentage >= 90) return 'Excellent!';
    if (percentage >= 70) return 'Good Job!';
    if (percentage >= 50) return 'Keep Practicing!';
    return 'Need More Study!';
  }

  Color getGradeColor(int score) {
    double percentage = (score / questions.length) * 100;
    if (percentage >= 90) return Colors.green;
    if (percentage >= 70) return Colors.blue;
    if (percentage >= 50) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.courseTitle} Quiz'),
        backgroundColor: widget.courseColor,
        foregroundColor: Colors.white,
      ),
      body: showResults ? buildResults() : buildQuiz(),
    );
  }

  Widget buildQuiz() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: questions.length + 1, // +1 for submit button
      itemBuilder: (context, index) {
        if (index == questions.length) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 24.0),
            child: ElevatedButton(
              onPressed: () {
                if (selectedAnswers.contains(null)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content:
                          Text('Please answer all questions before submitting'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  return;
                }
                setState(() {
                  showResults = true;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.courseColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Submit Quiz',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          );
        }

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Question ${index + 1}:',
                  style: TextStyle(
                    color: widget.courseColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  questions[index].text,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 16),
                ...List.generate(
                  questions[index].options.length,
                  (optionIndex) => RadioListTile<int>(
                    title: Text(questions[index].options[optionIndex]),
                    value: optionIndex,
                    groupValue: selectedAnswers[index],
                    activeColor: widget.courseColor,
                    onChanged: (value) {
                      setState(() {
                        selectedAnswers[index] = value;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget buildResults() {
    final score = getScore();
    final grade = getGrade(score);
    final gradeColor = getGradeColor(score);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Text(
                    'Quiz Results',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: gradeColor,
                    child: Text(
                      '$score/${questions.length}',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    grade,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: gradeColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              setState(() {
                selectedAnswers = List.filled(5, null);
                showResults = false;
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.courseColor,
              padding: const EdgeInsets.symmetric(
                horizontal: 32,
                vertical: 16,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Try Again',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
