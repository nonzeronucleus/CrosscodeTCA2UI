import ComposableArchitecture
import Foundation
import CrosscodeDataLibrary

@Reducer
struct KeyboardFeature {
    typealias State = PlayGameFeature.State
    
    @CasePathable
    enum Action {
        case view(View)
        case delegate(Delegate)
        
        @CasePathable
        enum View: Equatable {
            case letterInput(Character)
            case deleteInput
        }
        
        @CasePathable
        enum Delegate {
            case finished(Result<Void, Error>) // Num remaining letters to find
        }
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in

            switch action {
                case let .view(viewAction):
                    if state.isCompleted {return .none}
                    
                    return handleViewAction(&state, viewAction)
                case .delegate(_):
                    return .none
            }
        }
    }
}
        
extension KeyboardFeature {
    func handleViewAction(_ state: inout State, _ action: Action.View) -> Effect<Action> {
        switch action {
            case .letterInput(let letter):
                guard let selectedNumber = state.selectedNumber else { return .none }
                if let index = state.level!.attemptedLetters.firstIndex(of: letter) {
                    state.level!.attemptedLetters[index] = " "
                }
                state.level!.attemptedLetters[selectedNumber] = letter
                break
            case .deleteInput:
                guard let selectedNumber = state.selectedNumber else { return .none }
                state.level!.attemptedLetters[selectedNumber] = " "
                break
        }
        
        return .run { send in await send(.delegate(.finished(.success(())))) }
    }
}
        
