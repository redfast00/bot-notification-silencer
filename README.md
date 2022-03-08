# `bot-notification-silencer`

Marks notifications from bots as read. (Fork of <https://github.com/benbalter/bot-notification-silencer>)

Originally intended to be run via a scheduled Heroku job, but could probably be run via GitHub Actions or elsewhere.

In order to run this, the `OCTOKIT_ACCESS_TOKEN` needs access to:

* `notifications` to read notifications
* `repo` to access pull request data linked to notifications

> NOTE: if your organization uses a VPN / IP address allowlisting, this script
> will not work from Github Actions since the runner's IP is not allowed.
> In this case you would need to run this script as a local cron job or
> equivalent.
