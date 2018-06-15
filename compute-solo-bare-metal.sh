#!/bin/bash
curl https://api.service.softlayer.com/rest/v3.1/SoftLayer_Resource_Metadata/getUserMetadata | sed -e "s/\\\//g" | sed -e "s/\"#/#/g" | sed -e "s/rn\"/\n/g" | sed -e "s/rn/\n/g" > userData.sh
chmod 755 userData.sh
./userData.sh
