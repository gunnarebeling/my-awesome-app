import 'dart:io';

enum Flavor {
  develop,
  staging,
  production,
}

class F {
  static Flavor appFlavor = Flavor.develop;

  static bool get isDevelop => appFlavor == Flavor.develop;
  static bool get isStaging => appFlavor == Flavor.staging;
  static bool get isProduction => appFlavor == Flavor.production;

  static String get title {
    switch (appFlavor) {
      case Flavor.develop:
        return 'Pickup Play Develop';
      case Flavor.staging:
        return 'Pickup Play Volatile';
      case Flavor.production:
        return 'Pickup Play';
    }
  }

  static String get apiUrl {
    switch (appFlavor) {
      case Flavor.develop:
        final emulatorUrl = Platform.isAndroid ? 'http://10.0.2.2:3000' : 'http://127.0.0.1:3000';
        return emulatorUrl;
      case Flavor.staging:
        const stagingUrl = 'https://volatile.pickupplay.games';
        return stagingUrl;
      case Flavor.production:
        // TODO: change to production url
        final emulatorUrl = Platform.isAndroid ? 'http://10.0.2.2:3000' : 'http://127.0.0.1:3000';
        return emulatorUrl;
    }
  }
}
