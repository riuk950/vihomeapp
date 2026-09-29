import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vihomeapp/presentation/widgets/contact_actions_row.dart';
import 'package:vihomeapp/presentation/widgets/solicitudes_empty_state.dart';

void main() {
  group('ContactActionsRow (RF-19.1, RF-19.2, RF-19.3, RF-20.2, RF-20.3, QA 1.1, QA 1.7, CL-16)', () {
    Widget buildContactWidget({
      String? phoneNumber,
      String? recipientName,
      String? propertyTitle,
      String status = 'pendiente',
      bool isTenantView = false,
      VoidCallback? onCall,
      VoidCallback? onWhatsApp,
      Future<bool> Function(Uri, {dynamic mode})? launcher,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: Center(
            child: ContactActionsRow(
              phoneNumber: phoneNumber,
              recipientName: recipientName,
              propertyTitle: propertyTitle,
              status: status,
              isTenantView: isTenantView,
              onCall: onCall,
              onWhatsApp: onWhatsApp,
              launcher: launcher,
            ),
          ),
        ),
      );
    }

    testWidgets('debe renderizar botones de llamada y WhatsApp para el Arrendador en solicitud pendiente',
        (tester) async {
      await tester.pumpWidget(
        buildContactWidget(
          phoneNumber: '3124567890',
          recipientName: 'Carlos Restrepo',
          propertyTitle: 'Apt 402',
          status: 'pendiente',
          isTenantView: false,
        ),
      );

      expect(find.byKey(const Key('contact_call_button')), findsOneWidget);
      expect(find.byKey(const Key('contact_whatsapp_button')), findsOneWidget);
    });

    testWidgets('debe renderizar botones de llamada y WhatsApp para el Arrendador en solicitud aceptada',
        (tester) async {
      await tester.pumpWidget(
        buildContactWidget(
          phoneNumber: '3124567890',
          status: 'aceptada',
          isTenantView: false,
        ),
      );

      expect(find.byKey(const Key('contact_call_button')), findsOneWidget);
      expect(find.byKey(const Key('contact_whatsapp_button')), findsOneWidget);
    });

    testWidgets('debe renderizar botones para el Arrendatario ÚNICAMENTE si la solicitud está aceptada (RF-19.2)',
        (tester) async {
      await tester.pumpWidget(
        buildContactWidget(
          phoneNumber: '3009876543',
          recipientName: 'Beatriz Salazar',
          propertyTitle: 'Casa Campestre',
          status: 'aceptada',
          isTenantView: true,
        ),
      );

      expect(find.byKey(const Key('contact_call_button')), findsOneWidget);
      expect(find.byKey(const Key('contact_whatsapp_button')), findsOneWidget);
    });

    testWidgets('debe ocultar botones para el Arrendatario si la solicitud está pendiente (RF-19.1)',
        (tester) async {
      await tester.pumpWidget(
        buildContactWidget(
          phoneNumber: '3009876543',
          status: 'pendiente',
          isTenantView: true,
        ),
      );

      expect(find.byKey(const Key('contact_call_button')), findsNothing);
      expect(find.byKey(const Key('contact_whatsapp_button')), findsNothing);
    });

    testWidgets('debe ocultar botones para AMBAS partes si la solicitud está rechazada (RF-19.3, QA 1.7)',
        (tester) async {
      // Arrendador
      await tester.pumpWidget(
        buildContactWidget(
          phoneNumber: '3124567890',
          status: 'rechazada',
          isTenantView: false,
        ),
      );
      expect(find.byKey(const Key('contact_call_button')), findsNothing);
      expect(find.byKey(const Key('contact_whatsapp_button')), findsNothing);

      // Arrendatario
      await tester.pumpWidget(
        buildContactWidget(
          phoneNumber: '3009876543',
          status: 'rechazada',
          isTenantView: true,
        ),
      );
      expect(find.byKey(const Key('contact_call_button')), findsNothing);
      expect(find.byKey(const Key('contact_whatsapp_button')), findsNothing);
    });

    testWidgets('debe ocultar botones si el teléfono es nulo o vacío (RF-20.3, CL-16)',
        (tester) async {
      // Teléfono nulo
      await tester.pumpWidget(
        buildContactWidget(
          phoneNumber: null,
          status: 'pendiente',
          isTenantView: false,
        ),
      );
      expect(find.byKey(const Key('contact_call_button')), findsNothing);
      expect(find.byKey(const Key('contact_whatsapp_button')), findsNothing);

      // Teléfono vacío
      await tester.pumpWidget(
        buildContactWidget(
          phoneNumber: '   ',
          status: 'pendiente',
          isTenantView: false,
        ),
      );
      expect(find.byKey(const Key('contact_call_button')), findsNothing);
      expect(find.byKey(const Key('contact_whatsapp_button')), findsNothing);

      // Teléfono no numérico / inválido
      await tester.pumpWidget(
        buildContactWidget(
          phoneNumber: 'sin-telefono',
          status: 'pendiente',
          isTenantView: false,
        ),
      );
      expect(find.byKey(const Key('contact_call_button')), findsNothing);
      expect(find.byKey(const Key('contact_whatsapp_button')), findsNothing);
    });

    testWidgets('debe invocar onCall y onWhatsApp al tocar los botones respectivos',
        (tester) async {
      bool callTapped = false;
      bool whatsappTapped = false;

      await tester.pumpWidget(
        buildContactWidget(
          phoneNumber: '3124567890',
          status: 'pendiente',
          onCall: () => callTapped = true,
          onWhatsApp: () => whatsappTapped = true,
        ),
      );

      await tester.tap(find.byKey(const Key('contact_call_button')));
      await tester.pumpAndSettle();
      expect(callTapped, isTrue);

      await tester.tap(find.byKey(const Key('contact_whatsapp_button')));
      await tester.pumpAndSettle();
      expect(whatsappTapped, isTrue);
    });

    testWidgets('debe mostrar SnackBar de retroalimentación si el lanzamiento falla (QA 1.4, QA 1.13)',
        (tester) async {
      await tester.pumpWidget(
        buildContactWidget(
          phoneNumber: '3124567890',
          recipientName: 'Carlos Restrepo',
          propertyTitle: 'Apt 402',
          status: 'pendiente',
          launcher: (uri, {mode}) async => false, // Simula fallo al abrir app
        ),
      );

      // Tocar llamada fallida
      await tester.tap(find.byKey(const Key('contact_call_button')));
      await tester.pump(); // Inicia animación de SnackBar

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.textContaining('No se pudo abrir llamada'), findsOneWidget);

      // Tocar WhatsApp fallido
      await tester.tap(find.byKey(const Key('contact_whatsapp_button')));
      await tester.pump();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.textContaining('No se pudo abrir WhatsApp'), findsOneWidget);
    });
  });

  group('SolicitudesEmptyState (RF-22.1, RF-22.2)', () {
    Widget buildEmptyStateWidget(Widget child) {
      return MaterialApp(
        home: Scaffold(
          body: child,
        ),
      );
    }

    testWidgets('debe renderizar título, mensaje y botón de acción en constructor estándar',
        (tester) async {
      bool actionTriggered = false;

      await tester.pumpWidget(
        buildEmptyStateWidget(
          SolicitudesEmptyState(
            icon: Icons.hourglass_empty,
            title: 'Sin datos disponibles',
            message: 'No existen registros para mostrar en este momento.',
            actionLabel: 'Recargar',
            onAction: () => actionTriggered = true,
          ),
        ),
      );

      expect(find.text('Sin datos disponibles'), findsOneWidget);
      expect(find.text('No existen registros para mostrar en este momento.'), findsOneWidget);
      expect(find.byIcon(Icons.hourglass_empty), findsOneWidget);
      expect(find.text('Recargar'), findsOneWidget);

      await tester.tap(find.byKey(const Key('empty_state_action_button')));
      await tester.pumpAndSettle();
      expect(actionTriggered, isTrue);
    });

    testWidgets('no debe renderizar botón de acción si actionLabel es nulo',
        (tester) async {
      await tester.pumpWidget(
        buildEmptyStateWidget(
          const SolicitudesEmptyState(
            title: 'Solo lectura',
            message: 'Mensaje informativo sin acción.',
          ),
        ),
      );

      expect(find.text('Solo lectura'), findsOneWidget);
      expect(find.byKey(const Key('empty_state_action_button')), findsNothing);
    });

    testWidgets('SolicitudesEmptyState.tenant debe contener "Explorar inmuebles" (RF-22.1)',
        (tester) async {
      bool explored = false;

      await tester.pumpWidget(
        buildEmptyStateWidget(
          SolicitudesEmptyState.tenant(
            onExplore: () => explored = true,
          ),
        ),
      );

      expect(find.text('No tienes postulaciones'), findsOneWidget);
      expect(find.text('Explorar inmuebles'), findsOneWidget);

      await tester.tap(find.text('Explorar inmuebles'));
      await tester.pumpAndSettle();
      expect(explored, isTrue);
    });

    testWidgets('SolicitudesEmptyState.landlord debe contener "Ver mis propiedades" (RF-22.1)',
        (tester) async {
      bool viewed = false;

      await tester.pumpWidget(
        buildEmptyStateWidget(
          SolicitudesEmptyState.landlord(
            onManageProperties: () => viewed = true,
          ),
        ),
      );

      expect(find.text('No tienes solicitudes recibidas'), findsOneWidget);
      expect(find.text('Ver mis propiedades'), findsOneWidget);

      await tester.tap(find.text('Ver mis propiedades'));
      await tester.pumpAndSettle();
      expect(viewed, isTrue);
    });

    testWidgets('SolicitudesEmptyState.filtered debe renderizar el nombre del filtro (RF-22.2)',
        (tester) async {
      bool cleared = false;

      await tester.pumpWidget(
        buildEmptyStateWidget(
          SolicitudesEmptyState.filtered(
            filterName: 'Aceptadas',
            onClearFilter: () => cleared = true,
          ),
        ),
      );

      expect(find.textContaining('Aceptadas'), findsWidgets);
      expect(find.text('Ver todas'), findsOneWidget);

      await tester.tap(find.text('Ver todas'));
      await tester.pumpAndSettle();
      expect(cleared, isTrue);
    });
  });
}
