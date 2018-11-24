See the fully formatted README on [GitHub](https://github.com/korylprince/hassio-node-red/tree/master/node-red).

# Deprecation Notice
Due to my inability to keep up with Home Assistant and Node-RED changes, I'm offically deprecating this add-on. The good news is there's a [much better add-on](https://github.com/hassio-addons/addon-node-red) in the Community Hass.io Add-on repository.

This repository will remain on GitHub for the foreseeable future.

#### Migration

Export your flows from the Web GUI or copy your `flows.json` with the SSH or SAMBA add-ons. Stop the old add-on, install, configure, and start the new one, and import your flows using copy and paste in the web GUI.

You'll need to edit your Home Assistant server nodes and check the "I use Hass.io" checkbox.

The new add-on stores its configuration in the Home Assistant config directory, so once you've got everything migrated, you can remove the `/share/node-red` directory.

# About

This unofficial add-on gives an easy way to add [Node-RED](https://nodered.org/) to your [Hass.io](https://home-assistant.io/hassio/) device. It comes pre-installed with [Home Assistant nodes](https://github.com/AYapejian/node-red-contrib-home-assistant) so you can get started easily.

# Why?

There's already a [Hass.io Node-RED add-on](https://github.com/notoriousbdg/hassio-addons/tree/master/node-red), so why make another one? I took a lot of inspiration from the existing add-on, but I decided to make my own for the following reasons:

* Image size: 125MB vs 590MB
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
palette_version | `""` | Set the [node-red-contrib-home-assistant](https://github.com/AYapejian/node-red-contrib-home-assistant) version. If empty, the latest version will be installed. This add-on caches `0.2.1` and `0.3.0` for offline installation.


# Node-RED Configuration

To use Home Assistant Nodes, you'll need to add the Home Assistant server when editing a Home Assistant node. You'll want to use the following configuration:

Name | Value
-----|-------
Base URL | `http://homeassistant:8123` (See Hostname section below)
API Pass | [Home Assistant API password](https://home-assistant.io/components/http/)

## Hostname

If you are running Home Assistant without HTTPS, you need to literally use "homeassistant" as the hostname as [that's how add-ons can reach the Home Assistant instance](https://home-assistant.io/developers/hassio/addon_communication/#home-assistant).

If you want to use HTTPS, the configuration gets a bit harder because you have to use the hostname in your certificate. This is usually the certificate Subject Common Name (CN) but can also be in [Subject Alternative Name](https://www.digicert.com/subject-alternative-name.htm) if you have multiple domains in one certificate. You'll need to use `https://<your full certificate hostname>:<your ssl port>` as the Base URL, and you'll need to modify your local DNS to resolve your certificate hostname to your local Hass.io IP Address. For an example of this, see this [DIY Futurism](http://diyfuturism.com/index.php/2018/01/31/setting-up-lets-encrypt-with-node-red-home-assistant/) post.

# Migration from notoriousbdg's add-on

This add-on uses the same `/share/node-red` folder as the original add-on so only one of the add-ons should be run at once. This add-on should be able to to seamlessly migrate; Just stop the old add-on and start this one. If you do have issues, feel free to [file an issue](https://github.com/korylprince/hassio-node-red/issues). You will need to copy the Hass.io configuration, and it's syntax is a bit different.

Since this add-on includes the Home Assistant modules, you might want to remove the `node_modules` folder and `package.json` file and reinstall any other nodes you use to clear up some space. This isn't necessary, though.

# Advanced Configuration

You can access all of the Node-RED files (`settings.js`, `flows.json`, etc) in `/share/node-red` using the [SSH](https://home-assistant.io/addons/ssh/) or [Samba](https://home-assistant.io/addons/samba/) add-ons. Special care should be taken if you decide to edit `settings.js`. This add-on rewrites certain parts of that file when started, but these changes are somewhat brittle because `sed` and  `awk` are used. If you do have issues, feel free to [file an issue](https://github.com/korylprince/hassio-node-red/issues).
