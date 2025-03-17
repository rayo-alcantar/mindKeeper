import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    // El plugin de Flutter se aplica después de los plugins de Android y Kotlin.
    id("dev.flutter.flutter-gradle-plugin")
}

// Cargar key.properties si existe
val keystoreProperties = Properties().apply {
    val keystorePropertiesFile = file(rootProject.file("app/key.properties"))


    println("📌 Buscando key.properties en: " + keystorePropertiesFile.absolutePath)
    
    if (keystorePropertiesFile.exists()) {
        load(FileInputStream(keystorePropertiesFile))
        println("✅ key.properties cargado correctamente.")
    } else {
        throw GradleException("❌ ERROR: No se encontró android/app/key.properties. Asegúrate de crearlo.")
    }
}

android {
    namespace = "com.Rayoscompany.MindKeeper"
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
        applicationId = "com.Rayoscompany.MindKeeper"
        minSdk = 21
        targetSdk = 35
        
        versionCode = 4 
        versionName = "2.1.2"
    }

    signingConfigs {
        create("release") {
            storeFile = file(keystoreProperties["storeFile"]?.toString() ?: "C:/Users/angel/mindkeeper.jks")
            storePassword = keystoreProperties["storePassword"] as String?
            keyAlias = keystoreProperties["keyAlias"] as String?
            keyPassword = keystoreProperties["keyPassword"] as String?
        }
    }

    buildTypes {
        getByName("release") {
            isMinifyEnabled = false
            isShrinkResources = false
            signingConfig = signingConfigs.getByName("release")
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
