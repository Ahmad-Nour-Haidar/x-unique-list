# XUniqueList - A Dart/Flutter Package for Managing Unique Lists

`XUniqueList` is a high-performance utility for managing lists with **custom uniqueness rules**.

Instead of relying on object equality (`==`), you define a `uniqueCondition` (e.g., `id`), and the
list guarantees that no two items share the same unique key.

### Platform Support

| Android |   IOS   |   Web   |  MacOS  |  Linux  | Windows |
|:-------:|:-------:|:-------:|:-------:|:-------:|:-------:|
| &#9989; | &#9989; | &#9989; | &#9989; | &#9989; | &#9989; |

## 📜 Table of Contents

- [✨ Features](#-features)
- [🚀 Getting Started](#-getting-started)
- [📄 License](#-license)

## ✨ Features

- 🆔 **Custom Uniqueness** — enforce uniqueness using any field (e.g., `id`)
- ➕ **Add / Replace Smartly** — avoid duplicates or replace existing items
- ⚡ **Fast Lookups** — O(1) existence checks via internal `Set`
- 🔄 **Safe Mutations** — keeps internal structures always in sync
- 📦 **Flexible Access** — modifiable & unmodifiable views

## 🚀 Getting Started

To start using `XUniqueList`, you need to add the following dependency to your `pubspec.yaml` file:

```yaml
dependencies:
  x_unique_list: ^1.1.0
```

```bash
flutter pub get
```

```bash
dart pub get
```

## 📄 License

This package is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.