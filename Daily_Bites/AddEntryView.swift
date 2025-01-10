//VIEW
import SwiftUI
import PhotosUI
import CoreLocation
import MapKit

//represents each location w the following info
struct Location: Identifiable {
    let id = UUID()
    var location: String
    var coordinate: CLLocationCoordinate2D
}

//view so users can add entry
struct AddEntryView: View {
    @ObservedObject var profileViewModel: ProfileViewModel
    @Environment(\.presentationMode) var presentationMode
    
    @State private var title = ""
    @State private var caption = ""
    @State private var selectedDate = Date()
    @State private var location = ""
    @State private var selectedPhotos: [PhotosPickerItem] = []
    @State private var photoData: [Data] = []
    
    @State private var markers: [Location] = []
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 33.4255, longitude: -111.9400), // Default to Tempe, Arizona
        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    )
    @State private var searchQuery = ""
    @State private var searchResults: [MKMapItem] = []
    
    var body: some View {
        ScrollView{
            VStack {
                //obtain title info
                Text("Journal Entry Title")
                    .font(.custom("AmericanTypewriter", fixedSize: 18))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding([.leading],20)
                
                TextField("", text: $title)
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
                
                Divider()
                    .padding(10)
                
                //obtain caption info
                Text("Caption")
                    .font(.custom("AmericanTypewriter", fixedSize: 15))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding([.leading],20)
                
                TextField("", text: $caption)
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
                
                Divider()
                    .padding(10)
                
                //obtain date info using datepicker
                HStack{
                    Text("Date: ")
                        .multilineTextAlignment(.center)
                        .font(.custom("AmericanTypewriter", fixedSize: 15))
                    Spacer()
                    DatePicker("Select Date", selection: $selectedDate, displayedComponents: .date)
                        .datePickerStyle(.compact)
                        .labelsHidden()
                        .padding(.trailing, 20)
                }.padding([.leading], 20)
                
                Divider()
                    .padding(10)
                
                //obtain location string
                Text("Location")
                    .font(.custom("AmericanTypewriter", fixedSize: 15))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding([.leading],20)
                
                //when "entered" show on the map
                TextField("", text: $location, onCommit: performSearch)
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
                
                //show map w/ search results
                Map(coordinateRegion: $region, annotationItems: markers) { marker in
                    MapPin(coordinate: marker.coordinate, tint: .red)
                }
                .frame(height: 150)
                .cornerRadius(8)
                .padding(.horizontal)
                
                Divider()
                    .padding(10)
                
                //allow users to add multiple images
                PhotosPicker(
                    selection: $selectedPhotos,
                    matching: .images,
                    photoLibrary: .shared()
                ) {
                    Label("Add Images", systemImage: "photo")
                        .foregroundColor(.black)
                }
                .padding(10)
                .onChange(of: selectedPhotos) { newItems in
                    //add to photos array as data type
                    Task {
                        for item in newItems {
                            if let data = try? await item.loadTransferable(type: Data.self) {
                                photoData.append(data)
                            }
                        }
                    }
                } //end of label
                
                //show the photos selected in a horizontal scroll view
                ScrollView(.horizontal) {
                    HStack {
                        ForEach(photoData.indices, id: \.self) { index in
                            //change it into image type for each
                            if let uiImage = UIImage(data: photoData[index]) {
                                VStack {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 80, height: 80)
                                        .cornerRadius(8)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(Color.gray, lineWidth: 1)
                                        )
                                        .padding(.bottom, 4)
                                    
                                    Button(action: {
                                        //if trashed, remove that photo
                                        photoData.remove(at: index)
                                    }) {
                                        Image(systemName: "trash")
                                            .foregroundColor(.red)
                                            .padding(4)
                                            .background(Color.white)
                                            .clipShape(Circle())
                                    }
                                }
                                .padding(.horizontal, 4)
                            }
                        }
                    }
                }
                .padding(.vertical)
                
                Divider()
                    .padding(10)
                
                //add entry button
                Button(action: {
                    //call profileviewmodel's add entry function
                    profileViewModel.addJournalEntry(
                        date: selectedDate,
                        title: title,
                        caption: caption,
                        photos: photoData,
                        location: location
                    )
                    //clear fields and go back to profile after done
                    clearFields()
                    presentationMode.wrappedValue.dismiss()
                    
                }) {
                    Text("Add Entry")
                        .padding(10)
                        .frame(maxWidth: .infinity)
                        .background(Color.black)
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                }
                .padding(.horizontal)
            } //end of vstack
        }
    }
    
    //clear all fields
    private func clearFields() {
            title = ""
            caption = ""
            selectedDate = Date()
            location = ""
            selectedPhotos.removeAll()
            photoData.removeAll()
            markers.removeAll()
            region = MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: 33.4255, longitude: -111.9400),
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            )
        }
    
    //searches the place for map view same as entry detailed view
    private func performSearch() {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = location
        request.region = region

        //start seraching w location string
        let search = MKLocalSearch(request: request)
        search.start { response, error in
            if let response = response {
                searchResults = response.mapItems
                markers = response.mapItems.map {
                    Location(location: $0.name ?? "Unknown", coordinate: $0.placemark.coordinate)
                }
                //set search results as the region for the map
                if let firstResult = response.mapItems.first?.placemark.coordinate {
                    region.center = firstResult
                }
            }
            
            else {
                print("Search for Map didn't work: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }
}

//preview for add entry view
struct AddEntryView_Previews: PreviewProvider {
    static var previews: some View {
        AddEntryView(profileViewModel: ProfileViewModel(journalViewModel: JournalViewModel())).environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
