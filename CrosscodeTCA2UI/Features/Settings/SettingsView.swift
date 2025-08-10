import SwiftUI
import ComposableArchitecture


struct SettingsView: View {
    @Bindable var store: StoreOf<SettingsFeature>
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button(action: {
                    store.send(.backButtonTapped)
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.black)
                        .bold(true)
                    Text("Back")
                        .foregroundColor(.black)
                        .bold(true)
                }
                .padding()
                Spacer()
            }
            
            Form {
                Toggle("Edit Mode", isOn: $store.settings.isEditMode)
            }
            .frame(minWidth: 300, minHeight: 400)
            .padding()
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
        }
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
