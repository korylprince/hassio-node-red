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

PALETTE_VERSION=$(jq --raw-output ".palette_version" $CONFIG_PATH)
palette_versions=( $PALETTE_VERSIONS )

mkdir -p /share/node-red/

# copy default settings.js if it doesn't exist
if [ ! -f $SETTINGS_PATH ]; then
  echo "created default settings"
  cp /node-red/node_modules/node-red/settings.js $SETTINGS_PATH
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
    sed -i '/    adminAuth: {/,/^    \(\/\/\)\?},/ s/^    /    \/\//g' $SETTINGS_PATH
fi

# set HTTP credentials
if [[ ! -z "$HTTP_USER" ]] && [[ ! -z "$HTTP_PASSWORD" ]]; then
    echo "HTTP Authentication Enabled"
    # use | instead of / because $HASH might have /
    sed -i "s|\(//\)\?httpNodeAuth: {.*}|httpNodeAuth: {user: '$HTTP_USER', pass: require('bcryptjs').hashSync('$HTTP_PASSWORD', 8)}|g" $SETTINGS_PATH
    sed -i "s|\(//\)\?httpStaticAuth: {.*}|httpStaticAuth: {user: '$HTTP_USER', pass: require('bcryptjs').hashSync('$HTTP_PASSWORD', 8)}|g" $SETTINGS_PATH
else
    echo "HTTP Authentication Disabled"
    sed -i 's/    httpNodeAuth:/    \/\/httpNodeAuth:/g' $SETTINGS_PATH
    sed -i 's/    httpStaticAuth:/    \/\/httpStaticAuth:/g' $SETTINGS_PATH
fi

# if palette version is empty, set to latest version
if [ -z "$PALETTE_VERSION" ]; then
    PALETTE_VERSION=${palette_versions[${#palette_versions[@]}-1]}
fi

# enter node-red directory
pushd /share/node-red > /dev/null

# get current version of palette
current_version=$(npm --json list node-red-contrib-home-assistant | jq --raw-output '.dependencies["node-red-contrib-home-assistant"].version')

# if version doesn't match currently installed version, install it
if [ "$current_version" != "$PALETTE_VERSION" ]; then

    echo "Current palette version: $current_version want: $PALETTE_VERSION"

    # create an array to check for cached versions
    declare -A version_map
    for version in ${palette_versions[@]}; do
        version_map["$version"]=1
    done

    # install version from cache or Internet
    if [ ${version_map["$PALETTE_VERSION"]} ]; then
        echo "Installing $PALETTE_VERSION from cache"
        npm install --no-optional --only=production --save --offline "node-red-contrib-home-assistant@$PALETTE_VERSION"
    else
        echo "Palette Version \"$PALETTE_VERSION\" not in valid list of versions: \""${palette_versions[@]}"\""
        echo "Installing $PALETTE_VERSION from Internet"
        npm install --no-optional --only=production --save "node-red-contrib-home-assistant@$PALETTE_VERSION"
    fi
else
    echo "Current palette version $current_version matches requested version"
fi

# exit node-red directory
popd > /dev/null

# wait for Hassio API to be available
/waiting -s -t 0 hassio:80

# get Home Assistant port
info=$(curl -s -H "X-HASSIO-KEY: $HASSIO_TOKEN" -H "Content-Type: application/json" http://hassio/homeassistant/info)
port=$(echo $info | jq --raw-output ".data.port")

# wait for Home Assistant to be available
/waiting -s -t 0 homeassistant:$port

NODE_PATH=/node-red/node_modules exec /node-red/node_modules/.bin/node-red --userDir /share/node-red/ /share/node-red/flows.json
