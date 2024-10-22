# frozen_string_literal: true

require 'celluloid'

class MeetingSession
    include Celluloid

    def initialize(user, meeting_url, driver)
        @user = user
        @meeting_url = meeting_url
        @driver = driver
        @wait_time = Selenium::WebDriver::Wait.new(timeout: 10)
        @max_retries = 5
    end

    def login_join_and_leave_meeting
        @driver.navigate.to 'https://account.microsoft.com/account/manage-my-account'

        login
        join
        leave

        'completed'
    rescue
        'completed'
    end

    def login
        @driver.find_element(:id, 'id__5').click
        enter_user_name
        enter_password
        reject_stay_logged_in

        puts "Logged in for #{@user[:email]}"
    end

    def enter_user_name
        retries = 0

        begin
            @wait_time.until { @driver.find_element(name: 'loginfmt') }
            @driver.find_element(:name, 'loginfmt').send_keys(@user[:email])
            @driver.find_element(:id, 'idSIButton9').click
        rescue
            retry if (retries += 1) < @max_retries
        end
    end

    def enter_password
        retries = 0

        begin
            @wait_time.until { @driver.find_element(id: 'i0118', name: 'passwd') }
            @driver.find_element(id: 'i0118', name: 'passwd').send_keys(@user[:password])
            @driver.find_element(:id, 'idSIButton9').click
        rescue
            retry if (retries += 1) < @max_retries
        end
    end

    def reject_stay_logged_in
        retries = 0

        begin
            @wait_time.until { @driver.find_element(id: 'declineButton') }
            @driver.find_element(id: 'declineButton').click
        rescue
            retry if (retries += 1) < @max_retries
        end
    end

    def join
        @driver.navigate.to @meeting_url
        join_from_browser

        puts "Waiting to join for #{@user[:email]}"
        sleep @user[:wait_before_joining]

        @wait_time.until { @driver.find_element(id: 'prejoin-join-button') }
        @driver.find_element(id: 'prejoin-join-button').click
    end

    def join_from_browser
        retries = 0

        begin
            @wait_time.until do
                @driver.find_element(xpath: '//*[@id="container"]/div/div/div[1]/div[4]/div/button[1]/div/h3')
            end
            @driver.find_element(xpath: '//*[@id="container"]/div/div/div[1]/div[4]/div/button[1]/div/h3').click
        rescue
            retry if (retries += 1) < @max_retries
        end
    end

    def leave
        sleep @user[:wait_before_leaving]

        @wait_time.until do
            @driver.find_element(xpath: '//*[@id="app"]/div/div/div/div[4]/div[1]/div/div/div/div/div[3]')
        end
        @driver.find_element(xpath: '//*[@id="app"]/div/div/div/div[4]/div[1]/div/div/div/div/div[3]').click

        puts "Meeting has been left for #{@user[:email]}"
        @driver.quit # Close the browser session when done
    end
end
