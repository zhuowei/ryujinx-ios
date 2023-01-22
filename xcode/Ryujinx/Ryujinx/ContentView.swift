//
//  ContentView.swift
//  Ryujinx
//
//  Created by Zhuowei Zhang on 2023-01-22.
//

import RyujinxKit
import SwiftUI

struct ContentView: View {
  var body: some View {
    VStack {
      Image(systemName: "globe")
        .imageScale(.large)
        .foregroundColor(.accentColor)
      Text("Hello, world!")
      Button(action: buttonClicked) {
        Text("Go!")
      }.padding(8)
    }
    .padding()
  }
}

func buttonClicked() {
  // boot up CoreCLR.
  // we use the old embedding API since it's less files to copy
  startCoreClr()
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
