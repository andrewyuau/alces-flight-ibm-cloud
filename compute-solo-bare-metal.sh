#!/bin/bash
cat <<EOF > /root/userData.sh
#!/bin/bash
EOF
chmod 755 /root/userData.sh
echo "$(curl -w "\n" https://api.service.softlayer.com/rest/v3.1/SoftLayer_Resource_Metadata/getUserMetadata | sed -e "s/\"#/#/g"  | sed -e "s/n\"/n/g" | sed -e "s/\\\n//g" | sed -e "s/\\\//g")" >> /root/userData.sh
/bin/bash /root/userData.sh
