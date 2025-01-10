//VIEW MODEL

import SwiftUI
import CoreData

//in charge of any user profile changes and their journal entry list
class ProfileViewModel: ObservableObject {
    //have a userprofile to be able to refer back to
    @Published var userProfile: UserProfile?
    //reference to journalviewmodel so it can use it's functions
    @ObservedObject var journalViewModel: JournalViewModel

    init(journalViewModel: JournalViewModel) {
        self.journalViewModel = journalViewModel
    }
    
    //function that adds a userprofile to coredata
    func addProfile(username: String, password: String) {
        let context = PersistenceController.shared.container.viewContext
        
        //setting up the profile to add
        let newProfile = UserProfile(context: context)
        newProfile.username = username
        newProfile.password = password
        
        //create a starter journal entry to introduce user's to the app
        let entry = JournalEntry(context: context)
        entry.title = "Welcome to DailyBites"
        entry.caption = "Here you can add any notes or comments about the meal you just ate! You an also swipe to delete any entry you want to remove!"
        entry.date = Date()
        entry.location = "Tempe"
        
        //adding it to a set of JournalEntry's
        newProfile.addToJournalEntries(entry)
        
        do {
            //save
            try context.save()
        } 
        
        catch {
            print("Profile Saving Error: \(error)")
        }
    }
    
    //for login, it checks if there exists a userprofile with matching username and password
    func authenticate(username: String, password: String) -> UserProfile? {
        let context = PersistenceController.shared.container.viewContext
        let fetchRequest: NSFetchRequest<UserProfile> = UserProfile.fetchRequest() // Ensure type is correctly cast
        
        //filter search result
        fetchRequest.predicate = NSPredicate(format: "username == %@ AND password == %@", username, password)
        
        do {
            let results = try context.fetch(fetchRequest)
            return results.first
        } 
        
        catch {
            print("Authentication failed: \(error)")
            return nil
        }
    }
    
    //function to add a journal entry to the set of Journal Entry's and using journalviewmodel
    func addJournalEntry(date: Date, title: String, caption: String, photos: [Data]?, location: String) {
        //make sure there exists a user
        guard let userProfile = userProfile else {
            return
        }

        //using journalviewmodel, add an entry
        journalViewModel.addEntry(date: date, title: title, caption: caption, photos: photos, location: location)

        //whatever was last added, add it to the set of Journal Entry's that the user has
        if let entry = journalViewModel.entries.last {
            //uses subclass entity function
            userProfile.addToJournalEntries(entry)
        }

        //save profile, update entry list, and alert the profile view so it updates
        saveUserProfile()
        fetchJournalEntries()
        objectWillChange.send()
    }
    
    //function that gets all the existing journal entries, for updating
    func fetchJournalEntries() {
        //makes sure user exists
        guard let userProfile = userProfile else {
            return
        }
        
        //fetch set of journal entries with current user
        let context = PersistenceController.shared.container.viewContext
        let fetchRequest: NSFetchRequest<JournalEntry> = JournalEntry.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "user == %@", userProfile)
        
        do {
            //update
            let entries = try context.fetch(fetchRequest)
            userProfile.journalEntries = Set(entries)
        } 
        
        catch {
            print("Couldn't fetch entries: \(error)")
        }
    }

    //function to delete an entry when swiped
    func deleteEntry(at offsets: IndexSet, from sortedEntries: [JournalEntry]) {
        let context = PersistenceController.shared.container.viewContext
        //makes sure user exists
        guard let userProfile = userProfile else {
            return
        }

        //get the right journal entry to delete
        for index in offsets {
            let entry = sortedEntries[index]
            //delete from data
            let context = PersistenceController.shared.container.viewContext
            context.delete(entry)
                
            //remove from set of journal entries (using subclass entity function)
            userProfile.removeFromJournalEntries(entry)
        }

        //save and update
        saveUserProfile()
        fetchJournalEntries()
    }


    //function to save the user profile (if needed after modifying entries)
    private func saveUserProfile() {
        let context = PersistenceController.shared.container.viewContext
        do {
            try context.save()
        }
        
        catch {
            print("Couldn't save profile after a change: \(error.localizedDescription)")
        }
    }
}
