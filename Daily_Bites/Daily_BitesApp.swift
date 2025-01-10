//for my web api call i have 17 calls that are avaliable to use on the acc i registered as, if that runs out
//i've provided another api key that gives it 50 more calls if needed in restuarant view model

import SwiftUI

@main
struct Daily_BitesApp: App {
    let persistenceController = PersistenceController.shared

    //start at home view
    var body: some Scene {
        WindowGroup {
            HomeView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}


