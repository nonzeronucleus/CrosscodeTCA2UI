import ComposableArchitecture

@Reducer
struct PackFeature {
    @ObservableState
    struct State: Equatable {
        var packNumber : Int = 1
    }
    
    enum Action:Equatable {
        
        case incrementButtonTapped
        case decrementButtonTapped
        
        case delegate(Delegate)
        
        enum Delegate:Equatable {
            case didChangePackNumber(Int)
        }
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
                case .incrementButtonTapped:
                    state.packNumber += 1
                    return .send(.delegate(.didChangePackNumber(state.packNumber)))
                case .decrementButtonTapped:
                    guard state.packNumber > 1 else { return .none }
                    state.packNumber -= 1
                    return .send(.delegate(.didChangePackNumber(state.packNumber)))
                case .delegate:
                    return .none
            }
        }
    }
}
