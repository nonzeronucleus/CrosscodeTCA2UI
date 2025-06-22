import SwiftUI

struct ActionKeyView: View {
    let symbol: String
    let onClick: () -> Void
    let fontScale: CGFloat
    
    var body: some View {
        Button(action: onClick) {
            Text(symbol)
                .font(.system(size: 40 * fontScale, weight: .bold))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(4)
        }
        .buttonStyle(.plain)
    }
}



//struct ActionKeyView: View{
//    let keyText: String
//    let onClick: () -> Void
//    var fontScale: Double
//    
//    
//    init(_ keyText:String,
//         onClick:@escaping () -> Void,
//         fontScale: Double
//    ) {
//        self.keyText = keyText
//        self.onClick = onClick
//        self.fontScale = fontScale
//    }
//    
//    var body: some View {
//        GeometryReader { geo in
//            Button {
//                onClick()
//            } label: {
//                LetterView(char: keyText, color: Color.cyan, fontScale: fontScale)
//            }
////            .buttonStyle(.plain)
//        }
//    }
//}
//
//
//struct ActionKey_Previews: PreviewProvider {
//    static var previews: some View {
//        ActionKeyView("X", onClick: {}, fontScale: 0.5)
//    }
//}
