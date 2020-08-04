import SwiftUI

struct SearchRowView: View {
    var sender: String
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .center, spacing: 8.0) {
                // Mail Tag
                Text("Personal1234")
                    .padding([.leading, .trailing], 8.0)
                    .padding([.top, .bottom], 6.0)
                    .cornerRadius(5.0)
                    .font(.custom("Lato-Regular", size: 10.0))
                    .background(Color(.systemGray4))
                    .foregroundColor(UITraitCollection.current.userInterfaceStyle == .dark ? .white : Color(.darkGray))
                    .clipShape(Rectangle())
                    .cornerRadius(5.0)
                                
                // Mail Body
                Text("Attachment Mail")
                    .lineLimit(2)
                    .font(.custom("Lato-Regular", size: 16.0))
                
                Spacer()
                
                // Time
                Text("8:46 AM")
                    .font(.custom("Lato-Regular", size: 16.0))
                    .foregroundColor(Color(.gray))
                
            }.padding(.bottom, 2.0)
                .padding(.leading, 4.0)
                .padding(.trailing, 4.0)
            
            HStack(alignment: .center, spacing: 8.0) {
                Text(sender)
                    .foregroundColor(Color(.gray))
                    .font(.custom("Lato-Regular", size: 16.0))
                
                Spacer()
                
                // Images
                Image(systemName: "paperclip")
                    .padding(.trailing, 8.0)
                
                Image(systemName: "shield")
                    .padding(.trailing, 8.0)
                
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
                
            }.padding(.trailing, 4.0)
                .padding(.leading, 4.0)
        }
    }
}

#if DEBUG
struct SearchRowView_Previews: PreviewProvider {
    static var previews: some View {
        SearchRowView(sender: "Soham")
    }
}
#endif
