import 'package:flutter_test/flutter_test.dart';
import 'package:multi_lng_bloc/app/app.dart';

void main() {
  testWidgets('App renders home page', (WidgetTester tester) async {
    await tester.pumpWidget(MyApp());
    await tester.pumpAndSettle();

    expect(find.text('MultiLangBloc - چند زبانه با بلاک'), findsOneWidget);
  });
}
