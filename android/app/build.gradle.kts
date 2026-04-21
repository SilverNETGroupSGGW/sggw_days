import org.jetbrains.kotlin.gradle.dsl.JvmTarget

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

android {
    namespace = "com.silvernet.sggw_days"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_21
        targetCompatibility = JavaVersion.VERSION_21
    }

    defaultConfig {
        applicationId = "com.silvernet.sggw_days"
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            keyAlias = System.getenv("KEYSTORE_ALIAS")
            keyPassword = System.getenv("KEYSTORE_ALIAS_PASSWORD")
            val keystorePath = System.getenv("KEYSTORE_PATH")
            storeFile = if (keystorePath != null) {
                file(keystorePath)
            } else {
                null
            }
            storePassword = System.getenv("KEYSTORE_PASSWORD")
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget.set(JvmTarget.fromTarget(JavaVersion.VERSION_21.toString()))
    }
}

dependencies {
  implementation(platform("com.google.firebase:firebase-bom:34.12.0"))
  implementation("com.google.firebase:firebase-analytics")
}

flutter {
    source = "../.."
}
