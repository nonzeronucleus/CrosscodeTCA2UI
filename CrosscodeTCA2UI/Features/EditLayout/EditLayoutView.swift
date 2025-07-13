import SwiftUI
import ComposableArchitecture
import CrosscodeDataLibrary

struct EditLayoutView: View {
    let store: StoreOf<EditLayoutFeature>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            GeometryReader { geometry in
                ZStack {
                    backgroundGradient

                    VStack(spacing: 0) {
                        // Top bar with back button
                        HStack {
                            Button(action: {
                                store.send(.backButtonTapped)
                            }) {
                                Image(systemName: "chevron.left")
                                    .foregroundColor(.black)
                                    .bold(true)
                                Text("Back")
                                    .foregroundColor(.black)
                                    .bold(true)
                            }
                            .padding()
                            Spacer()
                        }
                        if let error = store.state.error {
                            Text("Error \(error.localizedDescription)")
                        }

                        crosswordView(geometry: geometry)
                            .padding(.top, 5)

                        VStack(spacing: 0) {
                            Spacer(minLength: 0)
                            actionButtons
                                .frame(height: ViewStyle.buttonHeight)
                                .padding(.bottom, 20)
                        }
                        .padding(.horizontal, UIDevice.current.userInterfaceIdiom == .pad ? 120 : 10)
                    }

                    if viewStore.isBusy {
                        OverlayView(
                            VStack {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(2.5)

                                Button("Cancel") {
                                    // Add cancel logic here
                                }
                            }
                        )
                    }
                }
                .ignoresSafeArea(.keyboard, edges: .bottom)
            }
            .onAppear {
                viewStore.send(.pageLoaded)
            }
        }
    }

    private func crosswordView(geometry: GeometryProxy) -> some View {
        WithViewStore(store, observe: { $0.layout }) { layoutStore in
            if let layout = layoutStore.state {
                CrosswordView(
                    grid: layout.crossword,
                    viewMode: .actualValue,
                    letterValues: layout.letterMap,
                    attemptedletterValues: nil
                ) { cell in
                    layoutStore.send(.cell(.cellClicked(cell)))
                }
                .frame(
                    width: ViewStyle.crosswordSize(geometry),
                    height: ViewStyle.crosswordSize(geometry)
                )
                .clipShape(RoundedRectangle(cornerRadius: ViewStyle.cornerRadius))
                .overlay(
                    RoundedRectangle(cornerRadius: ViewStyle.cornerRadius)
                        .stroke(Color.gray, lineWidth: 2)
                )
                .shadow(radius: 5)
            } else {
                EmptyView()
            }
        }
    }

    private var actionButtons: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            HStack(spacing: ViewStyle.buttonSpacing) {
                if viewStore.isPopulated {
                    Button("Export") {store.send(.exportButtonPressed) }
                        .buttonStyle(.borderedProminent)
                        .tint(.green)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)

                    Button("Clear") {store.send(.depopulate(.buttonClicked))}
                        .buttonStyle(.borderedProminent)
                        .tint(.red)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    Button("Duplicate") {store.send(.duplicateButtonTapped)}
                        .buttonStyle(.borderedProminent)
                        .tint(.blue)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)

                    Button("Populate") {store.send(.populate(.buttonClicked))}
                        .buttonStyle(.borderedProminent)
                        .tint(.blue)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
        }
    }

    private var backgroundGradient: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [.purple.opacity(0.2), .blue.opacity(0.2)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .edgesIgnoringSafeArea(.all)
        }
    }
}

extension EditLayoutView {
    private enum ViewStyle {
        static func crosswordSize(_ geometry: GeometryProxy) -> CGFloat {
            UIDevice.current.userInterfaceIdiom == .pad ?
                min(geometry.size.width * 0.8, geometry.size.height * 0.6) :
                geometry.size.width * 0.95
        }

        static let buttonHeight: CGFloat = UIDevice.current.userInterfaceIdiom == .pad ? 60 : 50
        static let buttonSpacing: CGFloat = UIDevice.current.userInterfaceIdiom == .pad ? 50 : 20
        static let cornerRadius: CGFloat = UIDevice.current.userInterfaceIdiom == .pad ? 2 : 1
    }
}


#Preview {
    let mock:APIClient = withDependencies {
        $0.uuid = UUIDGenerator.incrementing
    } operation: {
        .mock
    }

    let store = Store(initialState: .init(layoutID: UUID())) {
        EditLayoutFeature()
    } withDependencies: {
        $0.uuid = .incrementing
        $0.apiClient = mock
    }
    
    EditLayoutView(store: store)
}
