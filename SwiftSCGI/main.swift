//
//  main.swift
//  SwiftSCGI
//
//  Created by Rod Schmidt on 11/21/14.
//  Copyright (c) 2014 infiniteNIL. All rights reserved.
//

import Foundation

let port: in_port_t = 9998
let server = SCGIServer(port: port)
server.start()

println("SwiftSCGI listening on port \(port)")

CFRunLoopRun()
