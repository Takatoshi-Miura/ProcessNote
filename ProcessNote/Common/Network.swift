//
//  Network.swift
//  ProcessNote
//
//  Created by Takatoshi Miura on 2021/10/23.
//

import Reachability

final class Network {

    static func isOnline() -> Bool {
        let reachability = try! Reachability()
        if reachability.connection == .unavailable {
            return false
        } else {
            return true
        }
    }

}
