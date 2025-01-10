//VIEW MODEL

import SwiftUI
import CoreData
import CoreLocation
import MapKit

//in charge of the actual journa; entry
class JournalViewModel: ObservableObject {
    //creating an array of entries (so you can keep track of the last one and save all of them)
    @Published var entries: [JournalEntry] = []
    
    private let context = PersistenceController.shared.container.viewContext
    
    //function that adds a userprofile to coredata
    func addEntry(date: Date, title: String, caption: String, photos: [Data]?, location: String) {
        let context = PersistenceController.shared.container.viewContext
        let entry = JournalEntry(context: context)
        entry.date = date
        entry.title = title
        entry.caption = caption
        entry.location = location

        //save the array of photos into photos attribute
        if let photos = photos {
            entry.photoData = photos
        }
        
        //save, add, and update the entry to the list of entries
        saveContext()
        entries.append(entry)
    }
    
    //saving so it keeps the data updated any time changes are made
    private func saveContext() {
        do {
            try context.save()
            fetchEntries()
        }
        
        catch {
            print("Couldn't save due to some changes: \(error.localizedDescription)")
        }
    }
    
    //fetch all entries
    func fetchEntries() {
        let request: NSFetchRequest<JournalEntry> = JournalEntry.fetchRequest()
            
        do {
            let fetchedEntries = try context.fetch(request)
            entries = fetchedEntries
        }
    catch {
            print("Couldn't get all the entries: \(error)")
        }
    }
    
    //formatting how the date looks for detailed view later
    func formattedDateComponents(for date: Date) -> (month: String, day: String) {
        let dateFormatter = DateFormatter()
        
        //abrv month
        dateFormatter.dateFormat = "MMM"
        let month = dateFormatter.string(from: date).uppercased()
        //normal day
        dateFormatter.dateFormat = "d"
        let day = dateFormatter.string(from: date)
            
        return (month, day)
    }
}
