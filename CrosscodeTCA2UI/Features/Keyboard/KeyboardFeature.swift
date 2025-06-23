import ComposableArchitecture
import Foundation
import CrosscodeDataLibrary

@Reducer
struct KeyboardFeature {
    
//    @ObservableState
//    struct State: Equatable {
//        var usedLetters: Set<Character> = []
//        var selectedLetterInGrid: Character?
//    }
    
    enum Action: Equatable {
//        case letterSelectedInGrid(Character?)
        case letterInput(Character)
        case deleteInput
//        case delegate(Delegate)
//        enum Delegate: Equatable {
//            case letterSelected(Character)
//        }
    }
    
    var body: some Reducer<PlayGameFeature.State, Action> {
        Reduce { state, action in
            switch action {
//                case .letterSelectedInGrid(let letter):
////                    state.selectedLetterInGrid = letter
////                    debugPrint("Selected letter: \(letter ?? ".")")
//                    return .none
                case .letterInput(let letter):
//                    guard let !state.usedLetters.contains(letter) else { return .none } // If the letter's already been used, don't let it be entered again

//                    guard let selectedLetterInGrid = state.selectedLetterInGrid else { return .none } // If no letter selected, don't accept any imput
                    guard let selectedNumber = state.selectedNumber else { return .none }
                    
//                    debugPrint("Replacing selected letter \(selectedLetterInGrid) with \(letter)")
//                    state.usedLetters.remove(selectedLetterInGrid)
                    state.level!.attemptedLetters[selectedNumber] = letter
//                    state.usedLetters.insert(letter)
//                    state.selectedLetterInGrid = letter
                    return .none
                case .deleteInput:
                    return .none
            }
        }
    }
}
