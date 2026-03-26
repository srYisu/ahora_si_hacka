# Plan de Implementación: Registro de Organizaciones

Para hacer que la pantalla [RegistroOrganizacion.dart](file:///c:/Users/ao412/Downloads/maldicion/lib/screens/RegistroOrganizacion.dart) guarde la información en Supabase, necesitamos dos cosas: crear la tabla en tu base de datos y conectar el botón "FINALIZAR REGISTRO" en el código de Flutter.

## 1. Configuración de Base de Datos en Supabase (Requerido por el Usuario)

Dado que esta pantalla recopila mucha más información que solo un correo y contraseña, necesitamos un lugar donde guardar esos datos extra. 

Debes ir a tu panel de Supabase y crear una **nueva tabla** llamada `organizaciones`.

**Columnas requeridas para la tabla `organizaciones`:**
1. [id](file:///c:/Users/ao412/Downloads/maldicion/lib/screens/RegistroOrganizacion.dart#574-610) (Tipo: `uuid`, Clave Primaria, Valor por defecto: `gen_random_uuid()`)
2. `created_at` (Tipo: `timestampzj`, Valor por defecto: `now()`)
3. `auth_user_id` (Tipo: `uuid`, relacionado con `auth.users.id`). *Esto vincula los datos de la organización con la cuenta de correo para iniciar sesión.*
4. `razon_social` (Tipo: `text`)
5. [nit](file:///c:/Users/ao412/Downloads/maldicion/lib/screens/RegistroOrganizacion.dart#60-66) (Tipo: `text`)
6. `direccion` (Tipo: `text`)
7. `colonia` (Tipo: `text`)
8. `ciudad` (Tipo: `text`)
9. `latitud` (Tipo: `text`)
10. `longitud` (Tipo: `text`)
11. `nombre_responsable` (Tipo: `text`)
12. `cargo` (Tipo: `text`)
13. `telefono` (Tipo: `text`)

> [!IMPORTANT]
> Al crear la tabla, temporalmente **desactiva el RLS (Row Level Security)** o asegúrate de crear una "Policy" (Política) que permita a los usuarios insertar (`INSERT`) datos. De lo contrario, la base de datos rechazará la información por seguridad.

## 2. Cambios Propuestos en el Código (Flutter)

Modificaré el archivo [lib/screens/RegistroOrganizacion.dart](file:///c:/Users/ao412/Downloads/maldicion/lib/screens/RegistroOrganizacion.dart) de la siguiente manera:

#### [MODIFY] [RegistroOrganizacion.dart](file:///c:/Users/ao412/Downloads/maldicion/lib/screens/RegistroOrganizacion.dart)
- **Importaciones:** Añadir `supabase_flutter`.
- **Validaciones:** Añadir comprobaciones en el botón "FINALIZAR REGISTRO" para confirmar que las contraseñas coincidan y que los campos principales no estén vacíos.
- **Autenticación (Paso 1):** Usar `Supabase.instance.client.auth.signUp()` con el email y contraseña proporcionados en los controladores.
- **Guardado de Datos (Paso 2):** Si la cuenta se crea exitosamente, usar `Supabase.instance.client.from('organizaciones').insert({...})` para guardar toda la información de la empresa (razón social, NIT, coordenadas del mapa, etc.), usando el ID de la cuenta recién creada como `auth_user_id`.
- **UI:** Agregar la función [_showFloatingMessage](file:///c:/Users/ao412/Downloads/maldicion/lib/screens/InicioSesion2.dart#248-260) para informar al usuario sobre el progreso ("Creando cuenta...", "Guardando datos...", "¡Registro exitoso!").

## 3. Plan de Verificación
### Verificación Manual
1. El usuario creará la tabla en Supabase siguiendo las instrucciones.
2. Yo aplicaré los cambios en el código de Flutter.
3. El usuario ejecutará la app, llenará el formulario de "Registro de Organización" y le dará a registrar.
4. Revisaremos en el panel de Supabase si el nuevo registro aparece tanto en `Authentication > Users` como en `Table Editor > organizaciones`.
