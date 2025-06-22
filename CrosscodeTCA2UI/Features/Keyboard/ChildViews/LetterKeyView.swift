import SwiftUI



// Supporting Views (optimized)
struct LetterKeyView: View {
    let letter: Character
    let color: Color
    let onClick: () -> Void
    
    var body: some View {
        Button(action: onClick) {
            Text(String(letter))
                .font(.system(size: 20, weight: .bold))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(color)
                .cornerRadius(4)
        }
        .buttonStyle(.plain)
    }
}



//
//struct LetterKeyView: View{
//    let char: Character?
//    let onClick: () -> Void
//    let color:Color
//
//    init(_ char:Character?,
//         color: Color,
//         onClick:@escaping () -> Void
//    ) {
//        self.char = char
//        self.onClick = onClick
//        
//        self.color = color
//    }
//    
//    var body: some View {
//        GeometryReader { geo in
//            HStack(spacing:0)
//            {
//                if let letterToShow = char {
//                    Button {
//                        onClick()
//                    } label: {
//                        LetterView(char: String(letterToShow), color: color)
//                            .frame(width: geo.size.width, height: geo.size.height)
//                    }
//                } else {
//                    LetterView(char: String(" "), color:color, fontColor: Color.secondary)
//                }
//            }
//        }
//    }
//}
//
//
//struct LetterKey_Previews: PreviewProvider {
//    
//    static var previews: some View {
//        VStack {
//            HStack {
//                LetterKeyView("A", color:  Color(UIColor.systemBackground), onClick: {})
//                LetterKeyView("B", color:  Color(UIColor.systemBackground), onClick: {})
//                LetterKeyView("C", color:  Color(UIColor.systemBackground), onClick: {})
//            }
//        }
//    }
//}
