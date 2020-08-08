//
//  ContentView.swift
//  Unspash With SwitUI
//
//  Created by Vikesh Prasad on 06/08/20.
//  Copyright © 2020 Mobiotics. All rights reserved.
//

import SwiftUI
import SDWebImageSwiftUI

struct ContentView: View {
    var body: some View {
        HomeView()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct HomeView: View {
    
    @State var isExpanded = false
    @State var searchQuery = ""
    @State var currentPage = 1
    @ObservedObject var homeImages = FetchData()
    //
    
    var body: some View {
        VStack(spacing: 0){
            HStack() {
                
                if !isExpanded {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Unsplash")
                            .font(.title)
                            .fontWeight(.bold)
                        Text("The internet’s source of freely-usable images.")
                            .font(.callout)
                    }
                    .foregroundColor(.black)
                }
                
                Spacer(minLength: 0)
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                    .font(.system(size: 15, weight: .bold))
                    .onTapGesture {
                        withAnimation {
                            self.isExpanded = true
                        }
                }
                
                if self.isExpanded {
                    TextField("Seach High Resolution Pictures", text: self.$searchQuery)
                    
                    Button(action: {
                        withAnimation {
                          self.isExpanded = false
                        }
                        self.currentPage = 1
                        self.searchQuery = ""
                        self.homeImages.imageCollection.removeAll()
                        self.homeImages.fetchUnspashPhoto()
                        
                    }, label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(.black)
                    })
                        .padding(.leading, 10)
                }
                
                if !self.searchQuery.isEmpty {
                    Button(action: {
                        self.homeImages.searchQueryFromAPI(searchQuery: self.searchQuery, currentPage: self.currentPage)
                    }, label: {
                        Text("Search")
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                    })
                }
                
                
            }
            .padding(.top, UIApplication.shared.windows.first?.safeAreaInsets.top)
            .padding()
            .background(Color.white)
            Spacer()
            
            
            //Collection View
            if self.homeImages.imageCollection.isEmpty {
                ActivityIndicator()
                Spacer()
                
            } else {
                ScrollView(.vertical, showsIndicators: false) {
                    
                    ForEach(self.homeImages.imageCollection, id: \.self) { i in
                        HStack(spacing: 20) {
                            ForEach(i) { j in
                                AnimatedImage(url: URL(string: j.urls["thumb"]!))
                                    .resizable()
                                    .frame(width: (UIScreen.main.bounds.width - 50)/2, height: 200)
                                    .cornerRadius( 10)
                                    .foregroundColor(.clear)
                                    .contextMenu {
                                        Button(action: {
                                            
                                            self.saveImageToAlubum(url: URL(string: j.urls["thumb"]!)!)
                                            
                                        }) {
                                            HStack {
                                                Text("SAVE")
                                                Spacer()
                                                Image(systemName: "square.and.arrow.down.fill")
                                            }
                                        }
                                }
                            }
                        }
                    }
                }
            }
            
            //Refresh Images
            if !self.homeImages.imageCollection.isEmpty {
                
                if !self.searchQuery.isEmpty {
                   
                    HStack {
                        Text("Page: \(self.currentPage) ")
                        Spacer()
                        Button(action: {
                            self.homeImages.imageCollection.removeAll()
                            self.currentPage += 1
                            self.homeImages.searchQueryFromAPI(searchQuery: self.searchQuery, currentPage: self.currentPage)
                        }) {
                            Text("Refresh ")
                                .foregroundColor(.black)
                                .background(Color.white.opacity(0.45))
                                .cornerRadius(15)
                        }
                    }
                    .padding(.horizontal, 25)
                    
                } else {
                    
                    HStack {
                        Spacer()
                        Button(action: {
                            self.homeImages.imageCollection.removeAll()
                            self.homeImages.fetchUnspashPhoto()
                        }) {
                            Text("Refresh ")
                                .foregroundColor(.black)
                                .background(Color.white.opacity(0.45))
                                .cornerRadius(15)
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 25)
                }
                
            }
        }
        .background(Color.black.opacity(0.07).edgesIgnoringSafeArea(.top))
        .edgesIgnoringSafeArea(.top)
    }
    
    fileprivate func saveImageToAlubum(url: URL) {
        SDWebImageDownloader()
            .downloadImage(with:  url) { (image, _, _, _) in
                if let downloadImage = image {
                    UIImageWriteToSavedPhotosAlbum(downloadImage, nil, nil, nil)
                }
        }
    }
}



class FetchData: ObservableObject {
    @Published  var imageCollection: [[Photo]] = []
    init() {
        fetchUnspashPhoto()
    }
    func fetchUnspashPhoto() {
        let url = "https://api.unsplash.com/photos/random/?count=30&client_id=En17yud3LaGP_2z_P7ss26pVkVBnzoExXYNup0sONyY"
        
        let session = URLSession(configuration: .default)
        session.dataTask(with: URL(string: url)!) { (data, response, err) in
            if err == nil {
                do {
                    let json = try JSONDecoder().decode([Photo].self, from: data!)
                    
                    for i in stride(from: 0, to: json.count, by: 2){
                        print(i)
                        var ArrayData : [Photo] = []
                        
                        for j in i..<i+2{
                            // Index out bound ....
                            if j < json.count{
                                ArrayData.append(json[j])
                            }
                        }
                        DispatchQueue.main.async {
                            
                            self.imageCollection.append(ArrayData)
                        }
                    }
                    
                }catch {
                    debugPrint(error.localizedDescription)
                }
                
            } else {
                debugPrint(err.debugDescription)
            }
        }.resume()
        
    }
    
    func searchQueryFromAPI(searchQuery: String, currentPage: Int) {
          
          self.imageCollection.removeAll()
          let query  = searchQuery.replacingOccurrences(of: " ", with: "%20")
          let url = "https://api.unsplash.com/search/photos/?page=\(currentPage)&query=\(query)&client_id=En17yud3LaGP_2z_P7ss26pVkVBnzoExXYNup0sONyY"
          
          let session = URLSession(configuration: .default)
          session.dataTask(with: URL(string: url)!) { (data, response, err) in
              if err == nil {
                  do {
                      let json = try JSONDecoder().decode(SearchPhoto.self, from: data!)
                      
                    for i in stride(from: 0, to: json.results.count, by: 2){
                          var ArrayData : [Photo] = []
                          
                          for j in i..<i+2{
                              // Index out bound ....
                            if j < json.results.count{
                                ArrayData.append(json.results[j])
                              }
                          }
                          DispatchQueue.main.async {
                              
                              self.imageCollection.append(ArrayData)
                          }
                      }
                      
                  }catch {
                      debugPrint(error.localizedDescription)
                  }
                  
              } else {
                  debugPrint(err.debugDescription)
              }
          }.resume()
          
      }
}

struct Photo: Identifiable, Decodable, Hashable {
    var id: String
    var urls: [String: String]
}

struct SearchPhoto: Decodable {
    var results: [Photo]
}
struct ActivityIndicator: UIViewRepresentable {
    typealias UIViewType = UIActivityIndicatorView
    
    func makeUIView(context: UIViewRepresentableContext<ActivityIndicator>) -> UIActivityIndicatorView {
        let view = UIActivityIndicatorView(style: .large)
        view.startAnimating()
        return view
    }
    func updateUIView(_ uiView: UIActivityIndicatorView, context: UIViewRepresentableContext<ActivityIndicator>) {
        
    }
    
}
