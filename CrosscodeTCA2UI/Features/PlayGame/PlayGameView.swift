import SwiftUI
import ComposableArchitecture
import CrosscodeDataLibrary

struct PlayGameView: View {
    let store: StoreOf<PlayGameFeature>
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background Layer
                backgroundGradient
                
                // Main Content Stack
                // Replace the current VStack in your body with this:
                VStack(spacing: 0) { // Changed to 0 spacing between sections
                    // Top Bar (unchanged)
//                    Text(preferences.get().isDarkMode ? "Dark Mode" : "Light Mode")

                    HStack {
                        backButton
                            .padding(.leading, UIDevice.current.userInterfaceIdiom == .pad ? 40 : 20)
                            .padding(.top, 10) // Reduced top padding
                        Spacer()
                    }
                    .frame(height: 40) // Fixed height
                    
                    if let error = store.state.error {
                        Text("Error \(error.localizedDescription)")
                    }

                    
                    // Crossword with compressed spacing
                    crosswordView(geometry: geometry)
                        .padding(.top, 5) // Reduced from verticalSpacing
                    
                    // Bottom area with priority
                    VStack(spacing: 0) {
                        Spacer(minLength: 0) // Will compress first
                        
                        // Keyboard
                        KeyboardView(store: store.scope(state: \.self, action: \.keyboard))
                            .frame(height: ViewStyle.keyboardHeight)
                            .padding(.bottom, 5) // Reduced spacing
                        
                        Spacer(minLength: 0)
                        
                        // Action Buttons (fixed at bottom)
                        actionButtons
                            .frame(height: ViewStyle.buttonHeight)
                            .padding(.bottom, 20) // Keep bottom padding
                    }
                    .padding(.horizontal, UIDevice.current.userInterfaceIdiom == .pad ? 120 : 10)
                }
                
                // Completion Overlay
                if store.isCompleted {
                    completionOverlay
                }
            }
            .ignoresSafeArea(.keyboard, edges: .bottom)
        }
        .onAppear {
            store.send(.view(.pageLoaded))
        }
    }
    
    // MARK: - Subviews
    
    private var backButton: some View {
        Button(action: {
            store.send(.view(.backButtonTapped))
        }) {
            Image(systemName: "chevron.backward.circle.fill")
                .symbolRenderingMode(.hierarchical)
                .font(.system(size: UIDevice.current.userInterfaceIdiom == .pad ? 30 : 24))
                .foregroundColor(.blue)
                .contentShape(Circle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Back")
    }
    
    private var backgroundGradient: some View {
        LinearGradient(
            gradient: Gradient(colors: [.purple.opacity(0.2), .blue.opacity(0.2)]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .edgesIgnoringSafeArea(.all)
    }
    
    private func crosswordView(geometry: GeometryProxy) -> some View {
        ZStack {
            if let gameLevel = store.level {
                CrosswordView(
                    grid: gameLevel.crossword,
                    viewMode: .attemptedValue,
                    letterMap: gameLevel.letterMap,
                    selectedNumber: store.selectedNumber,
                    attemptedletterValues: gameLevel.attemptedLetters,
                    checking: store.checking
                ) { id in
                    store.send(.playGameCell(.cellClicked(id)))
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
        }
        }
    }
    
    private var actionButtons: some View {
        HStack(spacing: ViewStyle.buttonSpacing) {
            Button(action: { store.send(.view(.checkToggled)) }) {
                Text("Check")
                    .font(.system(size: ViewStyle.buttonFontSize(), weight: .bold))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.borderedProminent)
            .tint(.blue)
            
            Button(action: { store.send(.view(.revealRequested)) }) {
                Text("Reveal Letter")
                    .font(.system(size: ViewStyle.buttonFontSize(), weight: .bold))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.borderedProminent)
            .tint(.green)
        }
    }
    
    private var completionOverlay: some View {
        Color.black.opacity(0.5)
            .edgesIgnoringSafeArea(.all)
            .overlay(
                VStack {
                    Spacer()
                    CompletedPopover {
//                        store.send(.delegate(.dismiss))
                    }
                    .padding(.horizontal, UIDevice.current.userInterfaceIdiom == .pad ? 100 : 40)
                    Spacer()
                }
            )
    }
}


extension PlayGameView {
    private enum ViewStyle {
        static func crosswordSize(_ geometry: GeometryProxy) -> CGFloat {
            UIDevice.current.userInterfaceIdiom == .pad ?
            min(geometry.size.width * 0.8, geometry.size.height * 0.6) :
            geometry.size.width * 0.95
        }
        
        static let buttonHeight: CGFloat = UIDevice.current.userInterfaceIdiom == .pad ? 60 : 50
        static let buttonSpacing: CGFloat = UIDevice.current.userInterfaceIdiom == .pad ? 50 : 20
        static let cornerRadius: CGFloat = UIDevice.current.userInterfaceIdiom == .pad ? 2 : 1
        
        static func buttonFontSize() -> CGFloat {
            UIDevice.current.userInterfaceIdiom == .pad ? 22 : 17
        }
        static let keyboardHeight: CGFloat = UIDevice.current.userInterfaceIdiom == .pad ? 220 : 160
    }
}


#Preview {
    let level = GameLevel.mocks[1]
    
    let mockAPI:APIClient =  APIClient(
        layoutsAPI: MockLayoutsAPI(levels: []),
        gameLevelsAPI: MockGameLevelsAPI(levels:[level])
    )

    withDependencies {
        $0.uuid = .incrementing
        $0.apiClient = mockAPI
    } operation: {
        @Dependency(\.uuid) var uuid
        let store = Store(
            initialState: PlayGameFeature.State(levelID: level.id),
            reducer: { PlayGameFeature() }
        )
        
        return PlayGameView(store: store)
    }
}
 
