import 'package:calley_app/data/services/api_client.dart';
import 'package:calley_app/data/services/calley_repository.dart';
import 'package:calley_app/data/services/local_mock_calley_data_source.dart';
import 'package:calley_app/data/services/remote_calley_data_source.dart';
import 'package:calley_app/main.dart';
import 'package:calley_app/providers/app_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('Starts on Choose Your Language and navigates to Register',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final repo = CalleyRepository(
      remote: RemoteCalleyDataSource(ApiClient()),
      local: LocalMockCalleyDataSource(prefs),
    );

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AppProvider(prefs: prefs, repository: repo),
        child: const CalleyApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Choose Your Language'), findsOneWidget);
    expect(find.text('English'), findsOneWidget);
    expect(find.text('Hindi'), findsOneWidget);

    await tester.tap(find.text('Select'));
    await tester.pumpAndSettle();

    expect(find.text('Welcome!'), findsOneWidget);
    expect(find.text('Please register to continue'), findsOneWidget);
    expect(find.text('Sign Up'), findsOneWidget);
  });
}
