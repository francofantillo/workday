//
//  ContentView.swift
//  Workday
//
//  Created by Franco Fantillo on 2022-12-02.
//

import SwiftUI

struct NasaList: View {
    
    @EnvironmentObject private var errorHandling: ErrorHandling
    @StateObject var nasaItems = NasaItems(items: [])
    @FocusState var focus
    @State var searchString = ""
    @State var nextPageLink: String = ""
    let service = DataService(client: HttpClient(session: URLSession.shared))
    
    var searchStringBinding: Binding<String> { Binding (

        get: {
            return self.searchString
        },

        set: {
            guard $0 != "" else {
                nasaItems.items = []
                self.searchString = $0
                nextPageLink = ""
                return
            }
            guard self.searchString != $0 else { return }
            self.searchString = $0
            nextPageLink = ""
            self.getNasaItems(searchString: $0)
        })
    }
    
    private func appendNewData(collection: NasaCollection){
        DispatchQueue.main.async {
            nasaItems.items.append(contentsOf: collection.items)
            handleNextLinks(collection: collection)
        }
    }
    
    private func setNewdata(collection: NasaCollection){
        DispatchQueue.main.async {
            nasaItems.items = collection.items
            handleNextLinks(collection: collection)
        }
    }
    
    private func handleNextLinks(collection: NasaCollection){
        
        guard let links = collection.links else { return }
        
        guard !links.isEmpty else {
            nextPageLink = ""
            return
        }
        
        for link in links {
            if link.rel == "next" {
                nextPageLink = link.href
                nextPageLink = nextPageLink.replace(target: "http", withString:"https")
            }
            if link.rel == "prev" && links.count == 1 {
                nextPageLink = ""
            }
        }
    }
    
    private func getNextPage(){
        Task {
            do {

                guard nextPageLink != "" else { return }
                let url = try service.constructURLFromString(urlString: nextPageLink)
                service.getCollectionData(nextURL: url, completion: { inner in
                        do {
                            let collection = try inner()
                            appendNewData(collection: collection)
                        } catch let error as APIErrors {
                            errorHandling.handle(error: error)
                        }
                        catch let error {
                            errorHandling.handle(error: error)
                        }
                })

            } catch let error as APIErrors {
                errorHandling.handle(error: error)
            }
            catch let error {
                errorHandling.handle(error: error)
            }
        }
    }
    
    private func getNasaItems(searchString: String){
        Task {
            do {
                let url = try service.constructURLFromComponents(searchValue: searchString)
                service.getCollectionData(nextURL: url, completion: { inner in
                    do {
                        let collection = try inner()
                        setNewdata(collection: collection)
                    } catch let error as APIErrors {
                        errorHandling.handle(error: error)
                    }
                    catch let error {
                        errorHandling.handle(error: error)
                    }
                })
            }
        }
    }
    

    
    var body: some View {
        VStack {
            
            SearchBar(text: searchStringBinding, focusBinding: $focus, onEditMethod: nil)
                .padding(22)
            if !nasaItems.items.isEmpty {
                List {
                    ForEach(nasaItems.items) { item in
                        
                        if let data = item.data {
                            
                            //if !data.isEmpty {
                                NasaCell(vm: NasaCell.NasaCellViewModel(title: data[0].title ?? "", imageURL: item.links[0].href, description: data[0].description ?? "", dateCreated:   data[0].date_created ))
                                
                                    .padding([.leading, .trailing],-16)
                                    .listRowBackground(Color.clear)
                                    .listRowSeparator(.hidden)
                                    .buttonStyle(PlainButtonStyle())
                                    .onAppear(){
                                        if nasaItems.items.last == item {
                                            getNextPage()
                                        }
                                    }
                            //}
                        }
                    }
                }
                .scrollContentBackground(.hidden)
                .listStyle(PlainListStyle())
                .padding([.leading, .trailing])
            }
            Spacer()
        }
        .padding()
        .background(Color("Primary"))
        .navigationBarBackButtonHidden(true)
        .navigationTitle("Nasa Search")
        .navigationBarTitleDisplayMode(.large)
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        NasaList()
    }
}
