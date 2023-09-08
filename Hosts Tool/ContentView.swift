import SwiftUI
import Foundation



struct ContentView: View {
    @State private var services = [Service]()
    @State private var newServiceName = ""
    @State private var newServiceIP = ""
    @State private var newServiceDomains = ""
    @State private var selectedService: UUID? = nil
    @State private var errorMessage: String? = nil
    
    var body: some View {
        VStack(spacing: 20) {
            VStack(spacing: 10) {
                TextField("Nome del servizio", text: $newServiceName)
                TextField("IP del servizio", text: $newServiceIP)
                TextField("Domini (separati da spazio)", text: $newServiceDomains)
                
                Button("Salva") {
                    let domains = newServiceDomains.split(separator: " ").map(String.init)
                    let service = Service(name: newServiceName, ip: newServiceIP, domains: domains)
                    services.append(service)
                    newServiceName = ""
                    newServiceIP = ""
                    newServiceDomains = ""
                }
            }
            .padding()

            Picker(selection: $selectedService, label: Text("Seleziona un servizio")) {
                ForEach(services) { service in
                    Text(service.name).tag(service.id as UUID?)
                }
            }
            .padding()

            if let selectedID = selectedService, let service = services.first(where: { $0.id == selectedID }) {
                Text("IP: \(service.ip)")
                Text("Domini: \(service.domains.joined(separator: ", "))")
            } else {
                Text("Nessun servizio selezionato.")
            }
            
            if let error = errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .padding()
            }

            Button(action: applyChangesToHostsFile) {
                Text("Applica Modifiche")
            }
            .padding()

        }
        .padding()
    }
    
    func applyChangesToHostsFile() {
        if let selectedID = selectedService,
           let service = services.first(where: { $0.id == selectedID }) {
            let newEntry = "\(service.ip) \(service.domains.joined(separator: " "))"
            
            let shellCommand = "echo '\(newEntry)' | sudo tee -a /etc/hosts"
            
            let appleScriptCommand = """
            do shell script "\(shellCommand)" with administrator privileges
            """
            
            if let script = NSAppleScript(source: appleScriptCommand) {
                var error: NSDictionary?
                script.executeAndReturnError(&error)
                if let errorDict = error {
                    print("Error: \(errorDict)")
                    errorMessage = "Errore durante la modifica del file hosts: \(errorDict)"
                } else {
                    errorMessage = nil
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
