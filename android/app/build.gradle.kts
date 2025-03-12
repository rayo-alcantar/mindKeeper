plugins {
    id("com.android.application")
    id("kotlin-android")
    // El plugin de Flutter debe aplicarse después de los plugins de Android y Kotlin.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    ndkVersion = "27.0.12077973"
    namespace = "com.example.mindkeeper"

    // Actualizamos compileSdk a 35 para cumplir con los requisitos de los plugins.
    compileSdk = 35

    compileOptions {
        // Cambiamos la compatibilidad a Java 11.
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
        // Habilita el core library desugaring para utilizar características de Java 8/11 en bibliotecas de terceros.
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        // Se usa jvmTarget 11 para Kotlin.
        jvmTarget = "11"
    }

    defaultConfig {
        applicationId = "com.example.mindkeeper"
        minSdk = 21
        targetSdk = 35
        versionCode = 1
        versionName = "1.0.0"
    }

    buildTypes {
        release {
            // Usa la configuración de debug para firmar el release (ajusta esto según tus necesidades).
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Dependencia recomendada para funciones de extensión en Android.
    implementation("androidx.core:core-ktx:1.9.0")
    // Agrega la dependencia para el core library desugaring.
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.2")
}
