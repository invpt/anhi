import 'dart:ffi';
import 'dart:io';

import 'package:anhi/bridge_generated.dart';
export 'package:anhi/bridge_generated.dart';

const base = 'anhi_native';
final path = Platform.isWindows ? '$base.dll' : 'lib$base.so';
late final dylib = Platform.isIOS
    ? DynamicLibrary.process()
    : Platform.isMacOS
        ? DynamicLibrary.executable()
        : DynamicLibrary.open(path);
late final native = AnhiNativeImpl(dylib);