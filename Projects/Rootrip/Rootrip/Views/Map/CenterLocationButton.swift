import SwiftUI


struct CenterLocationButton: View {
    var onTap: () -> Void

    var body: some View {
        Button(action: {
            onTap()
        }) {
            Image(systemName: "location.fill")
                .foregroundStyle(.secondary4)
                .padding()
                .background(Circle().fill(Color.primary1))
                .shadow(radius: 4)
        }
        .padding()
    }
}
