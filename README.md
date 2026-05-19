# AS_New_InMotions

Prototipo móvil Flutter de **AS_New_InMotions**, app de salud mental y bienestar emocional para estudiantes UTB.

## Estado actual

Esta versión corresponde al **Paso 4: biblioteca local funcional + triaje oficial desde anexos**.

Incluye:

- Autenticación local simulada.
- Validación de correo institucional `@utb.edu.co`.
- Sesión local con `SharedPreferences`.
- Registro emocional local funcional.
- Historial emocional local funcional.
- Triaje emocional local con 23 ítems oficiales del Anexo A.
- Escala Likert de 1 a 5: No me identifico, Poco, Moderadamente, Bastante y Totalmente.
- Clasificación por niveles: Verde, Amarillo, Naranja, Rojo y Crítico.
- Activación crítica si A5, F1 o F2 tienen puntaje mayor o igual a 4.
- Resultado con recomendaciones y simulación de derivación a Psicología UTB.
- Biblioteca de recursos local basada en el Anexo B.
- Búsqueda, filtros por temática, formato y nivel.
- Favoritos locales con `SharedPreferences`.
- Recomendaciones de recursos según último resultado del triaje.
- Restricción inicial de biblioteca para resultados Rojo/Crítico hasta visualizar recursos de ayuda.

## Usuario de prueba

```text
Correo: estudiante@utb.edu.co
Contraseña: Test@12345
```

## Flujo implementado

```text
Login → Dashboard → Triaje → 23 preguntas → Resultado → Biblioteca recomendada
```

También sigue funcionando:

```text
Dashboard → Registro emocional → Guardar → Historial
Dashboard → Biblioteca → Buscar / Filtrar / Guardar favoritos → Detalle
```

## Triaje local

Las preguntas oficiales están en:

```text
lib/data/repositories/triage_repository.dart
```

Los rangos actuales son:

```text
23 a 45 puntos: Verde / Bienestar estable
46 a 70 puntos: Amarillo / Malestar moderado
71 a 95 puntos: Naranja / Malestar significativo
96 a 115 puntos: Rojo / Malestar alto
A5, F1 o F2 >= 4: Crítico, independiente del puntaje global
```

Los umbrales están en:

```text
lib/core/constants/app_config.dart
```

## Biblioteca local

Los recursos están en:

```text
lib/data/repositories/resource_repository.dart
```

El modelo, almacenamiento y visuales están en:

```text
lib/core/models/resource_model.dart
lib/core/storage/local_resource_storage.dart
lib/core/utils/resource_visuals.dart
```

## Archivos agregados en el Paso 4

```text
lib/core/models/resource_model.dart
lib/core/storage/local_resource_storage.dart
lib/core/utils/resource_visuals.dart
lib/data/repositories/resource_repository.dart
```

## Archivos modificados en el Paso 4

```text
lib/core/constants/app_config.dart
lib/core/models/triage_question_model.dart
lib/core/models/triage_result_model.dart
lib/core/storage/local_triage_storage.dart
lib/core/utils/triage_visuals.dart
lib/data/repositories/triage_repository.dart
lib/features/triage/presentation/pages/triage_page.dart
lib/features/articles/presentation/pages/articles_page.dart
lib/features/articles/presentation/pages/article_detail_page.dart
pubspec.yaml
README.md
```

## Ejecutar

```bash
flutter pub get
flutter run
```

## Nota importante

Esta versión todavía no usa backend ni base de datos en la nube. El objetivo es dejar primero toda la lógica funcional local para después reemplazar los repositorios locales por servicios API.
