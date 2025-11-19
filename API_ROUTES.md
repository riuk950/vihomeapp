# Rutas de la API (cURL)

Este documento detalla las rutas de la API disponibles, con ejemplos de cómo interactuar con ellas usando `cURL`.

### Listar propiedades 

```bash
curl 'https://oktklcmyjseaiitcqccv.supabase.co/rest/v1/propiedades?select=*' \
-H "apikey: SUPABASE_KEY" \
-H "Authorization: Bearer SUPABASE_KEY"

```

**Respuesta de ejemplo (éxito):**

```json
[
    {
        "id": 1,
        "id_propiedad": "d8c75eaf-ca8d-480b-b3fe-ac5eb012a0df",
        "direccion": "carrera13#3-64 sur",
        "tipo_propiedad": "Apartamento",
        "habitaciones": 2,
        "baños": 1,
        "fotos_propiedad": null,
        "titulo": "Apartamento Moderno en Manantial",
        "descripcion": "Disfrura de la vida de lujos en compañia de tu fasmilia ",
        "created_at": "2025-11-19T15:46:52.084718+00:00",
        "id_arrendador": "36f99a45-982e-4929-85e9-724421ea371b"
    }
]
```
 
