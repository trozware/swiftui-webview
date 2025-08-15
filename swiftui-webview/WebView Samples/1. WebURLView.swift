// This sample app accompanies my article on SwiftUI's WebView
// https://troz.net/post/2025/swiftui-webview/
//
// Sarah Reichelt, August 2025

import SwiftUI
import WebKit

struct WebURLView: View {
  @State private var toggle = false

  var body: some View {
    VStack {
      Text("This is the simplest way to use a WebView. Use the toolbar button to toggle between two URLs.")
        .padding()
        .foregroundStyle(.purple)
        .multilineTextAlignment(.center)

      WebView(
        url: toggle
          ? URL(string: "https://www.webkit.org")
          : URL(string: "https://www.swift.org")
      )
    }
    .toolbar {
      Button("Toggle URL", systemImage: "safari") {
        toggle.toggle()
      }
    }
  }
}

#Preview {
  WebURLView()
}
