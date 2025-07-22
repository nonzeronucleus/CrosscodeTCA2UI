import ComposableArchitecture
import CrosscodeDataLibrary


@Reducer
struct PackFeature {
    
    @ObservableState
    struct State: Equatable {
        var isBusy: Bool = false
        var packNumber : Int? = nil
        var packs: IdentifiedArrayOf<Pack> = []
        var currentPack: Pack? {
            get {
                guard let packNumber else { return nil }
                return packs.first {$0.number == packNumber}
            }
        }
    }
    
    enum Action {
        case viewDidAppear

        case incrementButtonTapped
        case decrementButtonTapped
        
        case loadPacks(LoadPacksReducer.Action)
        
        case delegate(Delegate)
        
        enum Delegate {
            case didChangePack(Pack)
        }
    }
    
    var body: some Reducer<State, Action> {
        Scope(state: \.self, action: \.loadPacks) { LoadPacksReducer() }

        Reduce { state, action in
            switch action {
                case .viewDidAppear:
                    return .send(.loadPacks(.start))
                    
                case .incrementButtonTapped:
                    guard state.packNumber != nil else { return .none }
                    guard state.packNumber! < state.packs.count else { return .none }
                    state.packNumber! += 1
                    guard let currentPack = state.currentPack else  { return .none }
                    return .send(.delegate(.didChangePack(currentPack)))
                    
                case .decrementButtonTapped:
                    guard state.packNumber != nil else { return .none }
                    
                    guard state.packNumber! > 1 else { return .none }
                    state.packNumber! -= 1
                    guard let currentPack = state.currentPack else  { return .none }
                    return .send(.delegate(.didChangePack(currentPack)))

                case let .loadPacks(.delegate(delegateAction)):
                    return handleLoadPackDelegate(&state, delegateAction)
                    
                case .loadPacks:
                    return .none
                    
                case .delegate:
                    return .none
            }
        }
    }
    
    private func handleLoadPackDelegate(_ state: inout State,_ action: LoadPacksReducer.Action.Delegate) -> Effect<Action> {
        switch action {
            case .wasLoaded:
                guard state.packNumber != nil else { return .none }
                
                guard let currentPack = state.currentPack else  { return .none }
                return .send(.delegate(.didChangePack(currentPack)))
        }
    }
}
