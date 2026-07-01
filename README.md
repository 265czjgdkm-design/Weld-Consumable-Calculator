# Weld Consumable Calculator

Professional Flutter web and mobile application for weld volume, weld metal, filler consumption, and planning-oriented estimation.

## Scope

Supported estimator modules:

- Pipe Butt Weld
- Plate Butt Weld
- Fillet Weld

Advanced visual development module:

- Branch Connections
  - Set-on Nozzle
  - Set-in Nozzle
  - Weldolet

Current calculation focus:

- Weld area
- Weld length
- Weld volume
- Weld metal weight
- Filler or electrode consumption
- Average arc-on time
- Deposition efficiency
- Effective deposition rate

## Product Direction

This product is being shaped as:

- an engineering calculator first
- a technical visual explainer second
- a report-ready planning tool third

The goal is to make it useful for:

- welding engineers
- estimators
- workshop planners
- client-facing technical teams

## Tech Stack

- Flutter
- Dart
- Flutter Web
- CustomPainter for technical drawing
- PDF reporting
- Shared preferences for local presets

## Current Capabilities

- Live joint and groove selection
- Technical and visual drawing modes
- Unequal member geometry support
- AWS consumable classification selection
- Manual and preset deposition-rate basis
- User preset save, update, and delete flow
- PDF export path
- Branch connection visualization workspace

## Local Run

```bash
flutter pub get
flutter run -d chrome
```

## Quality Checks

```bash
dart analyze
flutter test
```

## Operating System

This repository includes a lightweight operating system for continuous improvement:

- [TEAM_OPERATING_SYSTEM.md](./TEAM_OPERATING_SYSTEM.md)
- [PRODUCT_ROADMAP.md](./PRODUCT_ROADMAP.md)
- [docs/GITHUB_SETUP.md](./docs/GITHUB_SETUP.md)

## GitHub Ready

This project is prepared for GitHub with:

- CI workflow
- nightly health-check workflow
- issue templates
- pull request template
- contribution guide

## Notes

This application is intended for estimation and planning support. It is not a substitute for approved WPS, PQR, code compliance review, or formal release documentation.
