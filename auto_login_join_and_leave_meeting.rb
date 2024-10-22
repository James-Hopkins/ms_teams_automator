# frozen_string_literal: true

require 'selenium-webdriver'
require 'yaml'
require_relative 'meeting_session'

config_data = YAML.load_file('config.yml')

config = {
    users: config_data['users'].map do |user|
        {
            email: user['email'],
            password: user['password'],
            wait_before_joining: user['wait_before_joining'],
            wait_before_leaving: user['wait_before_leaving']
        }
    end,
    meeting_url: config_data['meeting_url']
}

def build_driver
    options = Selenium::WebDriver::Chrome::Options.new
    options.add_argument('--use-fake-device-for-media-stream')
    options.add_argument('--use-fake-ui-for-media-stream')

    Selenium::WebDriver.for :chrome, options: options
end

Celluloid.boot

meeting_sessions = config[:users].map do |user|
    meeting_session = MeetingSession.new(user, config[:meeting_url], build_driver)
    meeting_session.async.login_join_and_leave_meeting
    meeting_session
end

sleep 120

meeting_sessions.each(&:terminate)
