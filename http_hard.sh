#!/bin/bash
#
# ============================================
#  Basic Hardening Of Apache Server
# ============================================
# 


echo '============================================'
echo '  Basic Hardening Of Apache Server'
echo '============================================'
echo ''

CONFIG='/etc/httpd/conf/httpd.conf'


# Updating Apache to latest version

echo -n '> Updating Apache to latest version... '

yum -y update httpd >/dev/null 2>&1 &

SUCCESS=$?

if [ $SUCCESS -eq 0 ]; then
    echo "[OK]"
else
    echo "[ERROR]"
fi


# Backing Up Original Configuration

echo -n '> Backing Up Original Configuration... '
cp $CONFIG "$CONFIG.bk" &

SUCCESS=$?

if [ $SUCCESS -eq 0 ]; then
    echo "[OK]"
else
    echo "[ERROR]"
fi


# Protection Against Fingerprinting

echo -n '> Enabling Protection Against Fingerprinting... '

sed -i -e 's/ServerSignature On/ServerSignature Off/' $CONFIG
sed -i -e 's/ServerTokens OS/ServerTokens Prod/' $CONFIG

SUCCESS=$?

if [ $SUCCESS -eq 0 ]; then
    echo "[OK]"
else
    echo "[ERROR]"
fi


# Disabling Directory Listing 

echo -n '> Disabling Directory Listing... '

sed -r -i -e 's|^([[:space:]]*)</Directory>|\n\n\1\t# Hardening Related Configurations ===============\n\1</Directory>|g' $CONFIG
sed -r -i -e 's|^([[:space:]]*)</Directory>|\1\tOptions -Indexes\n\1</Directory>|g' $CONFIG

SUCCESS=$?

if [ $SUCCESS -eq 0 ]; then
    echo "[OK]"
else
    echo "[ERROR]"
fi


# Disable Server Side Includes and Symbolic Links

echo -n '> Disable SSI and SymLinks... '

sed -r -i -e 's|^([[:space:]]*)</Directory>|\1\tOptions -Includes\n\1\tOptions -FollowSymLinks\n\1</Directory>|g' $CONFIG

SUCCESS=$?

if [ $SUCCESS -eq 0 ]; then
    echo "[OK]"
else
    echo "[ERROR]"
fi


# Install mod_security and mod_evasive 

echo -n '> Install mod_security and mod_evasive... '

yum -y install mod_security mod_evasive >/dev/null 2>&1 &

SUCCESS=$?

if [ $SUCCESS -eq 0 ]; then
    echo "[OK]"
else
    echo "[ERROR]"
fi


# Limit Request Size To Prevent DOS

echo -n '> imit Request Size... '

sed -r -i -e 's|^([[:space:]]*)</Directory>|\1\tLimitRequestBody 512000\n\1\tOptions -FollowSymLinks\n\1</Directory>|g' $CONFIG 

SUCCESS=$?

if [ $SUCCESS -eq 0 ]; then
    echo "[OK]"
else
    echo "[ERROR]"
fi


# Disable Risky HTTP Methods

echo -n '> Disable Risky HTTP Methods... '

sed -r -i -e 's|^([[:space:]]*)</Directory>|\n\1\t<LimitExcept GET POST HEAD>\n\1\t\tdeny from all\n\1\t</LimitExcept>\n\n</Directory>|g' $CONFIG

SUCCESS=$?

if [ $SUCCESS -eq 0 ]; then
    echo "[OK]"
else
    echo "[ERROR]"
fi


# Enable XSS Protection For Modern Browsers

echo -n '> Enable XSS Protection For Modern Browsers... '

echo '' >> $CONFIG 
echo '<IfModule mod_headers.c>' >> $CONFIG 
echo 'Header set X-XSS-Protection 0' >> $CONFIG 
echo '</IfModule>' >> $CONFIG 

SUCCESS=$?

if [ $SUCCESS -eq 0 ]; then
    echo "[OK]"
else
    echo "[ERROR]"
fi


# Protect Apache Binary Files

echo -n '> Protect Apache Binary Files... '

chown -R root:root /etc/httpd/conf /etc/httpd/bin >/dev/null 2>&1 &
chmod -R 750 /etc/httpd/conf /etc/httpd/bin >/dev/null 2>&1 &

SUCCESS=$?

if [ $SUCCESS -eq 0 ]; then
    echo "[OK]"
else
    echo "[ERROR]"
fi


# Restart Apache Server

echo '> Restart Apache Server:'

service httpd restart &
