//VIEW

import SwiftUI
import CoreData

//sign up view
struct SignUpView: View {
    @ObservedObject var profileViewModel: ProfileViewModel
    
    @State private var username = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    
    @State private var showAlert = false
    @State private var borderColor: Color = Color(UIColor.lightGray)
    @State private var alertMessage = ""

    var body: some View {
        ZStack {
            Color(UIColor.lightGray)
                .opacity(0.5)
                .ignoresSafeArea()
            
            VStack {
                //to get username
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
                
                //set password
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
                
                //reconfirming password
                SecureField("Confirm Password", text: $confirmPassword)
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
                
                //password validation feedback (makes sure format is right)
                passValidation(for: password)
                
                //sign up button
                Button(action: {
                    //if the password fits the format...
                    if validatePassword(password) {
                        //and the passwords match each other and username isn't empty
                        if password == confirmPassword && !username.isEmpty {
                            //call the addProfile function
                            profileViewModel.addProfile(username: username, password: password)
                            alertMessage = "Successfully signed up!"
                            showAlert = true
                            clearFields()
                        } else { //else have an alert that tells user passwords don't match
                            borderColor = .red
                            alertMessage = "Passwords do not match."
                            showAlert = true
                        }
                    } else { //else have an alert that tells user password doesn't match format
                        borderColor = .red
                        alertMessage = "Password must be at least 8 characters long and contain at least one number."
                        showAlert = true
                    }
                }) {
                    Text("Sign Up")
                        .padding(10)
                        .frame(maxWidth: .infinity)
                        .background(Color.black)
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                }
                .padding(.horizontal)
                
                //hyperlink if user already has an account
                NavigationLink(destination: LoginView(profileViewModel: profileViewModel)) {
                    Text("Already have an account? Login?")
                    .foregroundColor(.blue)
                    .padding(.top, 10)
                }
                
                Spacer()
            }
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Success!"),
                    message: Text(alertMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
            .navigationTitle("Sign Up")
        }
    }
    
    //function to provide feedback for password requirements
    private func passValidation(for password: String) -> some View {
        let isValid = validatePassword(password)
        let color = isValid ? Color.green : Color.red
        
        //allows user to see in real time
        return VStack(alignment: .leading) {
            Text("Password must be at least 8 characters long and contain at least one number.")
                .foregroundColor(color)
                .font(.caption)
                .padding(.leading, 10)
        }
    }
    
    //function that checks if it fits password reqs
    private func validatePassword(_ password: String) -> Bool {
        let passwordReq = "^(?=.*[0-9]).{8,}$" //at least one number and minimum 8 characters
        let passwordTest = NSPredicate(format: "SELF MATCHES %@", passwordReq)
        return passwordTest.evaluate(with: password)
    }
    
    //clear fields
    private func clearFields() {
        self.username = ""
        self.password = ""
        self.confirmPassword = ""
    }
}

//preview for sign up
#Preview {
    SignUpView(profileViewModel: ProfileViewModel(journalViewModel: JournalViewModel())).environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
