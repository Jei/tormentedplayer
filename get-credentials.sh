#!/bin/sh

echo "Retrieving credential files..."

gsutil cp gs://adventures-in-credentials/google-services.json ./android/app/google-services.json
gsutil cp gs://adventures-in-credentials/keystore.jks ./android/app/keystore.jks
gsutil cp gs://adventures-in-credentials/keystore.properties ./android/app/keystore.properties
