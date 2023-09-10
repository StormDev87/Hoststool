//
//  HostViewModel.swift
//  Hosts Tool
//
//  Created by Matteo Visca on 10/09/23.
//

import Combine
import Foundation


class HostsViewModel: ObservableObject {
  @Published var services: [Service] = []
  @Published var hasPendingChanges: Bool = false

  
  init() {
    self.services = loadServicesFromHostsFile()
  }
  
  func loadServicesFromHostsFile() -> [Service] {
      var services: [Service] = []
      do {
          let hostsContent = try String(contentsOfFile: "/etc/hosts")
          let lines = hostsContent.split(separator: "\n")
          
          let uuidPrefix = "# UUID: "
          let namePrefix = " NAME: "
          
          var index = 0
          while index < lines.count {
              let line = lines[index].trimmingCharacters(in: .whitespacesAndNewlines)
              
              if line.starts(with: uuidPrefix) {
                  let uuidString = line.components(separatedBy: uuidPrefix)[1].components(separatedBy: namePrefix)[0]
                  let serviceName = line.components(separatedBy: namePrefix)[1]
                  
                  if let uuid = UUID(uuidString: uuidString) {
                      index += 1
                      while index < lines.count && !isIPAddressEntry(line: lines[index]) {
                          index += 1
                      }
                      if index < lines.count {
                          let serviceLine = lines[index].trimmingCharacters(in: .whitespacesAndNewlines)
                          let isEnabled = !serviceLine.starts(with: "#")
                          let components = isEnabled ? serviceLine.split(separator: " ") : serviceLine.dropFirst().split(separator: " ")
                          if components.count > 1 {
                              let ip = String(components[0])
                              let hosts = Array(components[1...]).map(String.init)
                              let service = Service(id: uuid, name: serviceName, ip: ip, hosts: hosts, isEnabled: isEnabled)
                              services.append(service)
                          }
                      }
                  }
              }
              index += 1
          }
      } catch {
          print("Error reading hosts file: \(error)")
      }
      return services
  }

  
  func isIPAddressEntry(line: Substring) -> Bool {
    let strippedLine = line.trimmingCharacters(in: .whitespacesAndNewlines)
    let components = strippedLine.split(separator: " ")
    return components.first?.contains(".") ?? false
  }
   

  func writeToHostsFile(content: String, completion: @escaping (String) -> Void) {
      DispatchQueue.global(qos: .background).async {
          let shellCommand = "echo '\(content)' | sudo tee /etc/hosts"
          let appleScriptCommand = """
          do shell script "\(shellCommand)" with administrator privileges
          """
          if let script = NSAppleScript(source: appleScriptCommand) {
              var error: NSDictionary?
              script.executeAndReturnError(&error)
              if let errorDict = error {
                  DispatchQueue.main.async {
                      completion("Errore durante l'aggiornamento del file hosts: \(errorDict)")
                  }
              } else {
                  DispatchQueue.main.async {
                      completion("Successo: File hosts aggiornato correttamente.")
                  }
              }
          }
      }
  }

  
  func generateHostsContent() -> String {
      var content = ""
      for service in services {
          content += service.headerRepresentation + "\n"
          let prefix = service.isEnabled ? "" : "#"
          content += prefix + service.ipLineRepresentation + "\n"
      }
      return content
  }

  
  
}
