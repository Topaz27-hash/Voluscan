# VoluScan

Cross-platform Flutter MVP for Android and iPhone.

## Included

- Camera capture and assisted scan flow
- Manual length, width, and height entry in centimetres
- Editable volumetric divisor (default: 5000)
- Optional actual weight
- Automatic volumetric and chargeable-weight calculation
- Printable/shareable PDF parcel receipt
- Unit tests for calculation logic

## Run

1. Install Flutter 3.24 or newer.
2. In this folder, run `flutter create .` to generate missing native build files.
3. Restore `android/app/src/main/AndroidManifest.xml` from this package if Flutter overwrites it.
4. Add the camera usage key shown in `ios/Runner/Info.plist.notes` to the generated iOS Info.plist.
5. Run `flutter pub get`.
6. Connect a physical Android phone or iPhone and run `flutter run`.

## Build an Android APK with GitHub

The project contains `.github/workflows/build-android.yml`. Push the project to
a GitHub repository and the workflow will generate the Android platform files,
run the tests, build a release APK, and upload it as the
`VoluScan-Android-APK` workflow artifact.

## Production scanning note

This MVP captures the parcel through the camera and lets the operator confirm its measurements. Fully automatic real-world dimensions require a native ARCore/ARKit measurement engine, device calibration, box-edge detection, and testing across supported phones. The rest of the app is intentionally independent of that engine so it can be added next without changing the calculation or receipt flow.
