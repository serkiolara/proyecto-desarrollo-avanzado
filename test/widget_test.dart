// Smoke test básico de la app MisPelis.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_project/login_page.dart';

void main() {
  testWidgets('La pantalla de login muestra el botón Entrar',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: LoginPage()));
    expect(find.text('Entrar'), findsOneWidget);
    expect(find.text('MisPelis'), findsOneWidget);
  });
}
