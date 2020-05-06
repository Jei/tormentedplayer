#!/bin/sh

echo "Retrieving credential files..."

gsutil cp gs://tormented-player-app-credentials/google-services.json ./android/app/google-services.json
gsutil cp gs://tormented-player-app-credentials/keystore.jks ./android/app/keystore.jks
gsutil cp gs://tormented-player-app-credentials/keystore.properties ./android/app/keystore.properties
gsutil cp gs://tormented-player-app-credentials/fastlane_service_account.json ./android/fastlane_service_account.json
