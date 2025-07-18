import ComposableArchitecture
import Foundation
import CrosscodeDataLibrary

@Reducer
struct KeyboardFeature {
    typealias State = PlayGameFeature.State
    
    @CasePathable
    enum Action: Equatable {
        case view(View)
        
        @CasePathable
        enum View: Equatable {
            case letterInput(Character)
            case deleteInput
        }
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
                case let .view(viewAction):
                    return handleViewAction(&state, viewAction)
            }
        }
    }
}
        
extension KeyboardFeature {
    func handleViewAction(_ state: inout State, _ action: Action.View) -> Effect<Action> {
        switch action {
            case .letterInput(let letter):
                guard let selectedNumber = state.selectedNumber else { return .none }
                state.level!.attemptedLetters[selectedNumber] = letter
                return .none
            case .deleteInput:
                return .none
        }
    }
}
        
