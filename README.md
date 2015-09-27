SwiftSCGI
=========

A [Simple Common Gateway Interface](https://en.wikipedia.org/wiki/Simple_Common_Gateway_Interface) server written in 
Swift.

SCGI allows any web server that supports it to interface with an external program. In this case a program
written in Swift. This provides a basis for writing web applications in Swift and interfacing with any popular web
server that supports SCGI, such as [Apache](https://httpd.apache.org), [nginx](http://nginx.org), and 
[lighttpd](http://redmine.lighttpd.net)

Once you've configured your web server, just launch it and then launch your application that has the SwiftSCGI code
embedded in it.


Installing
----------
No Cocoapod right now. Just copy the code into your project and modify as needed. 

You can either use main.swift as is
if your running from the command line, or if you already have your own main program and some kind of run loop setup 
then just create the server during your startup:

	let server = SCGIServer(port: 9998)
	server.start()


Configuring Your Web Server
---------------------------
All web servers have a different way of being configured, so consult your web server's documentation. 
Here's an excerpt from a lighttpd configuration file:

	server.modules = ("mod_scgi")
	$HTTP["host"] == "swift.test.com" {
	  server.document-root  = "/var/www/example.com/public"
	  server.error-handler-404 = "/error.html"
	  scgi.server = ( "/swift/" =>
		( "scgi-tcp" =>
		  (
			"host" => "127.0.0.1",
			"port" => 9998,
			"check-local" => "disable",
		  )
		)
	  )
	}


Now whenever the web server gets a request for something at www.example.com/swift, the server will connect to 
127.0.0.1:9998, send it an SCGI message, wait for a response, and send it to the browser.

Web Applications?
-----------------
SwiftSCGI provides one of the parts of writing web applications in Swift. You could take the code, add your own and
have a running web app. But to take this further, Swift needs something like Ruby's [Rack](http://rack.github.io). 
Then any Swift web app framework built on top of a Swift equivalent of Rack would be able to run on any web server
that supports SCGI (see `SCGIMessageHandler.startResponse()` for where you would add your own code or use something like
Rack.)
