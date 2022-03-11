# anhi

A tool that helps reliably memorize passwords and other secrets.

## Building

Non-exhaustively, you will need to install at least:
- Android Studio, which can be installed from the [official Android Studio homepage](https://developer.android.com/studio). Alternatively, you can install only the [Android command line tools](https://developer.android.com/studio/#command-tools) from the same page.
- The Android NDK **version 22**, which can be installed from within Android Studio by following [this guide](https://developer.android.com/studio/projects/install-ndk) (no need to install CMake). Alternatively, you can download it yourself from [this page](https://github.com/android/ndk/wiki/Unsupported-Downloads). If you have the Android command line tools, you can install it by running `sdkmanager --install "ndk;22.1.7171670"`.
- Flutter, which can be installed by following the [official Flutter installation instructions](https://docs.flutter.dev/get-started/install).
- Rustup, which can be installed by following the [official Rustup installation instructions](https://rustup.rs/).
- `flutter_rust_bridge_codegen`, which can be installed with `cargo install flutter_rust_bridge_codegen`
- `cargo-ndk`, which can be installed with `cargo install cargo-ndk`
- The required Rust targets, which can be installed with
    ```sh
    rustup target add \
        aarch64-linux-android \
        armv7-linux-androideabi \
        x86_64-linux-android \
        i686-linux-android
    ```

After installation, it is necessary to set the installation location of the Android NDK in your gradle.properties (for example in `~/.gradle/gradle.properties`) like so:
```
ANDROID_NDK=/path/to/ndk/22.1.7171670/
```

If you modify the native code, you'll need to regenerate the bindings with the following commands:
```sh
export ANHI_PATH=$(pwd)
cd /
flutter_rust_bridge_codegen -r $ANHI_PATH/native/src/api.rs -d $ANHI_PATH/lib/bridge_generated.dart
```
Changing directory to root is a workaround for a bug in the Flutter-Rust Bridge.

At this point, you can use the normal mechanisms for building a Flutter application.