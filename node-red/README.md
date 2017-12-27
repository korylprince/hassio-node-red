# About

This unofficial add-on gives an easy way to add [Node-RED](https://nodered.org/) to your [Hass.io](https://home-assistant.io/hassio/) device. It comes pre-installed with [Home Assistant nodes](https://github.com/AYapejian/node-red-contrib-home-assistant) so you can get started easily.

# Why?

There's already a [Hass.io Node-RED add-on](https://github.com/notoriousbdg/hassio-addons/tree/master/node-red), so why make another one? I took a lot of inspiration from the existing add-on, but I decided to make my own for the following reasons:

* Image size: 94MB vs 590MB
* This add-on is based directly on the `homeassistant/{arch}-base:latest` image instead of ubuntu
* This add-on has pre-built images on Docker Hub so a local build won't be necessary
* This add-on comes with the Home Assistant nodes installed by default

Note: See the **Migration** section below for help migrating from the original add-on.

# Installation

See the actual [repository](https://github.com/korylprince/hassio-node-red/) for installation instructions.

# Configuration

It's suggested that you change the default username and password. The following table shows the default options:

Configuration Option | Default Value | Description
---------------------|---------------|--------------
ssl | false | If `ssl` is true, `certkey` and `privkey` will be used to enable HTTPS. These files will be in `/ssl`
certfile | fullchain.pem | see above
privkey | keyfile.pem | see above
admin_users | `[{"username": "admin", "password": "password", "permissions": "*"}]` | [adminAuth users](https://nodered.org/docs/security#usernamepassword-based-authentication) settings. This is the login(s) to the admin dashboard. You'll probably want to change the default. If you set this to `"admin_users": []`, authentication won't be required.
http_user | `{"username": "", "password": ""}` | [HTTP Node user](https://nodered.org/docs/security#http-node-security) settings. This is the login for HTTP nodes and static content. If either `username` or `password` is empty, authentication won't be required.


# Node-RED Configuration

To use Home Assistant Nodes, you'll need to add the Home Assistant server when editing a Home Assistant node. You'll want to use the following configuration:

Name | Value
-----|-------
Base URL | `http://homeassistant:8123` (you might need `https` or a different port if you've changed that)
API Pass | [Home Assistant API password](https://home-assistant.io/components/http/)

# Migration from notoriousbdg's add-on

This add-on uses the same `/share/node-red` folder as the original add-on so only one of the add-ons should be run at once. This add-on should be able to to seamlessly migrate; Just stop the old add-on and start this one. If you do have issues, feel free to [file an issue](https://github.com/korylprince/hassio-node-red/issues). You will need to copy the Hass.io configuration, and it's syntax is a bit different.

Since this add-on includes the Home Assistant modules, you might want to remove the `node_modules` folder and `package.json` file and reinstall any other nodes you use to clear up some space. This isn't necessary, though.

# Advanced Configuration

You can access all of the Node-RED files (`settings.js`, `flows.json`, etc) in `/share/node-red` using the [SSH](https://home-assistant.io/addons/ssh/) or [Samba](https://home-assistant.io/addons/samba/) add-ons. Special care should be taken if you decide to edit `settings.js`. This add-on rewrites certain parts of that file when started, but these changes are somewhat brittle because `sed` and  `awk` are used. If you do have issues, feel free to [file an issue](https://github.com/korylprince/hassio-node-red/issues).
