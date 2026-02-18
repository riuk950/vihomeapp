class PropertyType {
  final String nombre;

  const PropertyType({
    required this.nombre,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PropertyType &&
          runtimeType == other.runtimeType &&
          nombre == other.nombre;

  @override
  int get hashCode => nombre.hashCode;
}
