# frozen_string_literal: true

require 'celluloid'

class MeetingSession
    include Celluloid

    def initialize(user, meeting_url, driver)
        @user = user
        @meeting_url = meeting_url
        @driver = driver
        @wait_time = Selenium::WebDriver::Wait.new(timeout: 10)
    end

    def login_join_and_leave_meeting
        @driver.navigate.to 'https://account.microsoft.com/account/manage-my-account'

        login
        join
        leave
    end

    def login
        enter_user_name
        enter_password
        reject_stay_logged_in

        puts "Logged in for #{@user[:email]}"
    end

    def enter_user_name
        sleep 1 # these are added because the elements are not yet enteraable so the built in @wait_time fails

        @driver.find_element(:id, 'id__5').click
        @wait_time.until { @driver.find_element(name: 'loginfmt') }
        @driver.find_element(:name, 'loginfmt').send_keys(@user[:email])
        @driver.find_element(:id, 'idSIButton9').click

        sleep 1
    end

    def enter_password
        sleep 1

        @wait_time.until { @driver.find_element(id: 'i0118', name: 'passwd') }
        @driver.find_element(id: 'i0118', name: 'passwd').send_keys(@user[:password])
        @driver.find_element(:id, 'idSIButton9').click

        sleep 1
    end

    def reject_stay_logged_in
        sleep 1

        @wait_time.until { @driver.find_element(id: 'declineButton') }
        @driver.find_element(id: 'declineButton').click

        sleep 1
    end

    def join
        @driver.navigate.to @meeting_url
        @wait_time.until do
            @driver.find_element(xpath: '//*[@id="container"]/div/div/div[1]/div[4]/div/button[1]/div/h3')
        end
        @driver.find_element(xpath: '//*[@id="container"]/div/div/div[1]/div[4]/div/button[1]/div/h3').click

        puts "Waiting to join for #{@user[:email]}"
        sleep @user[:wait_before_joining]

        @wait_time.until { @driver.find_element(id: 'prejoin-join-button') }
        @driver.find_element(id: 'prejoin-join-button').click
    end

    def leave
        sleep @user[:wait_before_leaving]

        @wait_time.until do
            @driver.find_element(xpath: '//*[@id="app"]/div/div/div/div[4]/div[1]/div/div/div/div/div[3]')
        end
        @driver.find_element(xpath: '//*[@id="app"]/div/div/div/div[4]/div[1]/div/div/div/div/div[3]').click

        puts "Meeting has been left for #{@user[:email]}"
        sleep 5

        @driver.quit # Close the browser session when done
    end
end
