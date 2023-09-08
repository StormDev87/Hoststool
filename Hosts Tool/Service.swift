//
//  Service.swift
//  Hosts Tool
//
//  Created by Matteo Visca on 08/09/23.
//

import Foundation

struct Service: Identifiable, Codable {
    var id = UUID()
    var name: String
    var ip: String
    var domains: [String]
}
