//
//  main.swift
//  SwiftSCGI
//
//  Created by Rod Schmidt on 11/21/14.
//  Copyright (c) 2014 infiniteNIL. All rights reserved.
//

import Foundation

let server = SCGIServer(port: 9998)
server.start()

print("SwiftSCGI listening on port \(server.port)")

CFRunLoopRun()
