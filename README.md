# 📂 SHADOWNET PROTOCOL — OPERACIÓN CAMALEÓN

**ESTADO DE LA TERMINAL:** ACTUALIZADO M3 (MATERIAL 3 APPROVED)
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

## 🎨 Extracción Dinámica de SeedColor

Para cumplir con los parámetros dinámicos del canal, la aplicación extrae la identidad cromática de la facción activa directamente mediante el generador de esquemas Material 3:

- **Hacker:** Genera una paleta de alto contraste basada en Verde Fósforo (`0xFF00FF41`).
- **Enforcer:** Despliega una alerta de combate utilizando Rojo Táctico (`0xFFFF3B30`).
- **Ghost:** Aplica un camuflaje espectral mediante Azul Neón (`0xFF00C6FF`).

El `ColorScheme.fromSeed` calcula automáticamente los tonos complementarios para componentes nativos (como contenedores de misiones, AppBars y botones) asegurando homogeneidad en la UI.

## 👁️ Árbol de Semantics (Accesibilidad Operativa)

Se reestructuró la terminal para evadir bloqueos de auditoría de hardware mediante la inyección estructurada de widgets `Semantics`:

1. **Etiquetado de Botones Primitivos:** El botón de purga fue mapeado explícitamente para lectores de voz: _"Finalizar misión y borrar rastro"_.
2. **Descripciones de Estado Dinámicas:** El logo hereda dinámicamente un tag descriptivo de la especialidad de la facción en curso.
3. **Fusión de Contenedores:** La telemetría y lista de nodos agrupan sus textos hijos en un solo mensaje fluido para evitar lecturas fragmentadas en los lectores de pantalla.

## 🛰️ Instrucciones de Despliegue

1. Clonar este repositorio mediante un túnel encriptado.
2. Configurar permisos de ubicación y biometría en el dispositivo móvil.
3. Ejecutar `flutter pub get` para descargar los módulos de infiltración.
4. Realizar la prueba biométrica para acceder al radar de nodos.

---

**"La IA calcula, pero la resistencia prevalece."**
