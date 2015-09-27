//
//  SCGIResponseHandler.swift
//  Serengeti
//
//  Created by Rod Schmidt on 11/18/14.
//  Copyright (c) 2014 infiniteNIL. All rights reserved.
//

import Foundation

public typealias SCGIHeaders = [String : String]

public class SCGIMessageHandler : NSObject {
	let message: SCGIMessage
	let fileHandle: NSFileHandle
	let server: SCGIServer

	required public init(message: SCGIMessage, requestFileHandle: NSFileHandle, server: SCGIServer) {
		self.message = message
		self.fileHandle = requestFileHandle
		self.server = server
	}

	deinit {
		// Stop the response if still running.
		endResponse()
	}

	//
	// startResponse
	//
	// Begin sending a response over the fileHandle. Trivial cases can
	// synchronously return a response but everything else should spawn a thread
	// or otherwise asynchronously start returning the response data.
	//
	// This method should only be invoked from SCGIServer
	//
	// server.closeHandler(self) should be invoked when done sending data.
	//
	func startResponse() {
		// TODO: Call into web application with environment like Rack
		// Body needs to be added to environment
		// Rack passes an input stream for the body
		// web application returns response (code, headers, body) which we relay to the web server

		let HTTPResponseHeaders =
			"Status: 200 OK\n" +
			"Content-Type: text/html\n"

		let response = HTTPResponseHeaders +
			"\n" +
			headersString(message) +
			"=================<br/>" +
			"\(message.body)"

		if let responseData = response.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false) {
			fileHandle.writeData(responseData);
		}

		server.closeHandler(self)
	}

	func headersString(message: SCGIMessage) -> String {
		return message.headers.keys.sort().reduce("") { (s, key) in
			s + "\(key) = \(message.headers[key]!)<br/>"
		}
	}

	//
	// endResponse
	//
	// Closes the outgoing file handle.
	//
	// You should not invoke this method directly. It should only be invoked from
	// SCGIServer. To close a reponse handler, use server.closeHandler(responseHandler).
	//
	// If the connection is persistent, you must set fileHandle to nil (without
	// closing the file) to prevent the connection getting closed by this method.
	//
	func endResponse() {
		fileHandle.closeFile()
	}

}
