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
		return Int(lengthString)
	}

	return nil;
}

public struct SCGIMessage {
	
	private let data: NSData
	private(set) var headers: [String : String] = [:]
	private(set) var body = ""

	init(data: NSData) {
		self.data = data
		let (headers, body) = parseRequest(data)
		self.headers = headers
		self.body = body
	}

	func parseRequest(requestData: NSData) -> (SCGIHeaders, String) {
		let count = requestData.length / sizeof(UInt8)
		var bytes = [UInt8](count: count, repeatedValue: 0)
		requestData.getBytes(&bytes, length: count * sizeof(UInt8))

		let (headersLength, restOfBytes) = parseHeadersLength(bytes)
		if headersLength != nil {
			let (headers, bodyBytes) = parseHeaders(restOfBytes, headersLength: headersLength!)
			let body = parseBody(bodyBytes)
			return (headers, body)
		}

		return ([:], "")
	}

	private func parseHeadersLength(bytes: [UInt8]) -> (headersLength: Int?, rest: [UInt8]) {
		if let colon = bytes.indexOf(UInt8(":".unicodeScalars.first!.value)) {
			if let lengthStr = String(bytes: bytes[0..<colon], encoding: NSASCIIStringEncoding) {
				if let length = Int(lengthStr) {
					let rest = Array(bytes[colon + 1..<bytes.count])
					return (length, rest)
				}
			}
		}
		return (nil, bytes)
	}

	private func parseHeaders(bytes: [UInt8], headersLength: Int) -> (headers: SCGIHeaders, rest: [UInt8]) {
		// Each Header is a pair of strings terminated by zero. (i.e. name 00 value 00)
		//
		let splits = bytes.split(allowEmptySlices: true, isSeparator: { $0 == 00 })

		// Convert splits to strings
		//
		let strings = splits.map { self.bytesToString(Array($0)) }

		// Pair up strings
		//
		var headers: SCGIHeaders = [:]
		var i = 0
		while i < strings.count - 1{
			let header = strings[i++]
			let value = strings[i++]
			headers[header] = value
		}

		// headersLength + 1 to skip ending comma
		let bodyBytes = Array(bytes[headersLength + 1..<bytes.count])
		return (headers, bodyBytes)
	}

	private func parseBody(bytes: [UInt8]) -> String {
		return bytesToString(bytes)
	}

	private func bytesToString(bytes: [UInt8]) -> String {
		return bytes.reduce("") { (str, byte) in
			str + String(Character(UnicodeScalar(byte)))
		}
	}

}
