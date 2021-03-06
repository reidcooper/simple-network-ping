#!/usr/bin/env ruby

# The MIT License (MIT)

# Copyright (c) 2014 Reid Cooper

# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

# Simple Network Ping
# */30 * * * * /usr/bin/ruby /home/pi/simple-network-ping/simple-network-ping.rb >> /home/pi/simple-network-ping/status.csv

# Run: ruby simple-network-ping.rb

# CSV OUTPUT
# Time, Router, Networked Device, Modem, External IP, Website

require 'rubygems'
require 'bundler/setup'

require 'net/ping'
require 'socket'
require 'json'
require 'net/http'
require 'mail'

@missed_pings = 0
@testiPAddr = true
@logFile = ""
@finalLog = 'server_up.csv'	#Location and log file of output
@lastWebSiteToPing = "www.espn.com" # External website to ping
$nums = Array.new()

# Read in passwords from a file, make sure there is a passwords.txt
def readPasswords()
	File.foreach('/home/pi/simple-network-ping/passwords.txt').with_index { |line|
	   $nums << line.chomp
	}
end

def ipaddress()

	uri      = URI('http://jsonip.com/')

	if @testiPAddr == true
		begin
			response = Net::HTTP.get_response(uri)
			data     = response.body
			result   = JSON.parse(data)
			ip = result['ip']
			return ip

		rescue StandardError
			return @testiPAddr = false
		end
	else
		return @testiPAddr = false
	end
end

def email(endScriptOutput)
	if @testiPAddr != false
		options = { :address              => "smtp.gmail.com",
		            :port                 => 587,
		            :domain               => $nums[0],
		            :user_name            => $nums[1],
		            :password             => $nums[2],
		            :authentication       => 'plain',
		            :enable_starttls_auto => true  }

		Mail.defaults do
		  delivery_method :smtp, options
		end

		Mail.deliver do
		       to $nums[3]
		     from $nums[0]
		  subject endScriptOutput
		     body ''
		end
	end
end

def sendMessage(host)

	if host == @lastWebSiteToPing
		if @missed_pings > 2 then
			@logFile.concat("-")
		else
			@logFile.concat("+")
		end
	else
		if @missed_pings > 2 then
			@logFile.concat("-,")
		else
			@logFile.concat("+,")
		end
	end

	if host == @lastWebSiteToPing

		endScriptOutput = Time.new.strftime("%Y-%m-%d %H:%M:%S").to_s + "," + @logFile

		positiveRegex = /(\+,\+,\+,\+,\+)/

		if !endScriptOutput.match(positiveRegex)

			File.open(@finalLog, 'a') do |log|
				# CSV OUTPUT
				# Time, Router, Networked Device, Modem, External IP, Website
				log.puts endScriptOutput
			end

			# CSV OUTPUT
			# Time, Router, Networked Device, Modem, External IP, Website
			puts endScriptOutput
			email(endScriptOutput)

		end
	end
end

def check_ping(host)
	@missed_pings = 0
	server = Net::Ping::External.new(host)

	for i in 1..5 #change depending on how many pings you want to send
			if not server.ping 
				@missed_pings+=1
			end
	end

	sendMessage(host)
end

def check_log

	$numberOfFaults = 0

	File.foreach(@finalLog).with_index { |line|
		if line.chomp.include?(Time.new.strftime("%Y-%m-%d").to_s) then
	   		$numberOfFaults+=1
	   	end
	}

	if $numberOfFaults != 0 then
		email($numberOfFaults)
	end

end

# First set up email info
readPasswords()

# In case the user wants to pass in an argument for a specific address
# check_ping(ARGV[0])
# Pings (In this order): Router, Another networked device, Another networked device, Modem, My IP, Outside website
check_ping("192.168.1.1")
check_ping("192.168.1.2")
check_ping("192.168.102.1")
check_ping("192.168.100.1")

# If External IP Address is unreachable, we still need to show the log the info
@testiPAddr = ipaddress()
if @testiPAddr == false then
	@missed_pings = 5 #otherwise, it will pass
	sendMessage("Error. Could Not Reach Home IP")
else
	check_ping(@testiPAddr)
end

check_ping(@lastWebSiteToPing)

# Check to send at 11pm
currentTime = Time.new.strftime("%H%M").to_i
if (currentTime >= 2300 && currentTime <= 2305 )
	check_log()
end
