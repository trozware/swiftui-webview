// This sample app accompanies my article on SwiftUI's WebView
// https://troz.net/post/2025/swiftui-webview/
//
// Sarah Reichelt, August 2025

import SwiftUI
import WebKit

struct WebPageLoad: View {
  @State private var page = WebPage()

  var body: some View {
    VStack {
      Text(
        "This uses a WebPage and a WebView. Use the toolbar buttons to load either an online site or local HTML."
      )
      .padding()
      .foregroundStyle(.purple)
      .multilineTextAlignment(.center)

      WebView(page)
        .navigationTitle(page.title)
    }
    .toolbar {
      Button("Online", systemImage: "network") {
        var request = URLRequest(url: URL(string: "https://troz.net")!)
        request.attribution = .user
        page.load(request)
      }
      Button("Local", systemImage: "document") {
        // page.load(html: html, baseURL: URL(string: "about:blank")!)
        page.load(html: html, baseURL: Bundle.main.resourceURL!)
      }
    }
  }

  let html = """
    <!DOCTYPE html>
    <html lang=\"en\">
      <head>
        <title>Local HTML</title>
        <link href="github.css" rel="stylesheet">
      </head>
      <body>
        <h1>Welcome to the Local Page</h1>
        <h2>This is a demonstration</h2>
        <p>The HTML here is a String property that's loaded into a `WebPage`.</p>
        <ul>
          <li>Item 1</li>
          <li>Item 2</li>
          <li>Item 3</li>
        </ul>
        <pre>This is loading a stylesheet from the app bundle.</pre>
      </body>
    </html>
    """
}

#Preview {
  WebPageLoad()
}
