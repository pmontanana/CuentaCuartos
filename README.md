# CuentaCuartos

**CuentaCuartos** es una aplicación nativa para iOS y watchOS diseñada para llevar el control absoluto de tus finanzas personales, gastos e ingresos de forma rápida y sencilla. Cuenta con sincronización en la nube en tiempo real y una app compañera para tu muñeca.

## Características Principales

### 💻📱 En el iPhone y MacOS
- **Gestión Inteligente**: Registra ingresos y gastos asociados a categorías y cuentas (tarjetas, efectivo, cuentas bancarias).
- **Dashboard Visual**: Gráficos interactivos construidos con *Swift Charts* para analizar rápidamente la salud de tu economía.
- **Sincronización en la Nube**: Todos tus datos se guardan de forma segura usando **Firebase Firestore**, permitiendo sincronización instantánea entre todos tus dispositivos.
- **Autenticación Segura**: Sistema de login completo usando **Firebase Authentication** (correo electrónico y Google).
- **Modo Oscuro**: Interfaz moderna y adaptativa que respeta las preferencias de tu sistema operativo.

### ⌚️ En el Apple Watch
- **Dashboard en tu muñeca**: Revisa tu saldo actual, ingresos y gastos semanales directamente desde el reloj.
- **WatchConnectivity**: Sincronización ultrarrápida por Bluetooth/WiFi. El iPhone procesa los datos y los envía al reloj, ahorrando batería al no depender de una conexión directa de red en el Watch.
- **Gráficos Nativos**: Gráfica circular (donut) de ingresos vs gastos implementada con *Swift Charts* optimizada para watchOS.

## Tecnologías y Stack

El proyecto sigue una arquitectura moderna recomendada por Apple, estructurada bajo el patrón MVVM y las últimas novedades de Swift.

*   **Lenguaje**: Swift 5.0+
*   **UI**: SwiftUI
*   **Gestión de Estados**: Combine (`ObservableObject`, `@Published`)
*   **Gráficos**: Swift Charts nativo
*   **Backend & DB**: Firebase-iOS-SDK (Auth, Firestore) vía Swift Package Manager.
*   **WatchOS**: WatchConnectivity para sincronización de estados.

## Instalación y Configuración

1. **Clona el repositorio:**
   ```bash
   git clone https://github.com/pmontanana/CuentaCuartos.git
   ```

2. **Requisitos:**
   - **Xcode 16** o superior.
   - Dispositivos con **iOS 17+** y **watchOS 10+** (recomendado).

3. **Configuración de Firebase:**
   - Crea un proyecto en [Firebase Console](https://console.firebase.google.com/).
   - Habilita **Authentication** (Email/Password) y **Firestore Database**.
   - Descarga el archivo `GoogleService-Info.plist` y arrástralo a la carpeta raíz del proyecto en Xcode.
   - *(El archivo `GoogleService-Info.plist` está ignorado en git por razones de seguridad).*

4. **Compilación:**
   - Selecciona el target `CuentaCuartos` y compila en un simulador o dispositivo iPhone real.
   - Para ver la app del reloj, asegúrate de añadir el target correspondiente o usar un dispositivo físico emparejado.

## 📄 Licencia

Este proyecto está licenciado bajo la **GNU General Public License v3.0 (GPL-3.0)**. 
Para más detalles, revisa el archivo [LICENSE](LICENSE) incluido en este repositorio.

Eres libre de usar, modificar y distribuir este software, siempre y cuando cualquier trabajo derivado mantenga la misma licencia y sea de código abierto.

---
*Desarrollado con ❤️ para mantener las cuentas siempre claras.*

