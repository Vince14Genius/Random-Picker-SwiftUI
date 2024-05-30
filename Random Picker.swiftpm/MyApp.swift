import SwiftUI

@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationView {
                ItemsList()
            }
            .navigationViewStyle(.stack)
        }
    }
}
