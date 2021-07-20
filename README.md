# 🤔 Deep Thought – DeepL translation bot for Slack

_Deep Thought_ is a Slack bot that provides a simple way to get translations for messages sent in your workspace. Simply invite _Deep Thought_ into channels (or group conversations!) that you wish to receive translations in, react to a message you wish to see translated with a flag emoji that indicates the desired language (for example, use Japanese flag 🇯🇵 to get translation in Japanese), and let the magic happen! ✨

## Usage

There are two main ways of interacting with the bot and receiving translations:

1. Most users choose to request and receive translations by reacting to a message they wish to see translated with an flag emoji, as described above;
2. For sending a quick translation into public channel or private channel the bot was previously invited to, you can also utilize the recently added `/translate [language shorthand/flag emoji] [text]` Slack command.

## Prerequisites

To run the bot, you must fullfil the following requirements:

- Have a DeepL API key (provided with a [DeepL API Free](https://www.deepl.com/pro#developer) or [DeepL API Pro plans](https://www.deepl.com/pro#developer));
- Have a Slack workspace to which you are permitted to install apps;
- Have a Heroku-compatible application hosting with a PostgreSQL database;
  - While [Heroku](https://www.heroku.com) is technically supported, the bot has only been tested in a [Dokku](https://dokku.com/) environment with the official [Dokku Postgres Plugin](https://github.com/dokku/dokku-postgres).

## Deployment

To deploy _Deep Thought_, you first need to create a Slack application, then configure your server to receive callback anytime the bot should perform any action.

### Slack configuration

1. Navigate to the [Your Apps](https://api.slack.com/apps) page and press the **Create New App** button
2. Choose _From an app manifest_, select your workspace and paste the following manifest, adjusting the `YOUR.DOMAIN.HERE` strings in three different places:

   ```yaml
   _metadata:
     major_version: 1
     minor_version: 1
   display_information:
     name: Deep Thought
     description: For the deepest of translations
     background_color: "#2c2d30"
   features:
     app_home:
       home_tab_enabled: false
       messages_tab_enabled: true
       messages_tab_read_only_enabled: true
     bot_user:
       display_name: Deep Thought
       always_online: true
     slash_commands:
       - command: /translate
         url: https://YOUR.DOMAIN.HERE/slack/commands
         description:
           Translate your message, sending both the translation and original
           text to the channel
         usage_hint: "[language shorthand/flag emoji] [text]"
         should_escape: false
   oauth_config:
     scopes:
       bot:
         - channels:history
         - chat:write
         - commands
         - groups:history
         - mpim:history
         - mpim:write
         - reactions:read
         - users.profile:read
         - chat:write.public
   settings:
     event_subscriptions:
       request_url: https://YOUR.DOMAIN.HERE/slack/events
       bot_events:
         - reaction_added
     interactivity:
       is_enabled: true
       request_url: https://YOUR.DOMAIN.HERE/slack/actions
     org_deploy_enabled: false
     socket_mode_enabled: false
     is_hosted: false
   ```

3. Confirm by pressing the **Create** button
4. Install the application to your workspace by pressing the **Install to Workspace** button and confirming the permission scope
5. Reveal your _Signing Secret_ by pressing the **Show** button – this will be the value of your `SLACK_SIGNING_SECRET` environmental variable
6. Navigate to the _OAuth & Permissions_ section and note your _Bot User OAuth Token_ – this will be the value of your `SLACK_BOT_TOKEN` environmental variable

### Dokku configuration (server side)

1. Install the official Dokku Postgres Plugin if you haven’t done so before

   ```shell
   sudo dokku plugin:install https://github.com/dokku/dokku-postgres.git postgres
   ```

2. Create a new Dokku app to host the bot:

   ```shell
   dokku apps:create bot
   ```

3. Create and link a database:

   ```shell
   dokku postgres:create bot-db
   dokku postgres:link bot-db bot
   ```

4. Configure the required environmental variables:

   ```shell
   dokku config:set bot DEEPL_AUTH_KEY=DEEPL_AUTH_KEY_HERE
   dokku config:set bot HOSTNAME=HOSTNAME_HERE
   dokku config:set bot SECRET_KEY_BASE=SECRET_KEY_BASE
   dokku config:set bot SLACK_BOT_TOKEN=SLACK_BOT_TOKEN_HERE
   dokku config:set bot SLACK_SIGNING_SECRET=SLACK_SIGNING_SECRET_HERE
   ```

   Most of these are self-describing, but two variables are of note:

   - `HOSTNAME` should correspond to the hostname your bot will be accessible on, without the protocol prefix
   - `SECRET_KEY_BASE` can be any sufficiently random string, but preferably use a key generated with the `mix phx.gen.secret` command

5. Configure the domain mapping for the app:

   ```shell
   dokku domains:set bot YOUR.DOMAIN.HERE
   ```

6. Configure TLS so that the bot is accessible via HTTPS in a way that is acceptable to you, perhaps with Dokku’s [Let’s Encrypt plugin](https://github.com/dokku/dokku-letsencrypt)

### Dokku configuration (local side)

1. From the directory into which you have checked this repository out, configure the remote repository pointing at your Dokku instance:

   ```shell
   git remote add dokku dokku@YOUR.SERVER.HERE:bot
   ```

2. Finally, deploy the bot:

   ```shell
   git push dokku master
   ```

## Local development

To start your bot:

- Install dependencies with `mix deps.get`
- Create and migrate your database with `mix ecto.setup`
- Install Node.js dependencies with `npm install` inside the `assets` directory
- Start Phoenix endpoint with `mix phx.server`

## Privacy

While the bot has to store some information in its database in order to function properly, it does not store either the original nor the translated message. Currently, these are the only pieces of information that _Deep Thought_ stores:

- For each translated message:
  - `channel_id`, an unique identifier of the channel in which the message was posted
  - `message_ts`, an unique timestamp of the message that was translated
  - `target_language`, indicating the language into which the message was translated
- For each user mentioned in any translated message:
  - `user_id`, an unique identifier of the user
  - `real_name`, the value of the _Full Name_ field in user’s Slack profile

In order for _Deep Thought_ to operate correctly, the following Slack OAuth permission scopes are required:

- `commands`
  - Required in order to provide the `/translate` slash command
- `groups:history`
  - Required in order to read the content of a single message in private channels that _Deep Thought_ was manually invited to, once a flag emoji has been added to that message
- `channels:history`
  - Required in order to read the content of a single message in public channels that _Deep Thought_ was manually invited to, once a flag emoji has been added to that message
- `chat:write`
  - Required in order to send message to private channels _Deep Thought_ was manually invited to
- `chat:write.public`
  - Required in order to send messages to any public channel
- `mpim:history`
  - Required in order to read the content of a single message in group direct messages that _Deep Thought_ was manually invited to, once a flag emoji has been added to that message
- `mpim:write`
  - Required in order to send messages to group direct messages
- `reactions:read`
  - Required in order to be notified when emoji reaction has been added to a message
- `users.profile:read`
  - Required in order to translate machine-readable user ID’s into user’s real name
