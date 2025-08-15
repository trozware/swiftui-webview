// This sample app accompanies my article on SwiftUI's WebView
// https://troz.net/post/2025/swiftui-webview/
//
// Sarah Reichelt, August 2025

import SwiftUI
import WebKit

struct CustomScheme: View {
  @State private var page = WebPage()
  @State private var findNavigatorIsPresented = false

  var body: some View {
    VStack {
      if page.url == nil {
        Text(
          "Use the toolbar buttons to load local pages using a custom scheme, or for in-page find. Scroll to the end of each page for an external link that opens in your browser."
        )
        .padding()
        .foregroundStyle(.purple)
      }

      WebView(page)
        .scrollBounceBehavior(.basedOnSize, axes: [.horizontal])
        .replaceDisabled(true)  // doesn't work yet
        .findNavigator(isPresented: $findNavigatorIsPresented)
        .navigationTitle(page.title)
        .onAppear {
          let scheme = URLScheme("manpage")!
          let handler = ManPageSchemeHandler()
          var configuration = WebPage.Configuration()
          configuration.urlSchemeHandlers[scheme] = handler
          let navigationDecider = NavigationDecider()

          page = WebPage(
            configuration: configuration,
            navigationDecider: navigationDecider
          )
        }
    }
    .toolbar {
      ToolbarItemGroup {
        Button("cal", systemImage: "calendar") {
          loadLocalPage("cal")
        }
        Button("ls", systemImage: "questionmark.folder") {
          loadLocalPage("ls")
        }
      }

      ToolbarSpacer()

      ToolbarItem {
        Button("Find", systemImage: "magnifyingglass") {
          findNavigatorIsPresented.toggle()
        }
      }
    }
  }

  func loadLocalPage(_ name: String) {
    Task {
      let url = URL(string: "manpage://\(name).html")
      page.load(URLRequest(url: url!))
    }
  }
}

#Preview {
  CustomScheme()
}

struct ManPageSchemeHandler: URLSchemeHandler {
  func reply(
    for request: URLRequest
  ) -> some AsyncSequence<URLSchemeTaskResult, any Error> {
    AsyncThrowingStream { continuation in
      guard
        let bundleURL = Bundle.main.url(forResource: request.url?.host, withExtension: nil),
        let pageData = try? Data(contentsOf: bundleURL)
      else {
        continuation.finish(throwing: URLError(.badURL))
        return
      }
      let response = URLResponse(
        url: request.url!,
        mimeType: "text/html",
        expectedContentLength: pageData.count,
        textEncodingName: "utf-8"
      )
      continuation.yield(.response(response))
      continuation.yield(.data(pageData))
      continuation.finish()
    }
  }
}

class NavigationDecider: WebPage.NavigationDeciding {
  func decidePolicy(
    for action: WebPage.NavigationAction, preferences: inout WebPage.NavigationPreferences
  ) async -> WKNavigationActionPolicy {
    guard let url = action.request.url else {
      print("No URL supplied for decision")
      return .cancel
    }

    if url.scheme == "manpage" {
      print("Opening man page for \(url)")
      return .allow
    }

    print("Opening \(url) in default browser")
    NSWorkspace.shared.open(url)
    return .cancel
  }
}
