# frozen_string_literal: true

require 'selenium-webdriver'



options = Selenium::WebDriver::Chrome::Options.new
options.add_argument('--use-fake-device-for-media-stream')
options.add_argument('--use-fake-ui-for-media-stream')

driver = Selenium::WebDriver.for :chrome, options: options

driver.navigate.to 'https://account.microsoft.com/account/manage-my-account'

# Find and interact with elements (e.g., login)
driver.find_element(:id, 'id__5').click
# wait for a specific element to show up
wait = Selenium::WebDriver::Wait.new(timeout: 10) # seconds
wait.until { driver.find_element(name: 'loginfmt') }
driver.find_element(:name, 'loginfmt').send_keys(config[:users][0][:email])
driver.find_element(:id, 'idSIButton9').click

sleep 1

wait.until { driver.find_element(id: 'i0118', name: 'passwd') }
driver.find_element(id: 'i0118', name: 'passwd').send_keys(config[:users][0][:password])

sleep 1

driver.find_element(:id, 'idSIButton9').click
wait.until { driver.find_element(id: 'declineButton') }
driver.find_element(id: 'declineButton').click

sleep 1

driver.navigate.to config[:meeting_url]
wait.until { driver.find_element(xpath: '//*[@id="container"]/div/div/div[1]/div[4]/div/button[1]/div/h3') }
driver.find_element(xpath: '//*[@id="container"]/div/div/div[1]/div[4]/div/button[1]/div/h3').click

sleep 1

wait.until { driver.find_element(xpath: '//*[@id="prejoin-join-button"]') }
driver.find_element(xpath: '//*[@id="prejoin-join-button"]').click

sleep 15 # loading the ms teams web app takes a while

wait.until { driver.find_element(xpath: '//*[@id="app"]/div/div/div/div[4]/div[1]/div/div/div/div/div[3]') }
driver.find_element(xpath: '//*[@id="app"]/div/div/div/div[4]/div[1]/div/div/div/div/div[3]').click

sleep 30

# Close the browser session when done
driver.quit
