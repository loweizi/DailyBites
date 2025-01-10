//MODEL
//based on json data structure
import Foundation

struct RestaurantData: Decodable {
    let matching_results: Int
    let restaurants: [Restaurant]
}

//most had to be optional bc some places were missing info
struct Restaurant: Decodable {
    let id: Int
    let restaurantName: String?
    let address: String?
    let zipCode: String?
    let phone: String?
    let website: String?
    let email: String?
    let latitude: String?
    let longitude: String?
    let stateName: String?
    let cityName: String?
    let hoursInterval: String?
    let cuisineType: String?
}
