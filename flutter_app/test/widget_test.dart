import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/main.dart';
import 'package:flutter_app/services/question_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMessageHandler('flutter/assets', (message) async {
        final key = utf8.decode(message!.buffer.asUint8List());
        if (key == 'AssetManifest.bin') {
          return const StandardMessageCodec().encodeMessage(<String, Object>{});
        }
        return null;
      });

  testWidgets('setup screen renders quiz controls', (tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(
      AzureQuizApp(
        repository: QuestionRepository(bundle: _FakeQuestionBundle()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Exams'), findsOneWidget);
    expect(find.text('Practice'), findsOneWidget);
    expect(find.text('Progress'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);
    expect(find.text('Hello, Alex'), findsOneWidget);

    await tester.tap(find.text('Practice'));
    await tester.pumpAndSettle();

    expect(find.text('Practice Mode'), findsWidgets);
    expect(find.text('Examination Mode'), findsOneWidget);
    expect(find.text('AZ-900'), findsWidgets);
    expect(find.text('10 Questions'), findsOneWidget);
  });

  testWidgets('starting a quiz displays a question and results', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(
      AzureQuizApp(
        repository: QuestionRepository(bundle: _FakeQuestionBundle()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Practice'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Start Practice'));
    await tester.tap(find.text('Start Practice'));
    await tester.pumpAndSettle();

    expect(
      find.text('Which Azure service is used for virtual machines?'),
      findsOneWidget,
    );
    expect(find.text('Finish'), findsOneWidget);

    await tester.tap(find.text('B. Azure Virtual Machines'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Finish'));
    await tester.tap(find.text('Finish'));
    await tester.pumpAndSettle();

    expect(find.text('Quiz Completed!'), findsOneWidget);
    expect(find.text('100%'), findsWidgets);
  });

  testWidgets('home exam action opens learning before practice studio', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(
      AzureQuizApp(
        repository: QuestionRepository(bundle: _FakeQuestionBundle()),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.text('Which Azure service is used for virtual machines?'),
      findsNothing,
    );

    await tester.ensureVisible(find.text('Learn AZ-900'));
    await tester.tap(find.text('Learn AZ-900'));
    await tester.pumpAndSettle();

    expect(find.text('Learning path before practice'), findsOneWidget);
    expect(find.text('What to learn first'), findsOneWidget);
    expect(
      find.text('Which Azure service is used for virtual machines?'),
      findsNothing,
    );

    await tester.scrollUntilVisible(
      find.text('Go to Practice Studio'),
      180,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.tap(find.text('Go to Practice Studio'));
    await tester.pumpAndSettle();

    expect(find.text('Practice studio'), findsOneWidget);
    expect(find.text('Start Practice'), findsOneWidget);
    expect(
      find.text('Which Azure service is used for virtual machines?'),
      findsNothing,
    );
  });

  testWidgets('exams tab opens learning instead of starting quiz', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(
      AzureQuizApp(
        repository: QuestionRepository(bundle: _FakeQuestionBundle()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Exams'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Learn').first);
    await tester.tap(find.text('Learn').first);
    await tester.pumpAndSettle();

    expect(find.text('Learning path before practice'), findsOneWidget);
    expect(
      find.text('Which Azure service is used for virtual machines?'),
      findsNothing,
    );
  });

  testWidgets('theme toggle changes app theme', (tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(
      AzureQuizApp(
        repository: QuestionRepository(bundle: _FakeQuestionBundle()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();

    expect(find.text('Dark mode'), findsOneWidget);
    expect(find.byType(Switch), findsOneWidget);
    await tester.ensureVisible(find.byType(Switch));
    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();

    expect(find.text('Dark mode'), findsOneWidget);
  });

  testWidgets('coming soon certifications are visible but do not start quiz', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(
      AzureQuizApp(
        repository: QuestionRepository(bundle: _FakeQuestionBundle()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('CLF-C02'), findsWidgets);
    expect(find.text('SC-900'), findsWidgets);
    expect(
      find.text('Which Azure service is used for virtual machines?'),
      findsNothing,
    );

    final sc900Card = find
        .ancestor(of: find.text('SC-900').last, matching: find.byType(InkWell))
        .last;
    tester.widget<InkWell>(sc900Card).onTap?.call();
    await tester.pumpAndSettle();

    expect(
      find.text('Which Azure service is used for virtual machines?'),
      findsNothing,
    );
  });
}

class _FakeQuestionBundle extends CachingAssetBundle {
  @override
  Future<ByteData> load(String key) async {
    final encoded = utf8.encode(await loadString(key));
    return ByteData.sublistView(Uint8List.fromList(encoded));
  }

  @override
  Future<String> loadString(String key, {bool cache = true}) async {
    return jsonEncode([
      {
        'id': 'az900_test_1',
        'question': 'Which Azure service is used for virtual machines?',
        'type': 'mcq',
        'options': [
          'A. Azure Blob Storage',
          'B. Azure Virtual Machines',
          'C. Azure AI Search',
          'D. Azure DevOps',
        ],
        'correct_answer': 'B',
        'explanation': 'Azure Virtual Machines provides scalable compute.',
        'category': 'Compute Services',
        'difficulty': 'easy',
        'exam_type': 'AZ-900',
      },
    ]);
  }
}
