# ViTextInputFormatter

[![style: very good analysis][very_good_analysis_badge]][very_good_analysis_link]
[![Powered by Mason][mason_badge]][mason_link]
[![License: BSD 3-Clause][license_badge]][license_link]

Simple Flutter package for direct Vietnamese text inputting

Provides `ViTextInputFormatter`, which mimics Unikey (Unicode, Telex)

## Usage

```dart
TextField(
    inputFormatters: [ViTextInputFormatter()],
),
```

>[!NOTE]
> Device's Vietnamese input programs must be turned off when typing on a `TextField` that uses `ViTextInputFormatter`.

[very_good_analysis_badge]: https://img.shields.io/badge/style-very_good_analysis-B22C89.svg
[very_good_analysis_link]: https://pub.dev/packages/very_good_analysis
[mason_badge]: https://img.shields.io/endpoint?url=https%3A%2F%2Ftinyurl.com%2Fmason-badge
[mason_link]: https://github.com/felangel/mason
[license_badge]: https://img.shields.io/badge/License-BSD%203--Clause-blue.svg
[license_link]: https://opensource.org/license/bsd-3-clause