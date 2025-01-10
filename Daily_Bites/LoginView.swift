//VIEW

import SwiftUI
import CoreData

//login view
struct LoginView: View {
    @ObservedObject var profileViewModel: ProfileViewModel
    
    @State private var username = ""
    @State private var password = ""
    
    @State private var borderColor: Color = Color(UIColor.lightGray)
    @State private var isLoggedIn = false
    
    var body: some View {
        ZStack {
            //background color
            Color(UIColor.lightGray)
                .opacity(0.5)
                .ignoresSafeArea()
            
            VStack {
                //username textfield
                TextField("Username", text: $username)
                    .autocapitalization(.none)
                    .padding(10)
                    .background(Color.white)
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color(UIColor.lightGray))
                            .opacity(0.5)
                    )
                    .padding(.horizontal)
                    .padding([.top], 20)
                
                //password textfield
                SecureField("Password", text: $password)
                    .autocapitalization(.none)
                    .padding(10)
                    .background(Color.white)
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(borderColor, lineWidth: 1)
                            .opacity(0.5)
                    )
                    .padding(.horizontal)
                
                //button to check if login info is right
                Button(action: {
                    //create a user w/ username and password typed in if the info matches
                    //to some account in the data, clear the fields after
                    if let userProfile = profileViewModel.authenticate(username: username, password: password) {
                        profileViewModel.userProfile = userProfile
                        isLoggedIn = true
                        clearFields()
                    }
                    //else indicate that the password is wrong
                    else {
                        borderColor = .red
                    }
                    
                }) {
                    //button UI
                    Text("Login")
                    .padding(10)
                    .frame(maxWidth: .infinity)
                    .background(Color.black)
                    .foregroundColor(.white)
                    .clipShape(Capsule())
                    }
                .padding(.horizontal)
                
                Spacer()
                
            }
            .navigationTitle("Login")
            //go to profile view if able to login
            NavigationLink(destination: ProfileView(profileViewModel: profileViewModel), isActive: $isLoggedIn) {
                EmptyView()
            }

        }
    }
    
    //clear the textfields
    private func clearFields() {
        self.username = ""
        self.password = ""
    }

}

//preview for login
#Preview {
    LoginView(profileViewModel: ProfileViewModel(journalViewModel: JournalViewModel())).environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
