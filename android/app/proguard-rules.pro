# Stripe SDK
-keep class com.stripe.** { *; }
-keep class com.reactnativestripesdk.** { *; }
-dontwarn com.stripe.**
-dontwarn com.reactnativestripesdk.**
-keep class ru.yoomoney.sdk.** { *; }
-keep class com.yandex.** { *; }
# Разрешить классы VK SDK
-keep class com.vk.** { *; }
-keep class ru.yoomoney.** { *; }
-dontwarn com.vk.**
-dontwarn ru.yoomoney.**
-keepattributes *Annotation*
-keep class java.beans.** { *; }
-keep class org.slf4j.** { *; }
-keep class com.fasterxml.jackson.** { *; }
