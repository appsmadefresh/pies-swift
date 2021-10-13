# pies-swift
Realtime Mobile Analytics

## Build Instructions

We use **xcodebuild** to generate archives and create a framework for release distribution.

Open the **Terminal** and navigate to the project directory:
```
cd "path/to/pies-swift"
```

Create an archive for **iOS**:
```
xcodebuild archive \
-scheme Pies \
-configuration Release \
-archivePath './build/Pies.framework-iphoneos.xcarchive' \
SKIP_INSTALL=NO \
BUILD_LIBRARY_FOR_DISTRIBUTION=YES
```

Create an archive for the **Simulator**:
```
xcodebuild archive \
-scheme Pies \
-configuration Release \
-destination 'generic/platform=iOS Simulator' \
-archivePath './build/Pies.framework-iphonesimulator.xcarchive' \
SKIP_INSTALL=NO \
BUILD_LIBRARY_FOR_DISTRIBUTION=YES
```

Create the **XCFramework**:
```
xcodebuild -create-xcframework \
-framework './build/Pies.framework-iphonesimulator.xcarchive/Products/Library/Frameworks/Pies.framework' \
-framework './build/Pies.framework-iphoneos.xcarchive/Products/Library/Frameworks/Pies.framework' \
-output './build/Pies.xcframework'
```

The output of each command is in the **build** directory. The **Pies.xcframework** folder can be distributed and integrated into other apps. However, before the framework can be distributed, we have one final step.

If you integrate the framework into another app, you will get the following error:
> ... is not a member type of ...

The error occurs because we have a class named "Pies", which is the same name as the module (or framework). There are many .swiftinterface files, so run the following to edit the files quickly:
```
cd build/Pies.xcframework
find . -name "*.swiftinterface" -exec sed -i -e 's/Pies\.//g' {} \;
```

Now **Pies.xcframework** can be distributed and integrated.
