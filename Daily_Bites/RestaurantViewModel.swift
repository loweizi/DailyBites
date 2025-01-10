//VIEW MODEL
import Foundation

//gets json data from web api call
class RestaurantViewModel: ObservableObject {
    //array to hold restuarants
    @Published var restaurants: [Restaurant] = []
    
    @Published var errorMsg: String?
    
    @Published var name: String?
    @Published var type: String?
    @Published var addr: String?
    
    //api key
    private let apiKey = "2f156263f3msh14df5a418a0ed63p1204bdjsn08eec44f8771"
    //if that api key runs out of call limits (50/month) last i checked i had 17 left...
    //replace with this "2f156263f3msh14df5a418a0ed63p1204bdjsn08eec44f8771"
    //4c9deab12amsh595375bea595524p1159b0jsn605ccfb42b86
    
    //function to get json data
    func getJsonData(state: String, city: String) {
        
        //base url w/ user input on state and city
        let urlString = "https://restaurants-near-me-usa.p.rapidapi.com/restaurants/location/state/\(state)/city/\(city)/0"
        
        //checks url is good
        guard let url = URL(string: urlString) else {
            self.errorMsg = "Invalid URL"
            return
        }
        
        //request to get json info w/ my api info and headers
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(apiKey, forHTTPHeaderField: "x-rapidapi-key")
        request.setValue("restaurants-near-me-usa.p.rapidapi.com", forHTTPHeaderField: "x-rapidapi-host")
        
        let urlSession = URLSession.shared
        
        //making the web api call and setting it to data
        let jsonQuery = urlSession.dataTask(with: request, completionHandler: { data, response, error in
            DispatchQueue.main.async {
                if let data = data {
                    let jsonString = String(data: data, encoding: .utf8)
                    //had to debug and match my models' atributes to json response
                    print("Raw JSON response: \(jsonString ?? "")")
                }
            }
            
            //if there's an error in getting data, print it
            if let error = error {
                DispatchQueue.main.async {
                    self.errorMsg = "Error fetching data: \(error.localizedDescription)"
                }
                return
            }
            
            //check if we got the data
            guard let data = data else {
                DispatchQueue.main.async {
                    self.errorMsg = "No data received"
                }
                return
            }
            
            //do the decoding
            do {
                //decode the json data into the restuarant data model
                let decodedData = try JSONDecoder().decode(RestaurantData.self, from: data)
                DispatchQueue.main.async {
                    //put the top 10 in an array
                    self.restaurants = Array(decodedData.restaurants.prefix(10))
                }
            } 
            //catch any decoding error and print it for debugging
            catch {
                DispatchQueue.main.async {
                    self.errorMsg = "Failed to decode data"
                    print("Decoding error: \(error)")
                }
            }
        })
        
        //start the network request
        jsonQuery.resume()
    }
}
