import '../../domain/entities/constructora.dart';

class ConstructoraModel extends Constructora {
  const ConstructoraModel({
    required super.id,
    required super.nombre,
    super.logoUrl,
    required super.nit,
    super.departamento,
    super.ciudad,
    super.direccion,
    super.telefonoFijo,
    super.whatsapp,
    super.sitioWeb,
    super.correo,
  });

  factory ConstructoraModel.fromJson(Map<String, dynamic> json) {
    return ConstructoraModel(
      id: json['id'] as String,
      nombre: json['nombre'] as String? ?? '',
      nit: json['nit'] as String? ?? '',
      departamento: json['departamento'] as String?,
      ciudad: json['ciudad'] as String?,
      direccion: json['direccion'] as String?,
      telefonoFijo: json['telefono_fijo'] as String?,
      whatsapp:
          json['whatsap'] as String?, // Note: API says 'whatsap' (missing p)
      sitioWeb: json['sitio_web'] as String?,
      correo: json['correo'] as String?,
      logoUrl: json['logo_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'nit': nit,
      'departamento': departamento,
      'ciudad': ciudad,
      'direccion': direccion,
      'telefono_fijo': telefonoFijo,
      'whatsap': whatsapp,
      'sitio_web': sitioWeb,
      'correo': correo,
      'logo_url': logoUrl,
    };
  }
}
