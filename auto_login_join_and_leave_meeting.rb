# frozen_string_literal: true

require 'selenium-webdriver'
require 'yaml'

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

def login_join_and_leave_meeting(user, meeting_url, driver)
    driver.navigate.to 'https://account.microsoft.com/account/manage-my-account'

    driver.find_element(:id, 'id__5').click
    wait = Selenium::WebDriver::Wait.new(timeout: 10) # seconds
    wait.until { driver.find_element(name: 'loginfmt') }
    driver.find_element(:name, 'loginfmt').send_keys(user[:email])
    driver.find_element(:id, 'idSIButton9').click

    sleep 1 # these are added because the elements are not yet enteraable so the built in wait fails

    wait.until { driver.find_element(id: 'i0118', name: 'passwd') }
    driver.find_element(id: 'i0118', name: 'passwd').send_keys(user[:password])

    sleep 1

    driver.find_element(:id, 'idSIButton9').click
    wait.until { driver.find_element(id: 'declineButton') }
    driver.find_element(id: 'declineButton').click

    sleep 1

    driver.navigate.to meeting_url
    wait.until { driver.find_element(xpath: '//*[@id="container"]/div/div/div[1]/div[4]/div/button[1]/div/h3') }
    driver.find_element(xpath: '//*[@id="container"]/div/div/div[1]/div[4]/div/button[1]/div/h3').click

    sleep user[:wait_before_joining]

    wait.until { driver.find_element(xpath: '//*[@id="prejoin-join-button"]') }
    driver.find_element(xpath: '//*[@id="prejoin-join-button"]').click

    sleep user[:wait_before_leaving]

    wait.until { driver.find_element(xpath: '//*[@id="app"]/div/div/div/div[4]/div[1]/div/div/div/div/div[3]') }
    driver.find_element(xpath: '//*[@id="app"]/div/div/div/div[4]/div[1]/div/div/div/div/div[3]').click

    sleep 5

    driver.quit # Close the browser session when done
end

# Use threads to handle multiple users concurrently
threads = config[:users].map do |user|
    Thread.new do
        login_join_and_leave_meeting(user, config[:meeting_url], build_driver)
    end
end

# Wait for all threads to complete
threads.each(&:join)
