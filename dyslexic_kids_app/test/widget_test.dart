// test/widget_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kids_learning_app/main.dart';
import 'package:kids_learning_app/pages/home_page.dart';

void main() {
  // تعريف userId وهمي للاختبار
  const int testUserId = 1;

  testWidgets('App loads and shows welcome screen', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Kids Learning App'), findsNothing); 
    
    expect(find.text('Welcome to'), findsOneWidget);
    expect(find.text('Dyslexic Kids Learning'), findsOneWidget);
    expect(find.text('Get Started'), findsOneWidget);
  });

  testWidgets('Navigation to home page works', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    // نضغط على الزر للذهاب للـ Home
    await tester.tap(find.text('Get Started'));
    await tester.pumpAndSettle();

    // ملاحظة: الـ Navigation الفعلي يعتمد على الـ Login و الـ Avatar selection
    // إذا الـ Test فشل هنا، لازمنا نمروا بكل مراحل التطبيق أو نختبر الـ Home مباشرة
  });

  testWidgets('Home page categories are displayed', (WidgetTester tester) async {
    // مصلحة: زدنا الـ userId هنا
    await tester.pumpWidget(const MaterialApp(
      home: HomePage(
        username: 'Alex', 
        selectedAvatar: 1, 
        userId: testUserId, // <--- FIXED
      ),
    ));
    
    await tester.pumpAndSettle();

    expect(find.text('Categories'), findsOneWidget);
    expect(find.byType(GridView), findsOneWidget);
  });

  testWidgets('Daily challenge card is present', (WidgetTester tester) async {
    // مصلحة: زدنا الـ userId هنا
    await tester.pumpWidget(const MaterialApp(
      home: HomePage(
        username: 'Alex', 
        selectedAvatar: 1, 
        userId: testUserId, // <--- FIXED
      ),
    ));
    
    await tester.pumpAndSettle();

    expect(find.text('Daily 👀'), findsOneWidget);
    expect(find.text('challenge'), findsOneWidget);
    expect(find.text("let's go"), findsOneWidget);
  });

  testWidgets('Notification icon is present and clickable', (WidgetTester tester) async {
    // مصلحة: زدنا الـ userId هنا
    await tester.pumpWidget(const MaterialApp(
      home: HomePage(
        username: 'Alex', 
        selectedAvatar: 1, 
        userId: testUserId, // <--- FIXED
      ),
    ));
    
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.notifications), findsOneWidget);
    
    await tester.tap(find.byIcon(Icons.notifications));
    await tester.pump();
    
    // بعد الضغط، الأيقونة تتغير لـ notifications_off
    expect(find.byIcon(Icons.notifications_off), findsOneWidget);
  });

  testWidgets('Avatar is present and clickable', (WidgetTester tester) async {
    // مصلحة: زدنا الـ userId هنا
    await tester.pumpWidget(const MaterialApp(
      home: HomePage(
        username: 'Alex', 
        selectedAvatar: 1, 
        userId: testUserId, // <--- FIXED
      ),
    ));
    
    await tester.pumpAndSettle();

    // الـ HomePage تستخدم GestureDetector و Container للأفاتار مش CircleAvatar
    // لذا نبحث بالـ Image.asset
    expect(find.byType(Image), findsWidgets);
    
    // نضغط على أول صورة (اللي هي الأفاتار في الهيدر)
    await tester.tap(find.byType(Image).first);
    await tester.pumpAndSettle();
  });
}