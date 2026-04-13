plugins {
    id("com.android.application")
    id("com.google.gms.google-services")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.nelson.caminho_do_saber"
    compileSdk = 36
    ndkVersion = flutter.ndkVersion

    compileOptions {
        // Habilita desugaring para suportar APIs Java modernas
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = "11"
    }

    defaultConfig {
        applicationId = "com.nelson.caminho_do_saber"
        minSdk = 24
        targetSdk = 36
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    // Suporte crucial para 16 KB Page Size (Android 15+)
    packaging {
        jniLibs {
            useLegacyPackaging = false
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Adiciona a biblioteca necessária para o desugaring
    add("coreLibraryDesugaring", "com.android.tools:desugar_jdk_libs:2.1.5")
}
