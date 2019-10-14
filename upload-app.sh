#!/bin/bash
CORDOVA_IOS_FILE=$1
MOBILE_PROVISION_FILE=$2
EXPORT_OPTIONS_FILE="export-options-tmp.plist"
DISTRIBUTION_CONFIG_FILE=$3
BUNDLE_IDENTIFIER=$(cat $DISTRIBUTION_CONFIG_FILE | jq -r '.bundleDisplayName')
UUID=`./install-provisioning.sh $MOBILE_PROVISION_FILE | tail -n 1`
PROVISIONING_PROFILE_JSON=$(plutil -extract provisioningProfileDist json -o - $DISTRIBUTION_CONFIG_FILE 2>&1)
CODE_SIGN_IDENTITY=$(cat $DISTRIBUTION_CONFIG_FILE | jq -r '.codeSignIdentity')
CORDOVA_IOS_RELEASES_PATH=releases/ios
mkdir -p $CORDOVA_IOS_RELEASES_PATH
echo "** Settings OK! IOS Distribution starting... **"
if [ -z "${CORDOVA_IOS_FILE}" ]
then
        echo "ERROR => Cordova IOS ZIP Binaries ${CORDOVA_IOS_FILE} do not exist."
        exit 1
fi
if [[ $PROVISIONING_PROFILE_JSON =~ $UUID ]]
then
    echo "=> Distributing APP with UUID $UUID and bundleIdentifier $BUNDLE_IDENTIFIER"
    mkdir -p config/export-options
    # Change with location of desired plist file
    cp config/export-options.plist $EXPORT_OPTIONS_FILE
    plutil -replace provisioningProfiles -json $PROVISIONING_PROFILE_JSON $EXPORT_OPTIONS_FILE
    plutil -replace signingCertificate -string "$CODE_SIGN_IDENTITY" $EXPORT_OPTIONS_FILE

    echo "=> Unziping ${CORDOVA_IOS_FILE} IOS Binaries..."
    unzip -q $CORDOVA_IOS_FILE -d $CORDOVA_IOS_RELEASES_PATH
    CORDOVA_IOS_PATH=$CORDOVA_IOS_RELEASES_PATH/`basename $CORDOVA_IOS_FILE .zip`

    echo "=> Starting archive & signing in $CORDOVA_IOS_PATH"
    xcodebuild archive \
    -workspace $CORDOVA_IOS_PATH"/"$BUNDLE_IDENTIFIER".xcworkspace" \
    -scheme $BUNDLE_IDENTIFIER \
    -archivePath $CORDOVA_IOS_PATH"/"$BUNDLE_IDENTIFIER \
    -configuration release \
    CODE_SIGN_STYLE="Manual" PROVISIONING_PROFILE_SPECIFIER="$UUID" CODE_SIGN_IDENTITY="$CODE_SIGN_IDENTITY" ENABLE_BITCODE=NO

    echo "=> Starting export..."
    xcodebuild -exportArchive \
    -archivePath $CORDOVA_IOS_PATH"/"$BUNDLE_IDENTIFIER".xcarchive" \
    -exportOptionsPlist $EXPORT_OPTIONS_FILE \
    -allowProvisioningUpdates -exportPath $CORDOVA_IOS_PATH/
    exit 0
else
    echo "** Error: Not matching provisioning profile :( **"
    exit 1
fi
