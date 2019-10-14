# ios-builder
Project to archive and export IOS projects to itunes connect and generate local IPAs
​
## Prerequisites
​
* macOS X
* Xcode 9 or newer
* jq
* plistbuddy
* plutil
* zip
​
​
## Set-up
​
In order to distribute an app automatically we need to generate a json file similar to the one in ```config/app-config/config.json``` in order to feed the script the app data.
​
## Execution
​
upload-app.sh _cordova_folder_ _mobile_provision_ _config_ where the params are:
* cordova_folder is a zipped version of the cordova project
* mobile_provision is the mobile provision one would feed xcode while building manually
* config is a configuration json with the same structure as the one in the example.

Example:

 ./upload-app.sh /YOUR_IOS_PROJECT.zip config/provisioning-profiles/YOUR_FILE.mobileprovision config/app-config/config.json