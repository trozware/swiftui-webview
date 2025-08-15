// This sample app accompanies my article on SwiftUI's WebView
// https://troz.net/post/2025/swiftui-webview/
//
// Sarah Reichelt, August 2025

import SwiftUI

struct ContentView: View {
  var body: some View {
    TabView {
      Tab("Web URL", systemImage: "wave.3.up") {
        WebURLView()
      }
      Tab("Web Page", systemImage: "richtext.page") {
        WebPageLoad()
      }
      Tab("Track Load", systemImage: "progress.indicator") {
        TrackLoad()
      }
      Tab("Custom Scheme", systemImage: "questionmark.diamond") {
        CustomScheme()
      }
      Tab("JavaScripting", systemImage: "applescript") {
        JavaScripting()
      }
      Tab("Browser Demo", systemImage: "safari") {
        Browser()
      }
    }
    .tabViewStyle(.sidebarAdaptable)
    .frame(minWidth: 700, minHeight: 350)
  }
}

#Preview {
  ContentView()
}
