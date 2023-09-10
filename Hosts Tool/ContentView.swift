import SwiftUI
import Foundation



struct ContentView: View {
    //@ObservedObject var viewModel: HostsViewModel
    @ObservedObject private var viewModel = HostsViewModel()
    @State private var selectedService: Service?
    
    var body: some View {
        VStack {
            List(viewModel.services, id: \.id) { service in
                Text(service.name)
                    .onTapGesture {
                        selectedService = service
                    }
            }
            
            if selectedService != nil {
                ServiceDetailView(service: $selectedService, viewModel: viewModel)
            }
            
            if viewModel.hasPendingChanges {
                Button("Applica modifiche") {
                  //viewModel.applyPendingChanges { message in
                        // Mostri un alert o un messaggio all'utente con il valore di "message"
                  //  }
                }
            }
        }
    }
}

struct ServiceDetailView: View {
    @Binding var service: Service?
    var viewModel: HostsViewModel
    @State private var hasUnsavedChanges = false
  
    
    private var serviceNameBinding: Binding<String> {
        Binding<String>(
            get: { self.service?.name ?? "" },
            set: { self.service?.name = $0 }
        )
    }
    
    private var serviceIPBinding: Binding<String> {
        Binding<String>(
            get: { self.service?.ip ?? "" },
            set: { self.service?.ip = $0 }
        )
    }
    
    var body: some View {
        Group {
            if let _ = service {
                VStack {
                  TextField("Nome", text: serviceNameBinding.onChange {
                    self.hasUnsavedChanges = true
                  })
                    TextField("IP", text: serviceIPBinding)
                    // Aggiungi altri TextField per gli altri attributi del servizio.
                }
            }
          if hasUnsavedChanges {
              Button("Applica Modifiche") {
                self.hasUnsavedChanges = false
              }
          }
        }
    }
}


extension Binding where Value: Equatable {
    func onChange(_ handler: @escaping () -> Void) -> Binding<Value> {
        return Binding(
            get: { self.wrappedValue },
            set: { newValue in
                if newValue != self.wrappedValue {
                    handler()
                }
                self.wrappedValue = newValue
            }
        )
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
