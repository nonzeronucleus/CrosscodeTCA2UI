import ComposableArchitecture
import Foundation
import CrosscodeDataLibrary


@Reducer
struct LoadLayoutReducer {
    typealias State = EditLayoutFeature.State
    @Dependency(\.apiClient) var apiClient
    
    @CasePathable
    enum Action {
        case api(API)
        case delegate(Delegate)

        @CasePathable
        enum API {
            case start(UUID)
        }
        
        @CasePathable
        enum Delegate {
            case finished(Result<Layout, Error>)
            case other
        }
        
        case `internal`(Internal)
        @CasePathable
        enum Internal {
            case finished(Result<Layout, Error>)
        }
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
                case .api(.start(let id)):
                    state.isBusy = true
                    return .run { send in
                      let result = await loadLayout(id: id, apiClient: apiClient)
                      await send(.internal(.finished(result)))
                      await send(.delegate(.finished(result)))
                    }
                    
                    
                case .internal(.finished(let result)):
                    state.isBusy = false
                    switch result {
                        case .success(let layout):
                            state.layout = layout
                        case .failure:
                            break
                    }
                    return .none
                    
                case .delegate:
                    return .none
            }
        }
    }
    
    func loadLayout(id: UUID, apiClient: APIClient) async -> Result<Layout, Error> {
        do {
            let response = try await apiClient.layoutsAPI.fetchLevel(id: id)
            guard let layout = response as? Layout else {
                throw EditLayoutError.loadLayoutError
            }
            return .success(layout)
        } catch {
            return .failure(error)
        }
    }
}
