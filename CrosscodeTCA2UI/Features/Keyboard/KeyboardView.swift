import SwiftUI
import ComposableArchitecture

struct KeyboardView: View {
    @Bindable var store: StoreOf<KeyboardFeature>

    var body: some View {
        ZStack {
            LetterKeyboardView(
                onLetterPressed: {letter in
                    store.send(.view(.letterInput(letter)))
                },
                onDeletePressed: {
                    store.send(.view(.deleteInput))
                },
                onEnterPressed: {},
                usedLetters: store.usedLetters
            )
//            .padding(5)
        }
    }
}
