//
//  Personal_Info_FormApp.swift
//  Personal_Info_Form
//
//  Created by 李熙欣 on 2024/12/22.
//

import SwiftUI

@main
struct Personal_Info_FormApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
