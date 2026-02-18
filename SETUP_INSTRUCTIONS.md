# Configuración Móvil Requerida

Actualmente el proyecto Flutter es solo "código", le faltan las carpetas nativas (`android` e `ios`) para poder compilarse en tu celular.

## Pasos para Activar tu Celular:

0.  **Instalar Flutter**:
    Parece que tu Winget no encuentra el paquete. Prueba estos dos comandos en orden:
    
    a) Actualiza las fuentes:
    ```bash
    winget source update
    ```
    b) Intenta instalar de nuevo:
    ```bash
    winget install Google.Flutter
    ```
    
    **¿Sigue fallando?** 
    Descarga el ZIP oficial aquí: [Flutter Windows SDK](https://storage.googleapis.com/flutter_infra_release/releases/stable/windows/flutter_windows_3.16.9-stable.zip)
    Descomprímelo en `C:\src\flutter` y añade `C:\src\flutter\bin` a tu PATH.

1.  **Abre tu Terminal** (PowerShell o CMD).
2.  Navega a la carpeta del proyecto:
    ```bash
    cd c:\Users\jacko\.gemini\antigravity\playground\galactic-voyager\vision_therapy_app
    ```
3.  **Genera los archivos nativos**:
    ```bash
    flutter create .
    ```
    *(Este comando creará las carpetas que faltan).*

4.  **Configura Permisos de Cámara** (Crítico para que la app vea):
    *   **Android**: Ve a `android/app/src/main/AndroidManifest.xml` y pega esto antes de `<application>`:
        ```xml
        <uses-permission android:name="android.permission.CAMERA"/>
        ```
    *   **iOS**: Ve a `ios/Runner/Info.plist` y añade:
        ```xml
        <key>NSCameraUsageDescription</key>
        <string>Necesitamos la cámara para el tracking ocular.</string>
        ```

5.  **Conectar tu Celular (El Puente)**:
    Para que la app "salte" de tu PC a tu celular, necesitas un cable USB y un modo especial.

    **Si tienes Android (Recomendado en Windows):**
    1.  Ve a *Ajustes > Acerca del teléfono*.
    2.  Toca 7 veces en **"Número de compilación"** hasta que diga "Ya eres desarrollador".
    3.  Ve a *Ajustes > Sistema > Opciones para desarrolladores*.
    4.  Activa **"Depuración por USB"**.
    5.  Conecta el celular al PC con cable. Autoriza la conexión en la pantalla del celular.

    **Si tienes iPhone:**
    *Nota: Desde Windows no se puede instalar directamente en iPhone (necesitas una Mac).*
    *Si usas iPhone, avísame para buscar alternativas.*

6.  **Ejecutar (El Salto)**:
    Ahora sí, en la terminal:
    ```powershell
    C:\src\flutter\bin\flutter.bat run
    ```
    *La primera vez tardará unos minutos compilando.*

    **¿Error de `ZipFile` o `Gradle task failed`?**
    Si la descarga se cortó (por el cable flojo), el archivo de instalación se corrompió.
    1.  Ve a `C:\Users\tu_usuario\.gradle` y **borra esa carpeta**.
    2.  Vuelve a ejecutar `flutter run`. (Volverá a descargar todo limpio).
    Si al correr el comando SOLO ves `[1] Windows`, `[2] Chrome`, etc., es que **tu PC no ve el celular**.
    1.  Asegúrate de que la pantalla del celular esté encendida.
    2.  Mira si ha salido una ventana emergente en el celular preguntando "¿Confiar en este ordenador?". **Dile que SÍ.**
    3.  Prueba a desconectar y conectar el cable.
    4.  Ejecuta `C:\src\flutter\bin\flutter.bat devices` para verificar si ya aparece.
