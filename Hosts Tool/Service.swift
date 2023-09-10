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
    var hosts: [String]
    var isEnabled: Bool
}

extension Service {
  func headerLine() -> String {
    return "# UUID: \(self.id.uuidString) NAME: \(self.name)"
  }
  var headerRepresentation: String {
      return "# UUID: \(id.uuidString) NAME: \(name)"
  }
  
  var ipLineRepresentation: String {
      return "\(ip) \(hosts.joined(separator: " "))"
  }
}
