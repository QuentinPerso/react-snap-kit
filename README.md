# React-Native SnapchatKit

- [1. Change Log](#changelog)
- [2. Installation](#installation)
- [3. Project configuration](#projectConfiguration)
- [4. Usage](#usage)

<a id="changelog"></a>
## 1. Change Log

* **v1.0.0** :
    - Brand new React Native Snaps  

<a id="installation"></a>
## 2. SDK Instalation

From your project folder: 

#### yarn

```bash
$ yarn add git+https://github.com/QuentinbTahi/react-snap-kit.git -- save
```

#### npm

```bash
$ npm install git+https://github.com/QuentinbTahi/react-snap-kit.git -- save
```

<a id="projectConfiguration"></a>
## 3. Project configuration

### 3.2 iOS configuration

#### 3.2.1 Change min iOS version : 

Edit your `Podfile` min version to 10 : `platform :ios, '10.0'`

#### 3.2.2 Run `$ pod install` from iOS folder : 

```bash
$ cd ios && pod install
```
or
```bash
$ react-native link react-native-snapchat-kit`
```
#### 3.2.3 Edit info.plist file : 

Add to `Info.plist`

```xml
<key>SCSDKClientId</key>
<string>YOUR CLIENT ID</string>

<key>SCSDKRedirectUrl</key>
<string>YOUR REDIRECT URL</string>

<key>SCSDKScopes</key>
<array>
     <string>https://auth.snapchat.com/oauth2/api/user.display_name</string>
    <string>https://auth.snapchat.com/oauth2/api/user.bitmoji.avatar</string>
</array>

<key>LSApplicationQueriesSchemes</key>
<array>
    <string>snapchat</string>
    <string>bitmoji-sdk</string>
    <string>itms-apps</string>
</array>
```

**REMEMBER** Add the app url to your URL Types on Xcode config.


#### 3.2.4 Update the `AppDelegate.m` (Login only) :

```objc
#import <SCSDKLoginKit/SCSDKLoginKit.h>

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
            options:(NSDictionary<UIApplicationOpenURLOptionsKey, id> *)options {
  if ([SCSDKLoginClient application:application openURL:url options:options]) {
    return YES;
  }
  
  return NO;
}
```

### 3.3 Android configuration

#### 3.3.1 Update build.gradle :

Update `android/build.gradle` with the min SDK Version :
```json
minSdkVersion = 19
```
and add to your repositories list :
```json
maven {
    url "https://storage.googleapis.com/snap-kit-build/maven"
}
```

#### 3.3.2 Update `AndroidManifest.xml` :

Add the INTERNET permission
```
<uses-permission android:name="android.permission.INTERNET" />
```

Add this to your application
```
<meta-data android:name="com.snapchat.kit.sdk.clientId" android:value="YOUR CLIENT ID" />
<meta-data android:name="com.snapchat.kit.sdk.redirectUrl" android:value="YOUR REDIRECT URL" />
<meta-data android:name="com.snapchat.kit.sdk.scopes" android:resource="@array/snap_connect_scopes" />

<activity android:name="com.snapchat.kit.sdk.SnapKitActivity" android:launchMode="singleTask">
    <intent-filter>
        <action android:name="android.intent.action.VIEW" />
        <category android:name="android.intent.category.DEFAULT" />
        <category android:name="android.intent.category.BROWSABLE" />
        <!--
            Enter the parts of your redirect url below
            e.g., if your redirect url is myapp://snap-kit/oauth2
                android:scheme="myapp"
                android:host="snap-kit"
                android:path="/oauth2"
        !-->
        <data
            android:scheme="the scheme of your redirect url"
            android:host="the host of your redirect url"
            android:path="the path of your redirect url"
        />
    </intent-filter>
</activity>
```

#### 3.3.3 Create a new file `values/arrays.xml` :
```
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <string-array name="snap_connect_scopes">
        <item>https://auth.snapchat.com/oauth2/api/user.display_name</item>
        <item>https://auth.snapchat.com/oauth2/api/user.bitmoji.avatar</item>
    </string-array>
</resources>
```

<a id="usage"></a>
## 4. Usage

### 4.1 Login

```javascript
import SnapchatKit from 'react-native-snapchat-kit';

SnapchatKit.login() 
SnapchatKit.isLogged()
SnapchatKit.logout()
SnapchatKit.getUserInfo()
```

### 4.1 Creative

```javascript
import SnapchatKit from 'react-native-snapchat-kit';

SnapchatKit.sharePhotoAtUrl(photoUrl, stickerUrl, stickerPosX, stickerPosY, attachmentUrl, caption)
```
