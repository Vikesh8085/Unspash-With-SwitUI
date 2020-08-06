//
//  ContentView.swift
//  Unspash With SwitUI
//
//  Created by Vikesh Prasad on 06/08/20.
//  Copyright © 2020 Mobiotics. All rights reserved.
//

import SwiftUI

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
    var body: some View {
        VStack(){
             Text("Hello, World!")
        }
    }
}
