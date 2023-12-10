//
//  ContentView.swift
//  OAuth
//
//  Created by Akshaya Kunila on 12/5/23.
//

import SwiftUI

struct DoorListView: View {
    
    @EnvironmentObject var router: ApplicationCoordinator
    @ObservedObject var viewModel: DoorListViewModel
    
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
    }
}

#Preview {
    DoorListView(viewModel: DoorListViewModel())
}
