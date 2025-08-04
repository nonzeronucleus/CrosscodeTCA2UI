import SwiftUI

func randomColorProvider() -> Color {
    let colors = [Color.red, Color.yellow, Color.blue, Color.orange, Color.green, Color.brown]
    let random = Int.random(in: 0..<6)
    return colors[random]
}
 
extension View {
    func debugModifier<T: View>(_ modifier: (Self) -> T) -> some View {
        #if DEBUG
        return modifier(self)
        #else
        return self
        #endif
    }
    
    func debugBorder(_ color: Color = randomColorProvider(), width: CGFloat = 1) -> some View {
        self.overlay(RoundedRectangle(cornerRadius: 1).stroke(color, lineWidth: width))
    }
    
    func debugBackground(_ color: Color = .red) -> some View {
        debugModifier {
            $0.background(color)
        }
    }
}


