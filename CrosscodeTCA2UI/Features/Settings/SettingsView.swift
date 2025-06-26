import SwiftUI
import ComposableArchitecture

//struct SettingsView: View {
//    @Bindable var store: StoreOf<SettingsFeature>
//    
//    var body: some View {
//        Form {
//            Toggle("Dark Mode", isOn: $store.isEditMode)
//        }
//        .frame(minWidth: 300, minHeight: 400)
//        .padding()
//    }
//}

struct SettingsView: View {
    @Bindable var store: StoreOf<SettingsFeature>
    
    var body: some View {
        Form {
            Toggle("Dark Mode", isOn: $store.isEditMode)
        }
        .frame(minWidth: 300, minHeight: 400)
        .padding()
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        // The back button is shown automatically when pushed
    }
}

#Preview {
    let store = Store(initialState: .init()) {
        SettingsFeature()
    } withDependencies: {
        $0.uuid = .incrementing
    }
    
    SettingsView(store: store)
}



//            Section("Appearance") {
//                Toggle("Dark Mode", isOn: .constant(false))
//                Picker("Font Size", selection: .constant(1)) {
//                    Text("Small").tag(0)
//                    Text("Medium").tag(1)
//                    Text("Large").tag(2)
//                }
//            }
//
//            Section("Preferences") {
//                Button("Reset Settings") { /* Action */ }
//                Button("Help") { /* Action */ }
//            }
