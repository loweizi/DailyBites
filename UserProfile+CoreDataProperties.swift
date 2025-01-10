import Foundation
import CoreData


extension UserProfile {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<UserProfile> {
        return NSFetchRequest<UserProfile>(entityName: "UserProfile")
    }

    @NSManaged public var username: String?
    @NSManaged public var password: String?
    @NSManaged public var journalEntries: Set<JournalEntry>?
    
    @objc(addJournalEntriesObject:)
    @NSManaged public func addToJournalEntries(_ value: JournalEntry)
        
    @objc(removeJournalEntriesObject:)
    @NSManaged public func removeFromJournalEntries(_ value: JournalEntry)
        
    @objc(addJournalEntries:)
    @NSManaged public func addToJournalEntries(_ values: NSSet)
        
    @objc(removeJournalEntries:)
    @NSManaged public func removeFromJournalEntries(_ values: NSSet)

}

extension UserProfile : Identifiable {

}
