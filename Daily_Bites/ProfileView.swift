//VIEW
import SwiftUI

//what users see after logging in
struct ProfileView: View {
    @ObservedObject var profileViewModel: ProfileViewModel
    
    var body: some View {
        //make the journalEntries an array and sort by date
        let journalEntries = Array(profileViewModel.userProfile?.journalEntries ?? [])
        let sortedEntries = journalEntries.sorted { ($0.date ?? Date()) > ($1.date ?? Date()) }
        
        GeometryReader { geometry in
            VStack(spacing: 0) {
                
                //UI black rectangle w/ user's name indicating the right acc
                Rectangle()
                    .fill(Color.black)
                    .frame(width: geometry.size.width, height: geometry.size.height / 4)
                    .ignoresSafeArea()
                    .overlay(
                        VStack{
                            Spacer()
                            Text("\(profileViewModel.userProfile?.username ?? "User")")
                                .font(.custom("AmericanTypewriter", fixedSize: 25))
                                .foregroundColor(.white)
                            Spacer()
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.black)
                    )
                
                //list of all journal entries for user
                List {
                    ForEach(sortedEntries, id: \.self) { entry in
                        NavigationLink(destination: EntryDetailedView(entry: entry, journalViewModel: profileViewModel.journalViewModel)) {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(entry.title ?? "Untitled")
                                        .font(.headline)
                                    Text(entry.date ?? Date(), style: .date)
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                } //end of vstack
                                
                                Spacer()
                            } //end of hstack
                        }
                    }
                    //delete on swipe w/ the array index and refresh
                    .onDelete { offsets in
                        profileViewModel.deleteEntry(at: offsets, from: sortedEntries)
                        profileViewModel.fetchJournalEntries()
                    }
                }
                .ignoresSafeArea(edges: .top)
                //.listStyle(PlainListStyle())
                
                //Spacer()
                
            } //end of vstack
        }//end of geo
        .overlay(
            //add entry button
            VStack {
                                
                Spacer()
                                
                HStack {
                    
                    Spacer()
                    //link to add entry view
                    NavigationLink(destination: AddEntryView(profileViewModel: profileViewModel)) {
                        //button UI
                        ZStack {
                            Circle()
                            .fill(Color.black)
                            .frame(width: 40, height: 40)
                            Image(systemName: "plus")
                            .foregroundColor(.white)
                            .font(.system(size: 20, weight: .bold))
                        }
                    }
                    .padding()
                } //end of hstack
            } //end of vstack
            .onAppear {
                //so it refreshes even when you come back from adding
                profileViewModel.fetchJournalEntries()
            }
        )
        .navigationTitle("Profile")
        .navigationBarItems(trailing:
                    // Add button in the top-right corner to navigate to the restaurant search
            NavigationLink(destination: RestaurantSearchView()) {
                Text("Find Restaurants")
                    .font(.body)
                    .foregroundColor(.white)
            }
        )
    }
}

//preview for profile
#Preview {
    ProfileView(profileViewModel: ProfileViewModel(journalViewModel: JournalViewModel())).environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
