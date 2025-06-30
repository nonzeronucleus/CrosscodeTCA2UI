import SwiftUI

struct TitleBarView: View {
    var title: String
    var color: Color
    var importAction: (() -> Void)?
    var exportAction: (() -> Void)?
    var addItemAction: (() -> Void)?
    var showSettingsAction: () -> Void
    
    // Calculate if buttons are present (to adjust title position)
    private var hasRightButtons: Bool {
        importAction != nil || exportAction != nil || addItemAction != nil
    }
    
    var body: some View {
        ZStack {
            // Background color extending to the top edge
            color
                .ignoresSafeArea(edges: .top)
            
            // Title (centered by default, offset left if buttons exist)
            Text(title)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .center) // Center in available space
                .offset(x: hasRightButtons ? -20 : 0) // Nudge left if buttons are present
            
            // Right-aligned buttons
            HStack(spacing: 16) {
                if let importAction {
                    Button(action: importAction) {
                        Image(systemName: "square.and.arrow.down")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24)
                            .foregroundColor(.white)
                    }
                }
                
                if let exportAction {
                    Button(action: exportAction) {
                        Image(systemName: "square.and.arrow.up")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24)
                            .foregroundColor(.white)
                    }
                }
                
                if let addItemAction {
                    Button(action: addItemAction) {
                        Image(systemName: "plus")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24)
                            .foregroundColor(.white)
                    }
                }
                
                // Settings Button
                Button(action: showSettingsAction) {
                    Image(systemName: "gearshape.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                        .foregroundColor(.white)
                }
            }
            .padding(.trailing, 16)
            .frame(maxWidth: .infinity, alignment: .trailing) // Push buttons to the right
        }
        .frame(height: 60)
    }
}
