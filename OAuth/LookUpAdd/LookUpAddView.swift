//
//  LookUpAddView.swift
//  OAuth
//
//  Created by Akshaya Kunila on 12/6/23.
//

import SwiftUI

struct LookUpAddView: View {
    
    @EnvironmentObject var router: ApplicationCoordinator
    @ObservedObject var viewModel: LookUpAddViewModel
    
    var body: some View {
        Text("Look Up!")
    }
}

#Preview {
    LookUpAddView(viewModel: LookUpAddViewModel())
}
