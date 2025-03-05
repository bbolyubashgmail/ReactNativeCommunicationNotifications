1. Робимо звичайні базові налаштування пуш нотифікацій, необхідні для отримання загальних нотифікацій з допомогою firabase і notifee

2. В Xcode додаємо Communication Notifications Capability

3. В info.plist додаємо <key>NSUserActivityTypes</key><array><string>INSendMessageIntent</string></array>

4. Дальше нам необхідно створити Notification Service Extension в Xcode як це описано тут - https://notifee.app/react-native/docs/ios/remote-notification-support#add-the-notification-service-extension. Робимо всі кроки окрім https://notifee.app/react-native/docs/ios/remote-notification-support#2-in-a-notification-service-extension-in-your-app-when-a-device-receives-a-remote-message

  Після цього кроку може виникнути бага:  коли запускаєш білд на IOS, в якому буде писати помилка про зациклення між main_app_target і NotifeeNotificationService. Щоб цю багу забрати треба в Xcode main_app_target ввійти в Build Phases і перемістити Embed Foundation       Extensions із останньої позиції, поставивши після Copy Bundle Resources.


Імовірно, на деяких системах айфону, може виникнути дублювання пушів: коли додаток закритий, приходить пуш, і після відкриття додатку цей пуш дублюється. Для рішення треба зробити наступні кроки:

1. В Info.plist додаємо <key>FirebaseAppDelegateProxyEnabled</key><false/>

2. Редагуємо AppDelegate.m зі всіма змінами, які там вказані

