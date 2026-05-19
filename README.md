# AS_New_InMotions

Prototipo móvil Flutter de **AS_New_InMotions**, app de salud mental y bienestar emocional para estudiantes UTB.

## Estado actual

Esta versión corresponde al **Paso 5: recordatorios locales funcionales + correcciones responsive de biblioteca**.

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
- Filtros de biblioteca corregidos para evitar overflow en pantallas pequeñas.
- Separación visual agregada entre el encabezado azul y el primer bloque de contenido.
- Favoritos locales con `SharedPreferences`.
- Recomendaciones de recursos según último resultado del triaje.
- Restricción inicial de biblioteca para resultados Rojo/Crítico hasta visualizar recursos de ayuda.
- Recordatorios locales funcionales con `SharedPreferences`.
- Crear, editar, activar/desactivar, eliminar y restaurar recordatorios.
- Selector de hora y días activos para cada recordatorio.
- Cálculo local del próximo recordatorio activo.

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
Dashboard → Recordatorios → Crear / Editar / Activar / Eliminar
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

## Recordatorios locales

Los recordatorios se guardan localmente en el dispositivo con `SharedPreferences`.

Archivos principales:

```text
lib/core/models/reminder_model.dart
lib/core/storage/local_reminder_storage.dart
lib/core/utils/reminder_visuals.dart
lib/data/repositories/reminder_repository.dart
lib/features/reminders/presentation/pages/reminders_page.dart
```

> Importante: este paso todavía no envía notificaciones push reales. Deja la lógica local lista para que después se conecte con Firebase Cloud Messaging o con el backend.

## Archivos agregados en el Paso 5

```text
lib/core/models/reminder_model.dart
lib/core/storage/local_reminder_storage.dart
lib/core/utils/reminder_visuals.dart
lib/data/repositories/reminder_repository.dart
```

## Archivos modificados en el Paso 5

```text
lib/features/articles/presentation/pages/articles_page.dart
lib/features/reminders/presentation/pages/reminders_page.dart
pubspec.yaml
README.md
```

## Corrección aplicada en biblioteca

Se corrigió el overflow de `DropdownButtonFormField` haciendo que los filtros sean responsive:

```text
- En pantallas angostas, Formato y Nivel se apilan verticalmente.
- En pantallas con más espacio, Formato y Nivel se mantienen en fila.
- Los dropdowns usan isExpanded y ellipsis para textos largos.
```

También se agregó separación entre el encabezado azul y el primer bloque de contenido.

## Ejecutar

```bash
flutter pub get
flutter run
```

## Nota importante

Esta versión todavía no usa backend ni base de datos en la nube. El objetivo es dejar primero toda la lógica funcional local para después reemplazar los repositorios locales por servicios API.
