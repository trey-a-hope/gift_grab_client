import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class FixedMacOsOptions extends MacOsOptions {
  const FixedMacOsOptions({super.useDataProtectionKeyChain});

  @override
  Map<String, String> toMap() {
    // Before sending data to macOS, convert settings
    // into a standard map.
    final map = super.toMap();

    // Look inside the map for the key 'usesDataProtectionKeychain'.
    final value = map['usesDataProtectionKeychain'];

    // If it finds the value, it duplicates it under a new key name, 'useDataProtectionKeyChain'.
    if (value != null) {
      map['useDataProtectionKeyChain'] = value;
    }

    return map;
  }
}
