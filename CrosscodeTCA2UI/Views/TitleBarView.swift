import SwiftUI

struct TitleBarView: View {
    var title: String
    var color: Color
    var addItemAction: (() -> Void)?
    var showSettingsAction: () -> Void

    var body: some View {
        ZStack {
            // Background color extending to the top edge
            color
                .ignoresSafeArea(edges: .top)

            ZStack {
                HStack {
                    Spacer()
                    
                    // Centered Title
                    Text(title)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Spacer()
                }
                
                HStack {
                    Spacer()
                    if let addItemAction {
                        Button(action: {
                            addItemAction()
                        }) {
                            Image(systemName: "plus")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 24, height: 24)
                                .foregroundColor(.white)
                        }
                        .padding(.trailing, 16) // Add some right padding
                    }

                    // Settings Button (Gear Icon)
                    Button(action: {
                        showSettingsAction()
                    }) {
                        Image(systemName: "gearshape.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24)
                            .foregroundColor(.white)
                    }
                    .padding(.trailing, 16) // Add some right padding
                }
            }
            .frame(height: 30) // Set a fixed height for the title bar
        }
        .frame(height: 60) // Total height of the title bar
        .padding(.bottom, 8)
    }
}


