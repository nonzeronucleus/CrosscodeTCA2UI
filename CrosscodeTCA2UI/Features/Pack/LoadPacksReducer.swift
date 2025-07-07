import ComposableArchitecture
import Foundation
import CrosscodeDataLibrary

@Reducer
struct LoadPacksReducer {
    @Dependency(\.apiClient) var apiClient

    enum Action: Equatable {
        case start
        case success([Pack])
        case failure(EquatableError)
        case delegate(Delegate)
        
        enum Delegate: Equatable {
            case wasLoaded
        }
    }

    var body: some Reducer<PackFeature.State, Action> {
        Reduce { state, action in
            switch action {
                case .start:
                    state.isBusy = true
                    return loadPacks(&state)

                case .success(let packs):
                    state.packs = IdentifiedArray(uniqueElements: packs)
                    state.isBusy = false
                    
                    if packs.isEmpty { return .none }
                    
                    state.packNumber = packs.last!.number
                    return .send(.delegate(.wasLoaded))

                case .failure(let error):
                    debugPrint(error.localizedDescription)
                    return .none
                    
                case .delegate:
                    return .none
            }
        }
    }

    private func loadPacks(_ state: inout PackFeature.State) -> Effect<Action> {
        return .run { send in
            do {
                let result = try await apiClient.gameLevelsAPI.fetchAllPacks()

                await send(.success(result))
            }
            catch {
                await send(.failure(EquatableError(error)))
            }
        }
    }
}
