# frozen_string_literal: true

require 'selenium-webdriver'

# Initialize a new browser session
driver = Selenium::WebDriver.for :chrome

# Open a website
driver.navigate.to 'https://account.microsoft.com/account/manage-my-account'

# Find and interact with elements (e.g., login)
driver.find_element(:id, 'id__5').click
# wait for a specific element to show up
wait = Selenium::WebDriver::Wait.new(timeout: 10) # seconds
wait.until { driver.find_element(name: 'loginfmt') }
driver.find_element(:name, 'loginfmt').send_keys('email')
driver.find_element(:id, 'idSIButton9').click
sleep 1
wait.until { driver.find_element(id: 'i0118', name: 'passwd') }
driver.find_element(id: 'i0118', name: 'passwd').send_keys('pass')
sleep 1
driver.find_element(:id, 'idSIButton9').click
wait.until { driver.find_element(id: 'declineButton') }
driver.find_element(id: 'declineButton').click
sleep 1

driver.navigate.to 'https://teams.live.com/meet/93807945591092?p=Xvn0CHXELj5Q2SuQ5S'
wait.until { driver.find_element(xpath: '//*[@id="container"]/div/div/div[1]/div[4]/div/button[1]/div/h3') }
driver.find_element(xpath: '//*[@id="container"]/div/div/div[1]/div[4]/div/button[1]/div/h3').click


sleep 30


# driver.find_element(:name, 'password').send_keys('my_password')

# Close the browser session when done
# driver.quit
