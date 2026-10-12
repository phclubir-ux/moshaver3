#!/usr/bin/env bash
set -e

echo "=== 1) Install tools ==="
sudo apt-get update -qq
sudo apt-get install -y openjdk-17-jdk wget unzip imagemagick > /dev/null

echo "=== 2) Android SDK ==="
mkdir -p $HOME/android-sdk/cmdline-tools
cd $HOME/android-sdk/cmdline-tools
wget -q https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip
unzip -q commandlinetools-linux-11076708_latest.zip
mv cmdline-tools latest
export ANDROID_HOME=$HOME/android-sdk
yes | $ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager --licenses > /dev/null || true
 $ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager "platform-tools" "platforms;android-34" "build-tools;34.0.0" > /dev/null

echo "=== 3) Project files ==="
cd $GITHUB_WORKSPACE
mkdir -p app/src/main/java/ir/physicstory/moshaver
mkdir -p app/src/main/res/values
mkdir -p app/src/main/res/mipmap-anydpi-v26
mkdir -p app/src/main/res/mipmap-mdpi
mkdir -p app/src/main/res/mipmap-hdpi
mkdir -p app/src/main/res/mipmap-xhdpi
mkdir -p app/src/main/res/mipmap-xxhdpi
mkdir -p app/src/main/res/mipmap-xxxhdpi

cat > settings.gradle <<'PJE'
pluginManagement { repositories { google(); mavenCentral(); gradlePluginPortal() } }
dependencyResolutionManagement { repositories { google(); mavenCentral() } }
rootProject.name = "Moshaver"
include ':app'
PJE

cat > build.gradle <<'PJE'
plugins { id 'com.android.application' version '8.1.4' apply false }
PJE

cat > gradle.properties <<'PJE'
android.useAndroidX=true
android.enableJetifier=true
org.gradle.jvmargs=-Xmx2g
PJE

cat > app/build.gradle <<'PJE'
plugins { id 'com.android.application' }
android {
    namespace 'ir.physicstory.moshaver'
    compileSdk 34
    defaultConfig {
        applicationId "ir.physicstory.moshaver"
        minSdk 23
        targetSdk 34
        versionCode 1
        versionName "1.0"
    }
    signingConfigs {
        release {
            storeFile file('keystore.jks')
            storePassword 'MoshaApp1405'
            keyAlias 'moshaver'
            keyPassword 'MoshaApp1405'
        }
    }
    buildTypes {
        release {
            minifyEnabled false
            signingConfig signingConfigs.release
        }
    }
}
dependencies {
}
PJE

echo "=== VERIFY ==="
if grep -q appcompat app/build.gradle; then echo "WARNING: old file detected (appcompat present)"; else echo "OK: new file confirmed"; fi

cat > app/src/main/AndroidManifest.xml <<'PJE'
<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <uses-permission android:name="android.permission.INTERNET"/>
    <application
        android:label="مهندس احمدپور"
        android:icon="@mipmap/ic_launcher"
        android:usesCleartextTraffic="false"
        android:supportsRtl="true">
        <activity
            android:name=".MainActivity"
            android:exported="true"
            android:configChanges="orientation|screenSize|keyboardHidden"
            android:launchMode="singleTask"
            android:theme="@style/AppTheme">
            <intent-filter>
                <action android:name="android.intent.action.MAIN"/>
                <category android:name="android.intent.category.LAUNCHER"/>
            </intent-filter>
        </activity>
    </application>
</manifest>
PJE

cat > app/src/main/res/values/strings.xml <<'PJE'
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <string name="app_name">مهندس احمدپور</string>
</resources>
PJE

cat > app/src/main/res/values/styles.xml <<'PJE'
<resources>
    <style name="AppTheme" parent="android:Theme.Material.NoActionBar">
        <item name="android:statusBarColor">#141519</item>
        <item name="android:navigationBarColor">#141519</item>
        <item name="android:windowBackground">#141519</item>
    </style>
</resources>
PJE

cat > app/src/main/res/values/colors.xml <<'PJE'
<resources>
    <color name="iconbg">#FFFFFF</color>
</resources>
PJE

