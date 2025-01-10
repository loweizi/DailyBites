import Foundation
import CoreData


extension JournalEntry {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<JournalEntry> {
        return NSFetchRequest<JournalEntry>(entityName: "JournalEntry")
    }

    @NSManaged public var title: String?
    @NSManaged public var caption: String?
    @NSManaged public var id: UUID?
    @NSManaged public var photos: NSObject?
    @NSManaged public var date: Date?
    @NSManaged public var location: String?
    @NSManaged public var user: UserProfile?
    
    public var safeTitle: String {
        return title ?? "Untitled"
    }

    public var safeCaption: String {
        return caption ?? "No caption available"
    }

    //function to retrieve photos as [Data]
    public var photoData: [Data]? {
        get {
            //attempt to cast the photos attribute as an array of data
            if let photos = photos as? [Data] {
                return photos
            }
            return nil
        }
        
        set {
            //set photos as an array of Data
            photos = newValue as NSObject?
        }
    }

}

extension JournalEntry : Identifiable {

}
