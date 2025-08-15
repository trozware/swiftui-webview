// This sample app accompanies my article on SwiftUI's WebView
// https://troz.net/post/2025/swiftui-webview/
//
// Sarah Reichelt, August 2025

import SwiftUI
import WebKit
import OSLog

struct TrackLoad: View {
  @State private var page = WebPage()
  @State private var webAddress = ""
  @State private var statusText =
    "Use the toolbar buttons to load different sites and read the navigation events here."

  let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "TrackLoad")

  var body: some View {
    ZStack {
      VStack {
        WebView(page)
          .navigationTitle(page.title)
          .navigationSubtitle(page.url?.absoluteString ?? "")

        ScrollView {
          Text(statusText)
            .frame(
              maxWidth: .infinity,
              maxHeight: .infinity,
              alignment: .topLeading
            )
            .padding()
            .multilineTextAlignment(.leading)
            .frame(height: 100)
        }
        .background(.yellow.opacity(0.1))
        .frame(height: 100)
      }

      if page.isLoading {
        // Basic spinner
        ProgressView()

        // Progress bar
        //  VStack {
        //    ProgressView(value: page.estimatedProgress)
        //      .padding(.horizontal)
        //    Spacer()
        //  }
      }
    }
    .task {
      await startObservingEvents()
    }
    .toolbar {
      Button("Apple", systemImage: "safari") {
        webAddress = "https://apple.com"
        let request = URLRequest(url: URL(string: webAddress)!)
        page.load(request)
      }
      Button("Troz", systemImage: "person") {
        webAddress = "https://troz.net"
        let request = URLRequest(url: URL(string: webAddress)!)
        page.load(request)
      }
    }
  }

  func startObservingEvents() async {
    let eventStream = Observations { page.navigations }

    for await observation in eventStream {
      do {
        for try await event in observation {
          switch event {
          case .startedProvisionalNavigation:
            statusText =
              "Started provisional navigation for \(page.url?.absoluteString ?? "unknown URL")\n"
            logger.info("Started provisional navigation")
          case .receivedServerRedirect:
            statusText += "Received server redirect\n"
            logger.info("Received server redirect")
          case .committed:
            statusText += "Committed\n"
            logger.info("Committed")
          case .finished:
            statusText += "Finished\n"
            logger.info("Finished")
          @unknown default:
            statusText += "Unknown navigation event\n"
            logger.fault("Unknown event")
            print(event)
          }
        }
      } catch WebPage.NavigationError.failedProvisionalNavigation(let error) {
        statusText += "Error: Failed provisional navigation: \(error.localizedDescription)\n"
        logger.fault(
          "Navigation error: failed provisional navigation: \(error.localizedDescription)")
      } catch WebPage.NavigationError.pageClosed {
        statusText += "Error: Page closed\n"
        logger.fault("Navigation error: page closed")
      } catch WebPage.NavigationError.webContentProcessTerminated {
        statusText += "Error: Web content process terminated\n"
        logger.fault("Navigation error: web content process terminated")
      } catch {
        statusText += "Unknown error: \(error.localizedDescription)\n"
        logger.fault("Unknown error: \(error.localizedDescription)")
      }
    }
  }
}

#Preview {
  TrackLoad()
}
