Simple Network Ping
=============

Simple Network Ping is a small ruby script that pings various points specified by the user to monitor a home network or wherever they see fit.

For myself (as is in the repo), the script pings:

* Home Router
* Another Device on the Network 
* Network Modem
* External IP Address
* An External Website

##Example Code:

This script is customizable to ping whatever you'd like. Just change the IP addresses at the bottom of the script.
	
	@lastWebSiteToPing = "www.espn.com" # External website to ping
	
	...
	
	# In case the user wants to pass in an argument for a specific address
	# check_ping(ARGV[0])
	# Pings (In this order): Router, Another networked device, Modem, My IP, Outside website
	check_ping("10.0.1.1")
	check_ping("10.0.1.3")
	check_ping("192.168.100.1")

	# If External IP Address is unreachable, we still need to show the log the info
	if ipaddress() == false then
		@missed_pings = 5 #otherwise, it will pass
		sendMessage("Error. Could Not Reach Home IP")
	else
		check_ping(ipaddress())
	end

	check_ping(@lastWebSiteToPing)
	
##Output:
The script outputs (+/- state if passed or failed):

Current Version (+/- shown in order of devices pinged):

	2014-09-05 13:06:34,+,+,+,+,+

Older Version:

	Mon, 11 Aug 2014 12:19:04 -0400
	10.0.1.1 -
	10.0.1.3 -
	192.168.100.1 +
	xx.xxx.xxx.xx +
	www.espn.com +

The script also outputs the same output to a log file in the same directory of the script. You can specify where you would like the script you desire.

##Passwords:

Make sure you configure the passwords.example file. The file should have 4 lines: 

* your email
* your account name
* your account/email password
* to Address

Reference the example file.

##Run:
	ruby simple-network-ping.rb
