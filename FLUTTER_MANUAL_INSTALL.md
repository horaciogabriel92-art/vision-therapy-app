# Protocolo de Instalación Manual de Flutter (Método Infalible)

Si `winget` te da problemas, no te preocupes. El método oficial "manual" es el más seguro. Sigue estos 4 pasos exactos:

## Paso 1: Descargar el Motor
1.  Haz clic en este enlace oficial para descargar el SDK de Windows:
    👉 [**Descargar flutter_windows_3.19.0-stable.zip**](https://storage.googleapis.com/flutter_infra_release/releases/stable/windows/flutter_windows_3.19.0-stable.zip)
2.  Espera a que termine la descarga (son ~1GB).

## Paso 2: "Instalar" (Descomprimir)
1.  Ve a tu disco `C:\`.
2.  Crea una carpeta nueva llamada `src` (ejemplo: `C:\src`).
3.  Abre el ZIP que descargaste.
4.  Arrastra la carpeta `flutter` del ZIP dentro de `C:\src`.
    *   *Deberías acabar teniendo: `C:\src\flutter`*
    *   *Y dentro de esa, `C:\src\flutter\bin`, etc.*

## Paso 3: Conectar al Sistema (El PATH)
Para que tu terminal entienda el comando `flutter`, necesitas decirle dónde está.
1.  Presiona la tecla **Windows** y escribe "env".
2.  Selecciona **"Editar las variables de entorno del sistema"**.
3.  Clic en el botón **"Variables de entorno..."**.
4.  En la lista de abajo (**Variables del sistema**), busca la fila llamada **Path** y hazle doble clic.
5.  Clic en **"Nuevo"** y pega esta ruta exacta:
    `C:\src\flutter\bin`
6.  Clic en **Aceptar** en todas las ventanas.

## Paso 4: Verificar
1.  Cierra cualquier terminal que tengas abierta.
2.  Abre una nueva (PowerShell o CMD).
3.  Escribe:
    ```bash
    flutter doctor
    ```
4.  Si sale texto procesando... **¡FELICIDADES! Ya tienes Flutter.**

---

### ¿Y después?
Una vez que `flutter doctor` funcione, vuelve a la carpeta de tu proyecto y ejecuta:
```bash
cd c:\Users\jacko\.gemini\antigravity\playground\galactic-voyager\vision_therapy_app
flutter create .
flutter run
```
