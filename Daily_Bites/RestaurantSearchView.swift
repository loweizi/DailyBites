//VIEW
import SwiftUI

//allows users to search restuarants to try at
struct RestaurantSearchView: View {
    @StateObject private var viewModel = RestaurantViewModel()
    
    @State private var state = ""
    @State private var city = ""
    @State private var showList = false

    var body: some View {
        NavigationView {
            VStack {
                
                //allows to enter state
                HStack {
                    Text("Enter State: ")
                        .font(.custom("AmericanTypewriter", fixedSize: 15))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding([.leading],20)
                        .padding([.top], 30)
                    
                    TextField("Ex: AZ", text: $state)
                        .autocapitalization(.none)
                        .padding(5)
                        .background(Color.white)
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color(UIColor.lightGray))
                                .opacity(0.5)
                        )
                        .padding(.horizontal)
                        .padding([.top], 30)
                }
                
                //allows to enter city
                HStack {
                    Text("Enter City: ")
                        .font(.custom("AmericanTypewriter", fixedSize: 15))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding([.leading],20)
                    
                    TextField("Ex: Phoenix", text: $city)
                        .autocapitalization(.none)
                        .padding(5)
                        .background(Color.white)
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color(UIColor.lightGray))
                                .opacity(0.5)
                        )
                        .padding(.horizontal)
                }
                
                Divider()
                    .padding(10)
                
                //search button
                Button(action: {
                    viewModel.getJsonData(state: state, city: city)
                    showList = true
                    
                }) {
                    Text("Search Restaurants")
                        .padding(10)
                        .frame(maxWidth: .infinity)
                        .background(Color.black)
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                }
                .padding(.horizontal)
                
                //for debugging the web api call
                if let errorMsg = viewModel.errorMsg {
                    Text(errorMsg)
                        .foregroundColor(.red)
                        .padding()
                }
                
                //shows a list of restaurants to try w/ name, cuisine type, and address
                ScrollView {
                    ForEach(viewModel.restaurants, id: \.id) { restaurant in
                        VStack(alignment: .leading) {
                            Text(restaurant.restaurantName ?? "None")
                                .font(.headline)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Text(restaurant.cuisineType ?? "N/A")
                                .font(.subheadline)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundColor(.gray)
                            Text(restaurant.address ?? "N/A")
                                .font(.footnote)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundColor(.gray)
                        }
                        .padding()
                        Divider()
                    }
                }
                .padding()
                
                Spacer()
            }
        }
    }
}

//preview for restuarant search view
struct RestaurantSearchView_Previews: PreviewProvider {
    static var previews: some View {
        RestaurantSearchView()
    }
}
