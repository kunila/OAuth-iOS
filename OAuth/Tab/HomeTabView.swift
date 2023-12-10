//
//  HomeTabView.swift
//  OAuth
//
//  Created by Akshaya Kunila on 12/6/23.
//

import SwiftUI

struct HomeTabView: View {
    
    @EnvironmentObject var router: ApplicationCoordinator
    @ObservedObject var viewModel: HomeTabViewModel

    var body: some View {
        TabView {
            DoorListView(viewModel: DoorListViewModel())
                .tabItem { Label("DoorList",systemImage: "door.sliding.right.hand.closed") }
            LookUpAddView(viewModel: LookUpAddViewModel())
                .tabItem { Label("LookUpAdd",systemImage: "doc.text.magnifyingglass") }
        }
    }
}

#Preview {
    HomeTabView(viewModel: HomeTabViewModel())
}
