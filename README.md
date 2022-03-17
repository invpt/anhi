# anhi

A tool that helps reliably memorize passwords and other secrets.

## Contributing

PRs are welcome.

### Build dependencies

To build Anhi, you will need to:
- Install Android Studio, which can be installed from the [official Android Studio homepage](https://developer.android.com/studio). Alternatively, you can install only the [Android command line tools](https://developer.android.com/studio/#command-tools) from the same page.
- Install the Android NDK **version 22**, which can be installed from within Android Studio by following [this guide](https://developer.android.com/studio/projects/install-ndk) (no need to install CMake). Alternatively, you can download it yourself from [this page](https://github.com/android/ndk/wiki/Unsupported-Downloads). If you have the Android command line tools, you can install it by running `sdkmanager --install "ndk;22.1.7171670"`.
- Install Flutter by following the [official installation instructions](https://docs.flutter.dev/get-started/install).
- Install Rustup by following the [official installation instructions](https://rustup.rs/).
- Install `flutter_rust_bridge_codegen` by following [the official installation instructions](https://cjycode.com/flutter_rust_bridge/tutorial_with_flutter.html#optional-run-generator).
- Install `cargo-ndk` with `cargo install cargo-ndk`
- Install the required Rust targets by running the following command:
    ```sh
    rustup target add \
        aarch64-linux-android \
        armv7-linux-androideabi \
        x86_64-linux-android \
        i686-linux-android
    ```
- Set the installation location of the Android NDK in your gradle.properties file (e.g. `~/.gradle/gradle.properties`) with contents similar to the following:
    ```
    ANDROID_NDK=/path/to/ndk/22.1.7171670/
    ```

### Regeneration of bridge code

If you modify the native code, you'll need to regenerate the bridge code with the following command:
```sh
flutter_rust_bridge_codegen -r $ANHI_PATH/native/src/api.rs -d $ANHI_PATH/lib/bridge_generated.dart
```
If this does not seem to work, try the workaround of changing your working directory to `/`:
```sh
export ANHI_PATH=$(pwd)
cd /
flutter_rust_bridge_codegen -r $ANHI_PATH/native/src/api.rs -d $ANHI_PATH/lib/bridge_generated.dart
```
This is due to a problem with `flutter_rust_bridge`.
