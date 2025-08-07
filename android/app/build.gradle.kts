plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}
//val dartDefines = mutableMapOf<String, String>()
//if (project.hasProperty("dart-defines")) {
//    val encodedDefines = project.property("dart-defines") as String
//    encodedDefines.split(",").forEach { entry ->
//        val decodedEntry = String(Base64.getDecoder().decode(entry), Charsets.UTF_8)
//        val pair = decodedEntry.split("=")
//        if (pair.size == 2) {
//            dartDefines[pair[0]] = pair[1]
//        }
//    }
//}
android {
    namespace = "com.sirteefyapps.food"
    compileSdk = 35
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.sirteefyapps.food"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = 23
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
//        resValue("string", "google_maps_api_key", dartDefines.get("GOOGLE_MAPS_API_KEY")!!)

    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
}
