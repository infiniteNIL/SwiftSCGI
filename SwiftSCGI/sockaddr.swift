//
//  sockaddr.swift
//  Based on gist: https://gist.github.com/brendanberg/eb10bda0d24d01606d4c
//
//

import Foundation

extension sockaddr_in {
	init(address: String, port: in_port_t) {
		sin_len = UInt8(sizeof(sockaddr_in))
		sin_family = sa_family_t(AF_INET)
		sin_port = port.bigEndian
		sin_addr = in_addr(s_addr: inet_addr(address))
		sin_zero = (0, 0, 0, 0, 0, 0, 0, 0)
	}
}

// C sockaddr struct Extension
// ---------------------------
// The Swift type checker doesn't allow us to use sockaddr and sockaddr_in
// interchangably, so the following extension destructures port and address
// types and sets the appropriate bytes in sa_data to use with the socket
// system calls.

extension sockaddr {
	init () {
		sa_len = 0
		sa_family = 0
		sa_data = (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
	}

	var sin_port: in_port_t {
		/*! Gets the socket's port number by restructuring bytes in the sa_data field.
		* \returns The socket's port number as a 16-bit unsigned integer
		*/
		get {
			let value: UInt16 = networkBytesToHost([sa_data.0, sa_data.1])
			return value.bigEndian
		}

		/*! Sets the socket's port number by destructuring the first two bytes of the
		*  sa_data field.
		* \param newValue The port number as a 16-bit unsigned integer
		*/
		set {
			let networkBytes = hostToNetworkBytes(newValue)
			sa_data.0 = networkBytes.0
			sa_data.1 = networkBytes.1
		}

	}

	var sin_addr: in_addr_t {
		get {
			return networkBytesToHost([sa_data.2, sa_data.3, sa_data.4, sa_data.5])
		}

		set {
			// Destructures a 32-bit IPv4 address to set as bytes 3 through 6 of sa_data
			// in_addr_t is already in network byte order (big-endian). inet_addr converted it
			let networkBytes = networkAddressToBytes(newValue)
			sa_data.2 = networkBytes.0
			sa_data.3 = networkBytes.1
			sa_data.4 = networkBytes.2
			sa_data.5 = networkBytes.3
		}

	}

	private func hostToNetworkBytes(value: UInt16) -> (Int8, Int8) {
		let byte0 = Int8(bitPattern: UInt8((value & 0xFF00) >> 8))
		let byte1 = Int8(bitPattern: UInt8((value & 0x00FF) >> 0))
		return (byte0, byte1)
	}

	private func networkAddressToBytes(value: UInt32) -> (Int8, Int8, Int8, Int8) {
		let network_value = value.bigEndian
		let byte0 = Int8(bitPattern: UInt8((network_value & 0xFF000000) >> 24))
		let byte1 = Int8(bitPattern: UInt8((network_value & 0x00FF0000) >> 16))
		let byte2 = Int8(bitPattern: UInt8((network_value & 0x0000FF00) >> 08))
		let byte3 = Int8(bitPattern: UInt8((network_value & 0x000000FF) >> 00))
		return (byte0, byte1, byte2, byte3)
	}
	
	private func networkBytesToHost<T: UnsignedIntegerType>(var bytes: [Int8]) -> T {
		assert(sizeof(T) == bytes.count, "size of network unsigned type must match number of bytes")
		let data = NSData(bytes: &bytes, length: bytes.count)
		var hostValue: T = 0
		data.getBytes(&hostValue, length: bytes.count)
		return hostValue
	}

	/**
	The human-readable, dotted quad string representation of the socket's IPv4 address.
	*/
	var addressString: String {
		return "\(sa_data.2).\(sa_data.3).\(sa_data.4).\(sa_data.5)"
	}
	
}
