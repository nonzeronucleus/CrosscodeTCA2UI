import SwiftUI
import ComposableArchitecture

struct KeyboardView: View {
    @Bindable var store: StoreOf<KeyboardFeature>

    var body: some View {
        ZStack {
            LetterKeyboardView(
                onLetterPressed: {letter in
                    store.send(.letterInput(letter))
                },
                onDeletePressed: {
                    store.send(.deleteInput)
                },
                onEnterPressed: {},
                usedLetters: store.usedLetters
            )
//            .padding(5)
        }
    }
}
