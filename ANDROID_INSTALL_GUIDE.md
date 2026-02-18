# Guía de Instalación: Android Studio (El Motor que falta)

¡Ya casi estamos! El diagnóstico dice que tienes Flutter (el chasis), pero te falta el **Android SDK** (el motor).
La forma más fácil de instalarlo es descargando **Android Studio**.

## Paso 1: Descargar e Instalar
1.  Ve a la web oficial: [developer.android.com/studio](https://developer.android.com/studio)
2.  Descarga **Android Studio Iguana** (o la versión actual).
3.  Ejecuta el instalador (`.exe`).
4.  Dile a todo que **SÍ** y **Next** (Asegúrate de que la casilla "Android Virtual Device" esté marcada).

## Paso 2: El Primer Arranque (CRÍTICO)
Una vez instalado, **ábrelo**.
1.  Verás un "Setup Wizard". Dale a **Next**.
2.  Elige **"Standard"** (Instalación estándar).
3.  Dale a **Finish**.
4.  **ESPERA**. Empezará a descargar componentes (aprox 1-2 GB). *Esto es lo que nos falta.*

## Paso 2.5: Instalar Herramientas Extra (CRÍTICO)
Para que el PC detecte el celular y acepte licencias:
1.  En la pantalla de bienvenida de Android Studio, ve a **Customize** (izquierda) -> **All settings...** (o pulsa **Configure** -> **SDK Manager**).
2.  Ve a la pestaña **SDK Tools**.
3.  Marca estas casillas:
    *   [x] **Android SDK Command-line Tools (latest)**
    *   [x] **Android SDK Platform-Tools**
    *   [x] **Google USB Driver**
4.  Dale a **Apply** y espera a que instale.

## Paso 3: Aceptar Licencias
Cuando Android Studio termine y te deje en la pantalla de bienvenida, ciérralo.
Vuelve a tu terminal y ejecuta este comando mágico para firmar el papeleo:

```powershell
C:\src\flutter\bin\flutter.bat doctor --android-licenses
```
*(Te preguntará varias veces "Do you accept?". Escribe `y` y Enter a todo).*

---

## Paso Final: Verificar
Ejecuta de nuevo el doctor:
```powershell
C:\src\flutter\bin\flutter.bat doctor
```
Si salen todos los checks en verde `[√]`, ¡ya puedes correr la app en tu celular!
