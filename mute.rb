# frozen_string_literal: true

require 'dotenv/load'
require 'octokit'
require 'logger'

client = Octokit::Client.new access_token: ENV['OCTOKIT_ACCESS_TOKEN']
since = Time.now - (60 * 60) * 24 * 4
ignored_authors = %w(dependabot[bot] dependabot)
ignored_body = "/jenkins trigger"
logger = Logger.new(STDOUT)
notifications = client.notifications(since: since.iso8601)

logger.info "Found #{notifications.count} notification(s)"
if notifications.count > 1
  logger.info notifications.map {|notif| "\"#{notif.subject.title}\""}.join(", ")
end

notifications.each do |notification|
  pr_info = notification.subject.rels[:self].get.data
  author = pr_info.user

  next if author.nil?

  if ignored_authors.include?(author.login)
    # If the PR or issue author is a bot, mark as read
    logger.info "Marking \"#{notification.subject.title}\" as read due to ignored author"
    client.mark_thread_as_read(notification.id)
    next
  end

  # Don't silence notifications for PRs authored by the current user
  next if author.login == client.user.login

  # Don't mark non-comment notifications as read
  next unless notification.subject.rels[:latest_comment]

  # If we've _never_ looked at this PR, don't mark as read
  next unless notification.last_read_at

  comments = pr_info.rels[:comments].get.data
  next unless comments

  mark_as_read = true
  comment_count = 0
  comments.each do |comment|
    next if comment.updated_at < since && comment.updated_at < notification.last_read_at
    comment_count += 1

    is_bot = ignored_authors.include?(comment.user.login)
    is_current_user = comment.user.login == client.user.login
    is_bot_command = ignored_body.include?(comment.body)

    next if is_bot || is_current_user || is_bot_command

    logger.info "PR ##{pr_info.number} comment by #{comment.user.login} at #{comment.updated_at}, not marking as read"
    mark_as_read = false
    break
  end

  next unless comment_count > 0

  if mark_as_read
    logger.info "No non-bot comments found, marking \"#{notification.subject.title}\" as read"
    client.mark_thread_as_read(notification.id)
  end
end
