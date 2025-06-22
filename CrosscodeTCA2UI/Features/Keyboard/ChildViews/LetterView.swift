import SwiftUI


struct LetterView: View{
    let char: String
    var color: Color
    var fontColor : Color = Color.primary
    var fontScale = 0.6

    init(char: String,color: Color,fontColor : Color = Color.primary,fontScale:Double = 0.6) {
        self.char = char
        self.fontColor = fontColor
        self.fontScale = fontScale
        self.color = color
    }

    init(char: String,colors:GameColors,fontScale:Double = 0.6) {
        self.char = char
        self.color = colors.background
        self.fontColor = colors.foregroundColor
        self.fontScale = fontScale
    }
    
    var body: some View {
            
        GeometryReader { geo in
            let width = abs(geo.size.width)
            let height = abs(geo.size.height*1.05)
            RoundedRectangle(cornerRadius: 4)
                .stroke(Color.primary, lineWidth: 1)
                .frame(width: width , height: height)
                .background(RoundedRectangle(cornerRadius: 4).fill(color))
                .overlay {
                    Text(char)
                        .foregroundColor(fontColor)
                        .frame(width: width, height: height)
                        .font(.system(size: geo.size.height > geo.size.width ? geo.size.width * fontScale: geo.size.height * fontScale))
                }
        }
    }
}


struct Letter_Previews: PreviewProvider {
    static var previews: some View {
        LetterView(char: "A", color: .orange)
    }
}
