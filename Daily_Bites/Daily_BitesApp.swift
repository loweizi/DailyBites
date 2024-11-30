//
//  Daily_BitesApp.swift
//  Daily_Bites
//
//  Created by Ivy Lo on 11/29/24.
//

import SwiftUI

@main
struct Daily_BitesApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
