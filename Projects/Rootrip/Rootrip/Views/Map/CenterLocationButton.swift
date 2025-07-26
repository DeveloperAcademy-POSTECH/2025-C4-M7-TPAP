import SwiftUI


struct CenterLocationButton: View {
    var onTap: () -> Void

    var body: some View {
        Button(action: {
            onTap()
        }) {
            Image(systemName: "location")
                .padding()
                .background(Circle().fill(Color.primary1))
                .shadow(radius: 4)
        }
        .padding()
    }
}
