import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    // El plugin de Flutter se aplica después de los plugins de Android y Kotlin.
    id("dev.flutter.flutter-gradle-plugin")
}

// Si ya no quieres usar key.properties, puedes eliminar este bloque por completo.
// Lo mantengo aquí comentado por si deseas reactivarlo más tarde.
/*
val keystoreProperties = Properties().apply {
    val keystorePropertiesFile = file("key.properties")

    if (keystorePropertiesFile.exists()) {
        load(FileInputStream(keystorePropertiesFile))
    } else {
        println("Warning: No se encontró android/key.properties. Asegúrate de crearlo.")
    }
}
*/

android {
    namespace = "com.rayoscompany.mindkeeper"
    ndkVersion = "27.0.12077973"
    compileSdk = 35

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = "11"
    }

    defaultConfig {
        applicationId = "com.rayoscompany.mindkeeper"
        minSdk = 21
        targetSdk = 35
        // Se obtienen las variables de versión inyectadas por Flutter (o se usan valores por defecto).
        versionCode = (project.findProperty("flutterVersionCode") as? String)?.toInt() ?: 1
        versionName = project.findProperty("flutterVersionName") as? String ?: "1.0"
    }

    // Eliminamos signingConfigs y la referencia en buildTypes
    buildTypes {
        getByName("release") {
            // Sin firma local, quedará sin firmar (o firmada con la debug key si no configuras nada más).
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    implementation("androidx.core:core-ktx:1.9.0")
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.2")
}
