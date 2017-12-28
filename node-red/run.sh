#!/bin/bash
set -e

CONFIG_PATH=/data/options.json
SETTINGS_PATH=/share/node-red/settings.js

SSL=$(jq --raw-output ".ssl" $CONFIG_PATH)
KEYFILE=$(jq --raw-output ".keyfile" $CONFIG_PATH)
CERTFILE=$(jq --raw-output ".certfile" $CONFIG_PATH)

ADMIN_USER_COUNT=$(jq --raw-output ".admin_users | length" $CONFIG_PATH)

HTTP_USER=$(jq --raw-output ".http_user.username" $CONFIG_PATH)
HTTP_PASSWORD=$(jq --raw-output ".http_user.password" $CONFIG_PATH)

mkdir -p /share/node-red/

# copy default settings.js if it doesn't exist
if [ ! -f $SETTINGS_PATH ]; then
  echo "created default settings"
  cp /usr/lib/node_modules/node-red/settings.js $SETTINGS_PATH
fi

# set SSL settings
if [[ "$SSL" == "true" ]]; then
    echo "SSL Enabled"
    sed -i 's/.*var fs = require("fs")/var fs = require("fs")/g' $SETTINGS_PATH
    # uncomment https section
    sed -i '/https: {/,/}/ s/\/\///g' $SETTINGS_PATH
    sed -i "/key: fs.readFileSync/ s/(.*)/('\/ssl\/$KEYFILE')/g" $SETTINGS_PATH
    sed -i "/cert: fs.readFileSync/ s/(.*)/('\/ssl\/$CERTFILE')/g" $SETTINGS_PATH
else
    echo "SSL Disabled"
    sed -i 's/.*var fs = require("fs")/\/\/var fs = require("fs")/g' $SETTINGS_PATH
    # comment https section
    sed -i '/    https: {/,/}/ s/^    /    \/\//g' $SETTINGS_PATH
fi

# set admin credentials
if [ ! "$ADMIN_USER_COUNT" == "0" ]; then
    echo "Admin Authentication Enabled"
    # uncomment adminAuth section
    sed -i '/adminAuth: {/,/^    \(\/\/\)\?},/ s/\/\///g' $SETTINGS_PATH
    # clear users section
    sed -i '/users: \[/,/\]/ c\        users: [\n<users>\n        ]' $SETTINGS_PATH

    # generate users section
    users_config=""

    users=`jq --raw-output ".admin_users[].username" $CONFIG_PATH`
    IFS=$'\n'
    users=($users)

    i=1

    for user in "${users[@]}"; do
        pass=`jq --raw-output ".admin_users[] | select(.username == \"$user\").password" $CONFIG_PATH`
        perm=`jq --raw-output ".admin_users[] | select(.username == \"$user\").permissions" $CONFIG_PATH`


        read -r -d '' user_config << EOF || true
            {
                username: "$user",
                password: require("bcryptjs").hashSync("$pass", 8),
                permissions: "$perm"
            }
EOF

        users_config="$users_config$user_config"
        if [[ ! "$i" == "$ADMIN_USER_COUNT" ]]; then
            users_config=$users_config$',\n'
        fi

        ((i++))
    done

    # write users section
    contents=`cat $SETTINGS_PATH`
    echo "$contents" | awk -v users_config="$users_config" '{sub(/<users>/, users_config);print;}' > $SETTINGS_PATH
else
    echo "Admin Authentication Disabled"
    # comment adminAuth section
    sed -i '/adminAuth: {/,/^    \(\/\/\)\?},/ s/^    /    \/\//g' $SETTINGS_PATH
fi

# set HTTP credentials
if [[ ! -z "$HTTP_USER" ]] && [[ ! -z "$HTTP_PASSWORD" ]]; then
    echo "HTTP Authentication Enabled"
    # use | instead of / because $HASH might have /
    sed -i "s|\(//\)\?httpNodeAuth: {.*}|httpNodeAuth: {user: '$HTTP_USER', pass: require('bcryptjs').hashSync('$pass', 8)}|g" $SETTINGS_PATH
    sed -i "s|\(//\)\?httpStaticAuth: {.*}|httpStaticAuth: {user: '$HTTP_USER', pass: require('bcryptjs').hashSync('$pass', 8)}|g" $SETTINGS_PATH
else
    echo "HTTP Authentication Disabled"
    sed -i 's/    httpNodeAuth:/    \/\/httpNodeAuth:/g' $SETTINGS_PATH
    sed -i 's/    httpStaticAuth:/    \/\/httpStaticAuth:/g' $SETTINGS_PATH
fi

NODE_PATH=/node-red/node_modules exec /node-red/node_modules/.bin/node-red --userDir /share/node-red/ /share/node-red/flows.json
