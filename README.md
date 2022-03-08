# `bot-notification-silencer`

Marks notifications from bots as read. (Fork of <https://github.com/benbalter/bot-notification-silencer>)

Originally intended to be run via a scheduled Heroku job, but could probably be run via GitHub Actions or elsewhere.

In order to run this, the `OCTOKIT_ACCESS_TOKEN` needs access to:

* `notifications` to read notifications
* `repo` to access pull request data linked to notifications
