import ComposableArchitecture
import Foundation
import CrosscodeDataLibrary

@Reducer
struct KeyboardFeature {
    
    @ObservableState
    struct State: Equatable {
        var usedLetters: Set<Character> = []
    }
    
    enum Action: Equatable {
        case letterInput(Character)
        case deleteInput
    }
}
