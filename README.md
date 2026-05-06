# 🌬️ Air Control

[![Flutter](https://img.shields.io/badge/Flutter-v3.22+-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Riverpod](https://img.shields.io/badge/State%20Management-Riverpod-02569B?style=flat&logo=riverpod&logoColor=white)](https://riverpod.dev)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](http://makeapullrequest.com)

**Air Control** is a revolutionary touchless motion-controlled Flutter application that allows users to interact with their device through physical gestures. By utilizing high-frequency sensor fusion, this app translates tilts and shakes into intuitive UI actions, providing a "magic" hands-free experience.

---

## ✨ Features

- **🚀 Touchless Navigation**: Scroll through content by tilting your phone forward or backward.
- **⭐ Kinetic Rating**: Activate the rating system with a quick shake and set star levels with precise tilts.
- **📡 Advanced Sensor Fusion**: Uses a custom-built motion engine with **Low-Pass Filtering** and **Auto-Calibration** for rock-solid detection.
- **🏗️ Professional Architecture**: Implements **Clean Architecture** (Feature-first) with **Riverpod** Notifiers for testable, scalable code.
- **🎨 Premium Dark UI**: A fluid, TikTok-style interface with micro-animations powered by `flutter_animate`.
- **🛠️ Developer-First**: Clean code patterns, clear folder structure, and comprehensive documentation.

---

## 🏗️ Clean Architecture

The project is structured to demonstrate best practices in modern Flutter development:

- **`core/`**: Centralized themes, constants, and utilities.
- **`services/`**: Infrastructure layer for sensor data and low-level processing.
- **`features/`**: Feature-based modules (e.g., `home`) containing:
  - **`domain/`**: Pure logic, entities, and models.
  - **`data/`**: Repositories and data providers.
  - **`presentation/`**: UI screens, widgets, and Riverpod controllers.

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (v3.22 or higher)
- A physical device (Sensors do not work in most emulators)

### Installation
1. Clone the repository:
   ```bash
   git clone https://github.com/ArbazKhan1645/air_control.git
   ```
2. Navigate to the project folder:
   ```bash
   cd air_control
   ```
3. Install dependencies:
   ```bash
   flutter pub get
   ```
4. Run the application:
   ```bash
   flutter run
   ```

---

## 🛠️ Tech Stack

- **Framework**: [Flutter](https://flutter.dev)
- **State Management**: [Riverpod](https://riverpod.dev)
- **Sensors**: [sensors_plus](https://pub.dev/packages/sensors_plus)
- **Animations**: [flutter_animate](https://pub.dev/packages/flutter_animate)
- **UI Components**: Custom Dark Mode components

---

## 🤝 Contributing

Contributions make the open-source community an amazing place!
1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

## 👨‍💻 Author

**Arbaz Mashwani**
- **Email**: [mashwanikhan192@gmail.com](mailto:mashwanikhan192@gmail.com)
- **GitHub**: [@arbazmashwani](https://github.com/ArbazKhan1645/)

---

## 📄 License

Distributed under the **MIT License**. See `LICENSE` for more information.

---

<p align="center">
  Developed with ❤️ for the Flutter Community
</p>
