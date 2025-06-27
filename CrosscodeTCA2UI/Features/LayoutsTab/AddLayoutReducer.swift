import ComposableArchitecture
import Foundation
import CrosscodeDataLibrary

extension LayoutsTabFeature {
    @Reducer
    struct AddLayoutReducer {
        @Dependency(\.apiClient) var apiClient
        
        enum Action: Equatable {
            case start
            case delegate(Delegate)
            
            enum Delegate : Equatable {
                case failure(EquatableError)
                case success
            }
        }
        
        var body: some Reducer<LayoutsTabFeature.State, Action> {
            Reduce { state, action in
                switch action {
                    case .start:
                        return addLayout(&state)
                    case .delegate:
                        return .none
                        //                case .success:
                        //                    return .none
                        ////                    return .send(Action.fetchAll(.start))
                }
            }
        }
        //    private func handleAddLayout(_ state: inout State, action:Action.AddLayout) -> Effect<Action> {
        //        switch action {
        //            case .start:
        //                return addLayout(&state)
        //
        //            case .success:
        //                return .send(Action.fetchAll(.start))
        //        }
        //    }
        //
        
        private func addLayout(_ state: inout LayoutsTabFeature.State) -> Effect<Action> {
            return .run { send in
                do {
                    try await apiClient.layoutsAPI.addNewLayout()
                    
                    await send(.delegate(.success))
                }
                catch {
                    await send(.delegate(.failure(EquatableError(error))))
                }
            }
        }
    }
}
    
//    private func handleAddLayoutSuccess(_ state: inout State) -> Effect<Action> {
//        .send(Action.fetchAll(.start))
//    }
//}

