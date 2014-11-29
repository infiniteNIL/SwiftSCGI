//
//  sockaddr.swift
//  Based on gist: https://gist.github.com/brendanberg/eb10bda0d24d01606d4c
//
//

import Foundation

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
			// TODO: Make sure this is done in a machine-architecture indepenent way.
			return UInt16(sa_data.1) << 8 + UInt16(sa_data.0)
			//			return (UInt16(sa_data.1.asUnsigned()) << 8) + UInt16(sa_data.0.asUnsigned())
		}
		/*! Sets the socket's port number by destructuring the first two bytes of the
		*  sa_data field.
		* \param newValue The port number as a 16-bit unsigned integer
		*/
		set {
			// TODO: Make sure this is done in a machine-architecture indepenent way.
			sa_data.0 = CChar((newValue & 0xFF00) >> 8)
			sa_data.1 = CChar((newValue & 0x00FF) >> 0)
		}

	}

	var sin_addr: in_addr_t {
		get {
			let first = in_addr_t(sa_data.2) >> 0
			let second = in_addr_t(sa_data.3) >> 08

			return (
				// Restructures bytes 3 through 6 of sa_data into a 32-bit unsigned
				// integer IPv4 address
				// TODO: This should probably go through ntohs() first.
				first + second + in_addr_t(sa_data.4) >> 16 + in_addr_t(sa_data.5) >> 24
			)
		}
		set {
			// Destructures a 32-bit IPv4 address to set as bytes 3 through 6 of sa_data
			// TODO: This should probably go through htons() first.
			sa_data.2 = CChar((newValue & 0x000000FF) >> 00)
			sa_data.3 = CChar((newValue & 0x0000FF00) >> 08)
			sa_data.4 = CChar((newValue & 0x00FF0000) >> 16)
			sa_data.5 = CChar((newValue & 0xFF000000) >> 24)
		}
	}

	/**
	The human-readable, dotted quad string representation of the socket's IPv4 address.
	*/
	var addressString: String {
		return "\(sa_data.2).\(sa_data.3).\(sa_data.4).\(sa_data.5)"
	}
	
}
