# Regras padrão do Flutter
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.plugins.** { *; }

# Regra para o plugin de notificações locais
-keep class com.dexterous.flutterlocalnotifications.** { *; }

# O -dontwarn impede que o build falhe por avisos de classes ausentes.
# O -keep garante que as classes não sejam removidas.
-dontwarn com.google.android.play.core.**
-keep class com.google.android.play.core.** { *; }
-keep interface com.google.android.play.core.** { *; }
-keep class com.google.firebase.** { *; }