cat > app/src/main/res/mipmap-anydpi-v26/ic_launcher.xml <<'PJE'
<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">
    <background android:drawable="@color/iconbg"/>
    <foreground android:drawable="@mipmap/iconfg"/>
</adaptive-icon>
PJE

cat > app/src/main/java/ir/physicstory/moshaver/MainActivity.java <<'PJE'
package ir.physicstory.moshaver;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.graphics.Color;
import android.os.Bundle;
import android.content.Intent;
import android.net.Uri;
import android.webkit.WebChromeClient;
import android.webkit.WebResourceRequest;
import android.webkit.WebSettings;
import android.webkit.WebView;
import android.webkit.WebViewClient;

public class MainActivity extends Activity {
    private WebView web;
    private static final String URL = "https://physicstory.ir/moshaver/index.php";

    @SuppressLint("SetJavaScriptEnabled")
    @Override
    protected void onCreate(Bundle b) {
        super.onCreate(b);
        web = new WebView(this);
        WebSettings s = web.getSettings();
        s.setJavaScriptEnabled(true);
        s.setDomStorageEnabled(true);
        s.setDatabaseEnabled(true);
        s.setMediaPlaybackRequiresUserGesture(false);
        s.setJavaScriptCanOpenWindowsAutomatically(true);
        s.setSupportZoom(false);
        s.setLoadWithOverviewMode(true);
        s.setUseWideViewPort(true);
        web.setWebChromeClient(new WebChromeClient());
        web.setWebViewClient(new WebViewClient() {
            @Override
            public boolean shouldOverrideUrlLoading(WebView v, WebResourceRequest r) {
                Uri u = r.getUrl();
                String host = u.getHost() == null ? "" : u.getHost();
                if (!host.contains("physicstory.ir")) {
                    try {
                        startActivity(new Intent(Intent.ACTION_VIEW, u));
                    } catch (Exception e) {}
                    return true;
                }
                return false;
            }
        });
        web.setBackgroundColor(Color.parseColor("#141519"));
        setContentView(web);
        web.loadUrl(URL);
    }

    @Override
    public void onBackPressed() {
        if (web != null && web.canGoBack()) web.goBack();
        else super.onBackPressed();
    }
}
PJE

echo "=== 4) Icons ==="
wget -q -O icon.png "https://physicstory.ir/wp-content/uploads/2026/09/1231.png"
[ -s icon.png ] || { echo "ICON DOWNLOAD FAILED"; exit 1; }
for S in 108 162 216 324 432; do
  convert icon.png -resize ${S}x${S} -background white -gravity center -extent ${S}x${S} fg_${S}.png
done
cp fg_108.png app/src/main/res/mipmap-mdpi/iconfg.png
cp fg_162.png app/src/main/res/mipmap-hdpi/iconfg.png
cp fg_216.png app/src/main/res/mipmap-xhdpi/iconfg.png
cp fg_324.png app/src/main/res/mipmap-xxhdpi/iconfg.png
cp fg_432.png app/src/main/res/mipmap-xxxhdpi/iconfg.png
cp fg_108.png app/src/main/res/mipmap-mdpi/ic_launcher.png
cp fg_162.png app/src/main/res/mipmap-hdpi/ic_launcher.png
cp fg_216.png app/src/main/res/mipmap-xhdpi/ic_launcher.png
cp fg_324.png app/src/main/res/mipmap-xxhdpi/ic_launcher.png
cp fg_432.png app/src/main/res/mipmap-xxxhdpi/ic_launcher.png

echo "=== 5) Signing key ==="
keytool -genkeypair -keystore app/keystore.jks -alias moshaver -keyalg RSA -keysize 2048 -validity 10000 -storepass MoshaApp1405 -keypass MoshaApp1405 -dname "CN=Moshaver"

echo "=== 6) Build ==="
cd $GITHUB_WORKSPACE
echo "sdk.dir=$HOME/android-sdk" > local.properties
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
wget -q https://services.gradle.org/distributions/gradle-8.4-bin.zip -O /tmp/gradle.zip
unzip -q /tmp/gradle.zip -d /opt
/opt/gradle-8.4/bin/gradle assembleRelease --no-daemon
cp app/build/outputs/apk/release/app-release.apk app-release.apk
echo "=== DONE ==="
ls -la app-release.apk
