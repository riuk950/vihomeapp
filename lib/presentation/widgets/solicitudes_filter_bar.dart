import 'package:flutter/material.dart';
import 'package:vihomeapp/core/theme/app_theme.dart';

/// Modelo de datos para las opciones de filtrado en [SolicitudesFilterBar].
class _FilterOption {
  final String key;
  final String label;
  final int count;

  const _FilterOption({
    required this.key,
    required this.label,
    required this.count,
  });
}

/// Barra horizontal de segmentación rápida con chips y contadores dinámicos.
/// (RF-21.1, RF-21.2, QA 1.17, RNF-12, RNF-14).
class SolicitudesFilterBar extends StatelessWidget {
  /// Filtro actualmente seleccionado ('Todas', 'Pendientes', 'Aceptadas', 'Rechazadas').
  final String currentFilter;

  /// Callback invocado cuando el usuario selecciona un nuevo filtro.
  final ValueChanged<String> onFilterSelected;

  /// Cantidad total de solicitudes coincidentes.
  final int totalCount;

  /// Cantidad de solicitudes en estado 'Pendiente'.
  final int pendingCount;

  /// Cantidad de solicitudes en estado 'Aceptada'.
  final int acceptedCount;

  /// Cantidad de solicitudes en estado 'Rechazada'.
  final int rejectedCount;

  const SolicitudesFilterBar({
    super.key,
    required this.currentFilter,
    required this.onFilterSelected,
    this.totalCount = 0,
    this.pendingCount = 0,
    this.acceptedCount = 0,
    this.rejectedCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    final options = [
      _FilterOption(key: 'Todas', label: 'Todas', count: totalCount),
      _FilterOption(key: 'Pendientes', label: 'Pendientes', count: pendingCount),
      _FilterOption(key: 'Aceptadas', label: 'Aceptadas', count: acceptedCount),
      _FilterOption(key: 'Rechazadas', label: 'Rechazadas', count: rejectedCount),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: options.map((option) {
          final isSelected =
              currentFilter.trim().toLowerCase() == option.key.trim().toLowerCase();

          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ChoiceChip(
              key: Key('filter_chip_${option.key.toLowerCase()}'),
              label: Text('${option.label} (${option.count})'),
              selected: isSelected,
              onSelected: (_) => onFilterSelected(option.key),
              selectedColor: primaryColor,
              backgroundColor: Colors.white,
              showCheckmark: false,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : textColor,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                fontSize: 13,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected ? primaryColor : Colors.grey.shade300,
                  width: 1,
                ),
              ),
              elevation: isSelected ? 1 : 0,
              visualDensity: VisualDensity.compact,
            ),
          );
        }).toList(),
      ),
    );
  }
}
