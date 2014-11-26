//
//  SCGIMessage.swift
//  SwiftSCGI
//
//  Created by Rod Schmidt on 11/22/14.
//  Copyright (c) 2014 infiniteNIL. All rights reserved.
//

import Foundation

func SCGIHeadersLength(message: NSData) -> Int? {
	if let s = NSString(data: message, encoding: NSUTF8StringEncoding) {
		let colonRange = s.rangeOfString(":")
		assert(colonRange.location != NSNotFound, "SCGI Content-Length not found")
		let lengthString = s.substringToIndex(colonRange.location)
		return lengthString.toInt()
	}

	return nil;
}

public struct SCGIMessage {
	private let data: NSData
	private var headersAndBody: ([String: String], String) = ([:], "")

	init(data: NSData) {
		self.data = data
		headersAndBody = parseRequest(data)
	}

	var headers: [String : String] {
		return headersAndBody.0
	}

	var body: String {
		return headersAndBody.1
	}

	func parseRequest(requestData: NSData) -> (SCGIHeaders, String) {
		if let headersLength = extractHeadersLengthFromRequest(requestData) {
			return extractHeadersAndBody(requestData)
		}
		else {
			return ([:], "")
		}
	}

	private func extractHeadersLengthFromRequest(requestData: NSData) -> Int? {
		if let s = NSString(data: requestData, encoding: NSUTF8StringEncoding) {
			let colonRange = s.rangeOfString(":")
			assert(colonRange.location != NSNotFound, "SCGI Content-Length")
			let lengthString = s.substringToIndex(colonRange.location)
			return lengthString.toInt()
		}

		return nil;
	}

	private func extractHeadersAndBody(requestData: NSData) -> (SCGIHeaders, String) {
		var headers: SCGIHeaders = [:]

		let count = requestData.length / sizeof(UInt8)
		var bytes = [UInt8](count: count, repeatedValue: 0)
		requestData.getBytes(&bytes, length: count * sizeof(UInt8))

		var index = 0

		// Skip headers length (terminated by ':')
		let colon = find(bytes, UInt8(":"))
		assert(colon != nil, "Didn't find colon separator")
		assert(colon! + 1 < count, "Nothing after colon")
		index = colon! + 1

		// Parse Headers:
		// Each Header is a pair of strings terminated by zero. (i.e. name 00 value 00)
		//
		var headerName = ""
		var s = ""
		var readingName = true

		while index < count {
			if bytes[index] == 0 {
				// End of header or value
				if readingName {
					headerName = s
				}
				else {
					let headerValue = s
					headers[headerName] = headerValue
				}

				s = ""
				readingName = !readingName
			}
			else {
				let c = Character(UnicodeScalar(bytes[index]))
				s.append(c)
			}
			++index
		}

		// Parse body
		var body = ""
		while index < count {
			let c = Character(UnicodeScalar(bytes[index]))
			body.append(c)
			++index
		}

		return (headers, body)
	}

}
