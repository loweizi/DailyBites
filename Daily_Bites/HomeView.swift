//VIEW
//START HERE
import SwiftUI
import CoreData

//main view, what you see when you open the app
struct HomeView: View {
    @StateObject private var profileViewModel = ProfileViewModel(journalViewModel: JournalViewModel())

    var body: some View {
        NavigationView {
            VStack {
                
                //title
                Text("DailyBites")
                    .font(.custom("AmericanTypewriter", fixedSize: 34))
                    .padding([.bottom], 10)
                //subtitle
                Text("THE daily food journal")
                    .font(.custom("AmericanTypewriter", fixedSize: 20))
                    .padding([.bottom], 80)
                //image
                Image("pizza")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 400, height: 300)
                    .padding([.bottom], 90)
                //button that goes to signupview
                NavigationLink(destination: SignUpView(profileViewModel: profileViewModel)) {
                    Text("Create Profile")
                        .padding(10)
                        .frame(width: 350)
                        .background(Color(.black))
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                }
                //button that goes to loginview
                NavigationLink(destination: LoginView(profileViewModel: profileViewModel)) {
                    Text("Login")
                        .padding(10)
                        .frame(width: 350)
                        .background(Color(.black))
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                }
            }
        }
    }
}

//preview for home view
#Preview {
    HomeView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
