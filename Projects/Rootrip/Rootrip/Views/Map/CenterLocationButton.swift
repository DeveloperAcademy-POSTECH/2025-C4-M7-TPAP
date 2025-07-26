import SwiftUI


struct CenterLocationButton: View {
    var onTap: () -> Void

    var body: some View {
        Button(action: {
            onTap()
        }) {
            Image(systemName: "location.fill")
                .padding()
                .background(Circle().fill(Color.white))
                .shadow(radius: 4)
        }
        .padding()
    }
}
