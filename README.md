<h1 align="center">Pies</h1>
<p align="center">
    <img src="https://img.shields.io/badge/license-MIT-lightgrey" alt="License - MIT"/> 
    <img src="https://img.shields.io/badge/Swift%20Package%20Manager-compatible-green" alt="Swift Package Manager - Compatible"/>
</p>

# Table of Contents
- [Overview](#overview)
- [Quick Start](#quick-start)
- [Manual Install](#manual-install)
- [FAQ](#faq)
- [Support](#support)

# Overview
Welcome to the Pies Swift Framework!

Pies Swift is a realtime mobile analytics framework for iOS. With only two lines of code, automatically track the number of devices, installs, app opens and revenue for your app. View a dashboard of your app's metrics in the [Pies](https://apps.apple.com/us/app/pies-mobile-analytics/id1592726335) app for iOS. Receive push notifications for installs and purchases.

**Requirements**
* iOS 12.2
* Swift 5

# Quick Start

1. Download [Pies](https://apps.apple.com/us/app/pies-mobile-analytics/id1592726335) from the App Store and sign up. You can get started with a free account.
2. In the Pies app, add your app and receive your **appId** and **apiKey** in an email.
3. Add **pies-swift** to your project. Swift Package Manager (SPM) is the preferred dependency manager for Pies.
4. Configure your app to use Pies. Please follow the appropriate instructions below for UIKit or SwiftUI.

### UIKit

Open your **AppDelegate** and import the Pies framework:
```
import Pies
```

Configure Pies by adding the following line to your **application:didFinishLaunchingWithOptions:** method:
```
Pies.configure(appId: "<YOUR APP ID>", apiKey: "<YOUR API KEY>")
```

### SwiftUI
Open the file containing your project's **App**, and add import the Pies framework:
```
import Pies
```

Configure Pies by adding the following line to your **App.init()** method:
```
Pies.configure(appId: "<YOUR APP ID>", apiKey: "<YOUR API KEY>")
```

For a complete example, please checkout the UIKit and SwiftUI demo apps in this repository.

5. Run your app and view the metrics in the Pies app.

# Manual Install

1. Download the Pies Framework from [here](https://firebasestorage.googleapis.com/v0/b/pies-d01b8.appspot.com/o/Pies.xcframework.zip?alt=media&token=5a19ca9f-c27a-4304-8306-937805f588b0).
2. Un-zip the Pies.xcframework.zip file and add the Pies.xcframework to your Xcode project.
3. In Xcode, open the **General** tab for your target. Then check the settings under **Frameworks, Libraries, and Embedded Content**. Pies.xcframework should be set to "Embed & Sign".
4. Follow the Quick Start instructions in Step 4.

# FAQ
**Do I need to request the user's permission through the [App Tracking Transparency](https://developer.apple.com/documentation/apptrackingtransparency) framework to use Pies?**

No. Pies does not use IDFA. Therefore, user permission through the App Tracking Transparency framework is not required.

# Support
If you have any questions or issues, please open an [Issue](https://github.com/appsmadefresh/pies-swift/issues) or send us an [email](support@appsmadefresh.com).