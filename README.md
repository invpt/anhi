# anhi

A tool that helps reliably memorize passwords and other secrets.

## Building

You'll need a number of things installed. Also, if you modify the native code, you'll need to regenerate the bindings with the following commands:
```sh
export ANHI_PATH=$(pwd)
cd /
flutter_rust_bridge_codegen -r $ANHI_PATH/native/src/api.rs -d $ANHI_PATH/lib/bridge_generated.dart
```
Changing directory to root is a workaround for a bug in the Flutter-Rust Bridge.