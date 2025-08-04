import SwiftUI
import ComposableArchitecture

struct KeyboardView: View, Equatable {
    @Bindable var store: StoreOf<KeyboardFeature>

    static func == (lhs: KeyboardView, rhs: KeyboardView) -> Bool {
        return lhs.store.usedLetters == rhs.store.usedLetters
    }

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
//            .debugBorder()
        }
    }
}
