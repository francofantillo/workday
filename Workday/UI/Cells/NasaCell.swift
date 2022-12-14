//
//  NasaCell.swift
//  Workday
//
//  Created by Franco Fantillo on 2022-12-05.
//

import SwiftUI

struct NasaCell: View {
    
    var vm: NasaCellViewModel
    
    init(vm: NasaCellViewModel) {
        self.vm = vm
    }
    
    var body: some View {
        
        NavigationLink(value: Route.detailScreen(viewModel: DetailScreen.DetailScreenViewModel(title: vm.title, imageURL: vm.imageURL, description: vm.description ?? "", date: vm.dateCreated))) {
            
            VStack {
                
                HStack {
                    
                    AsyncImage(url: URL(string: vm.imageURL)) { phase in
                        switch phase {
                        case .failure:
                            Image(systemName: "photo")
                                .font(.largeTitle)
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        default: ProgressView()
                        }
                    }
                    .frame(width: 50, height: 50)
                    .clipShape(RoundedRectangle(cornerRadius: 25))
                    .padding(.trailing)
                    
                    Text(vm.title)
                        .foregroundColor(.black)
                    Spacer()
                    
                }
                
                Rectangle()
                    .frame(height: 2, alignment: .center)
                    .foregroundColor(Color.black)
                
                HStack {
                    Text(vm.description ?? "")
                        .multilineTextAlignment(.leading)
                        .lineLimit(3)
                    Spacer()
                }
            }
            .padding()
            .background(Color("LightGray"))
            .cornerRadius(10)
            
        }
    }
}

struct NasaCell_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            NasaCell(vm: NasaCell.NasaCellViewModel(title: "Title", imageURL: "image URL", description: "descript skl d w  fw fe rwf rw fr r ef efeee et tte ttete et ettee te te t t e et te fkl fej jfwjf jfnwnfejnfjkjfe kfj fej rljflrjwf jlrfenlje  ekfleleljgflefjfel felj feljefljlfefl efk relr b etkl le fiojsfo", dateCreated: "2020"))
        }
    }
}
