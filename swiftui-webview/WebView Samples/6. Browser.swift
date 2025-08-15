// This sample app accompanies my article on SwiftUI's WebView
// https://troz.net/post/2025/swiftui-webview/
//
// Sarah Reichelt, August 2025

import SwiftUI
import WebKit

struct Browser: View {
  @State private var page = WebPage()
  @State private var address = ""
  @State private var findNavigatorIsPresented = false

  @State private var reloadButtonTitle = "Reload"
  @State private var reloadButtonIcon = "arrow.clockwise.circle"
  @State private var reloadFromOrigin = false

  var body: some View {
    VStack {
      TextField("URL", text: $address, prompt: Text("Enter a URL and press Return…"))
        .autocorrectionDisabled(true)
        .textFieldStyle(.roundedBorder)
        .padding(6)
        .onSubmit {
          loadAddress()
        }

      ZStack {
        WebView(page)
          .scrollBounceBehavior(.basedOnSize, axes: [.horizontal])
          .replaceDisabled(true)  // doesn't work yet
          .findNavigator(isPresented: $findNavigatorIsPresented)

        if page.isLoading {
          ProgressView()
        }
      }
    }
    .navigationTitle(page.title.isEmpty ? "Web Browser" : page.title)
    .navigationSubtitle(page.url?.absoluteString ?? "")
    .toolbar {
      ToolbarItemGroup {
        Menu("Back") {
          ForEach(page.backForwardList.backList.reversed()) { item in
            Button(item.title ?? item.url.absoluteString) {
              page.load(item)
            }
          }
        } primaryAction: {
          goBack()
        }
        .id(page.isLoading)

        Menu("Forward") {
          ForEach(page.backForwardList.forwardList) { item in
            Button(item.title ?? item.url.absoluteString) {
              page.load(item)
            }
          }
        } primaryAction: {
          goForward()
        }
        .id(page.isLoading)

        Button(reloadButtonTitle, systemImage: reloadButtonIcon) {
          page.reload(fromOrigin: reloadFromOrigin)
        }
        .help(reloadButtonTitle)
        .disabled(page.url == nil)
        .onModifierKeysChanged(mask: .option, initial: false) { _, new in
          if new.isEmpty {
            reloadButtonTitle = "Reload"
            reloadButtonIcon = "arrow.clockwise.circle"
            reloadFromOrigin = false
          } else {
            reloadButtonTitle = "Reload from origin"
            reloadButtonIcon = "arrow.clockwise.circle.fill"
            reloadFromOrigin = true
          }
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

  func formatURL() -> URL? {
    if !address.hasPrefix("http") {
      address = "https://" + address
    }
    if let url = URL(string: address) {
      return url
    }
    return nil
  }

  func loadAddress() {
    if let url = formatURL() {
      page.load(url)
    }
  }

  func goBack() {
    if let backItem = page.backForwardList.backList.last {
      page.load(backItem)
    }
  }

  func goForward() {
    if let forwardItem = page.backForwardList.forwardList.first {
      page.load(forwardItem)
    }
  }
}

#Preview {
  Browser()
}
