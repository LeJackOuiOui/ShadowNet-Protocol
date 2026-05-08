# 📂 REPORTE DE MISIÓN: PROTOCOLO SHADOWNET

**ESTADO:** CLASIFICADO - SOLO PARA OJOS DE OPERADORES
**AÑO:** 2084
**ORIGEN:** Resistencia de Mosquera (Sector 04)

---

## 👁️‍🗨️ Resumen de la Situación

La IA central, **The Core**, ha tomado control total de la infraestructura de comunicaciones. Este terminal ha sido diseñado para permitir a los Operadores infiltrarse en la red ShadowNet. Para garantizar la seguridad del canal, el acceso está restringido mediante validación biológica (ADN) y coordenadas de proximidad física en zonas libres de interferencia en Mosquera.

## 🔐 Protocolos de Seguridad (Configuración)

### 1. Validación de Identidad (Biometría)

Para que el hardware reconozca tu ADN humano, se han implementado los siguientes ajustes de seguridad en el núcleo Android:

- **Elevación de Privilegios:** El archivo `MainActivity.kt` ha sido modificado para heredar de `FlutterFragmentActivity`, permitiendo el puente de datos con el sensor biométrico.
- **Permisos de Hardware:** Se han inyectado los permisos `USE_BIOMETRIC` y `USE_FINGERPRINT` en el manifiesto principal para burlar las restricciones de The Core.

### 2. Triangulación de Nodos (Geolocalización)

La terminal solo desbloquea misiones si el Operador se encuentra a menos de **500 metros** de los nodos de la resistencia[cite: 1]:

- **Nodo Alpha:** SENA Mosquera (Servidor de notas).
- **Nodo Beta:** Parque Principal (Intercepción de radio).
- **Nodo Gamma:** Zona Industrial (Sabotaje de drones).

## 🛠️ Módulos de Hardware Requeridos (Dependencias)

Para el correcto funcionamiento de esta terminal, el dispositivo debe contar con:

- `local_auth`: Escáner de ADN humano[cite: 1].
- `geolocator`: Triangulación satelital en tiempo real[cite: 1].
- `vibration`: Protocolo de autodestrucción y comunicación Morse[cite: 1].
- `google_fonts`: Interfaz de comandos encriptada (Roboto Mono)[cite: 1].

## ⚠️ Protocolo de Autodestrucción

Si el sistema detecta **3 intentos fallidos** de acceso biométrico, se activará un protocolo de seguridad que bloqueará la terminal y emitirá una vibración de alta frecuencia durante 5 segundos para alertar al Operador de una posible captura[cite: 1].

## 🛰️ Instrucciones de Despliegue

1. Clonar este repositorio mediante un túnel encriptado.
2. Configurar permisos de ubicación y biometría en el dispositivo móvil.
3. Ejecutar `flutter pub get` para descargar los módulos de infiltración.
4. Realizar la prueba biométrica para acceder al radar de nodos.

---

**"La IA calcula, pero la resistencia prevalece."**
