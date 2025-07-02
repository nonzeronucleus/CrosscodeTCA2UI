import SwiftUI
import ComposableArchitecture
import CrosscodeDataLibrary



struct PackView: View {
    @Bindable var store: StoreOf<PackFeature>
    
    //    // MARK: - Computed binding for sheet
    
    var body: some View {
        HStack {
            Button(action: {store.send(.decrementButtonTapped)}) {
                Image(systemName: "arrowtriangle.left.fill")
            }
            Spacer()
            if store.state.packNumber == nil {
                Text("*")
            } else {
                Text("\(store.state.packNumber!)")
            }
            Spacer()
            Button(action: {store.send(.incrementButtonTapped)}) {
                Image(systemName: "arrowtriangle.right.fill")
            }
        }
        .padding([.leading, .trailing], 100)
        .padding([.top, .bottom], 5)
        .font(.largeTitle)
        .onAppear {
            store.send(.viewDidAppear)
        }
    }
}

#Preview {
    let store = Store(
        initialState: PackFeature.State(),
        reducer: { PackFeature() }
    )
    PackView(store: store)
}
