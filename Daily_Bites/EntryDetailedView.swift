//VIEW
import SwiftUI
import MapKit

//individual entry views
struct EntryDetailedView: View {
    let entry: JournalEntry
    @ObservedObject var journalViewModel: JournalViewModel
    
    @State private var markers: [Location] = []
    @State private var region = MKCoordinateRegion(
        //default is tempe
        center: CLLocationCoordinate2D(latitude: 33.4255, longitude: -111.9400),
        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    )
    
    @State private var searchQuery = ""
    @State private var searchResults: [MKMapItem] = []


    var body: some View {
        GeometryReader { geometry in
            VStack {
                //creating a horizontally scrolling photos view
                if let photos = entry.photoData, !photos.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            //getting each photo in array of photos and converting them back into images
                            ForEach(photos, id: \.self) { photoData in
                                if let uiImage = UIImage(data: photoData) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 180, height: 180)
                                    .cornerRadius(8)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color.black, lineWidth: 1)
                                    )
                                    .padding(.bottom, 4)
                                }
                            }
                        } //end of hstack
                        .padding([.leading, .trailing], 20)
                    } //end of scrollview
                    .frame(height: 200)
                    .background(Color.black)
                }
                    
                Divider()
                    .padding(10)
                    
                    
                //formmating the date using function in journal view model
                if let entryDate = entry.date {
                    let dateComponents = journalViewModel.formattedDateComponents(for: entryDate)
                    VStack(spacing: 2) {
                        //month
                        Text(dateComponents.month)
                            .font(.system(size: 20, weight: .bold))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .foregroundColor(.black)
                        //day
                        Text(dateComponents.day)
                            .font(.system(size: 15, weight: .regular))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .foregroundColor(.gray)
                    }
                    .padding([.leading], 20)
                    .padding([.bottom], 10)
                }
                    
                //title
                Text(entry.title!)
                    .font(.custom("AmericanTypewriter", fixedSize: 25))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding([.leading],20)
                  
                //caption
                Text(entry.caption!)
                    .font(.custom("AmericanTypewriter", fixedSize: 15))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding([.leading],20)
                    
                Divider()
                    .padding(10)
                    
                //location
                Text("Eaten At: \(entry.location ?? "Unknown Location")")
                    .font(.custom("AmericanTypewriter", fixedSize: 15))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding([.leading],20)
                     
                //show map based on saved location string
                if let location = entry.location, !location.isEmpty {
                    Map(coordinateRegion: $region, annotationItems: markers) { marker in
                        MapPin(coordinate: marker.coordinate, tint: .red)
                    }
                    .frame(height: 200)
                    .cornerRadius(8)
                    .padding(.horizontal)
                }
            } //end of vstack
        }
        //creates the map
        .onAppear {
            performSearch()
        }
        
    }
    
    //uses location string to set map constraints
    private func performSearch() {
        //setting the request to be location string (and start off in tempe)
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = entry.location
        request.region = region

        let search = MKLocalSearch(request: request)
        search.start { response, error in
            if let response = response {
                //set the search results to wtv search results found w/ string
                searchResults = response.mapItems
                markers = response.mapItems.map {
                    Location(location: $0.name ?? "Unknown", coordinate: $0.placemark.coordinate)
                }
                
                if let firstResult = response.mapItems.first?.placemark.coordinate {
                    region.center = firstResult
                }
                
            }
            
            else {
                print("Couldn't find location in entry view: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }
}
