// This sample app accompanies my article on SwiftUI's WebView
// https://troz.net/post/2025/swiftui-webview/
//
// Sarah Reichelt, August 2025

import SwiftUI
import WebKit

struct JavaScripting: View {
  @State private var page = WebPage()
  @State private var sections: [SectionLink] = []
  @State private var selectedSectionID: SectionLink.ID?
  @State private var currentScroll = ScrollPosition()

  let pageAddress = "https://troz.net/post/2025/swiftui-mac-2025/"
  let headerElement = "h3"

  var body: some View {
    VStack {
      Text(
        "When the page has loaded, the WebView uses JavaScript to find all the section headers for use in the toolbar menu."
      )
      .foregroundStyle(.purple)
      .multilineTextAlignment(.center)
      .padding()

      WebView(page)
        .scrollBounceBehavior(.basedOnSize, axes: [.horizontal])
        .webViewScrollPosition($currentScroll)
        .webViewOnScrollGeometryChange(for: CGFloat.self, of: \.contentOffset.y) { _, newValue in
          adjustSelectionTo(scrollPosition: newValue)
        }
    }
    .navigationTitle(page.title)
    .onAppear(perform: loadPage)
    .toolbar {
      ToolbarItem {
        if !sections.isEmpty {
          sectionsMenu
        }
      }
    }
  }

  var sectionsMenu: some View {
    Menu("Sections") {
      ForEach(sections) { section in
        Button {
          jumpToSection(id: section.id)
        } label: {
          if section.id == selectedSectionID {
            Label(section.title, systemImage: "checkmark")
          } else {
            Text("\(section.title)")
          }
        }
      }
    }
  }

  func loadPage() {
    Task {
      sections = []
      let url = URL(string: pageAddress)!
      page.load(URLRequest(url: url))

      while page.isLoading {
        try? await Task.sleep(for: .milliseconds(100))
      }
      listHeaders()
    }
  }
}

#Preview {
  JavaScripting()
}

extension JavaScripting {
  func listHeaders() {
    let js = """
      const headers = document.querySelectorAll("\(headerElement)")
      return [...headers].map(header => ({
        id: header.textContent.replaceAll(" ", "-").toLowerCase(),
        title: header.textContent
      }))
      """

    Task {
      do {
        let jsResult = try await page.callJavaScript(js)
        if let headers = jsResult as? [[String: Any]] {
          let pageSections = headers.map {
            SectionLink(jsEntry: $0)
          }
          await MainActor.run {
            sections = pageSections
          }
        }
      } catch {
        print(error)
      }
    }
  }

  func jumpToSection(id: String) {
    let section = sections.first(where: { $0.id == id }) ?? sections.first!

    let js = """
        const headers = document.querySelectorAll("\(headerElement)")
        const matchingHeader = [...headers].find(header => header.textContent === sectionTitle)
        if (matchingHeader) {
          return matchingHeader.offsetTop
        }
        return undefined
      """

    Task {
      do {
        let result = try await page.callJavaScript(
          js,
          arguments: ["sectionTitle": section.title]
        )
        guard let offset = result as? CGFloat else {
          return
        }
        await MainActor.run {
          withAnimation(.easeInOut(duration: 0.25)) {
            currentScroll.scrollTo(y: offset)
          }
        }
      } catch {
        print("Error computing scroll offset")
        print(error)
      }
    }
  }

  func adjustSelectionTo(scrollPosition: CGFloat) {
    let js = """
        const headers = [...document.querySelectorAll("h3")]
        const scrolls = headers.map(header => ({
          id: header.textContent.replaceAll(" ", "-").toLowerCase(),
          offset: header.offsetTop
        }))

        if (scrollPosition < scrolls[0].offsetTop) {
          return undefined
        }
        
        const windowScrollPosition = window.scrollY
        const windowHeight = window.innerHeight
        const documentHeight = document.documentElement.scrollHeight
        const isScrolledToEnd = windowScrollPosition + windowHeight >= documentHeight - 40
        if (isScrolledToEnd) {
          return scrolls[scrolls.length - 1].id
        }

        for (let i = 1; i < scrolls.length; i++) {
          if (scrollPosition >= scrolls[i - 1].offset && scrollPosition < scrolls[i].offset) {
            return scrolls[i - 1].id
          }
        }
        return undefined
      """

    Task {
      do {
        let result = try await page.callJavaScript(
          js,
          arguments: ["scrollPosition": scrollPosition]
        )
        guard let sectionID = result as? String else {
          return
        }
        selectedSectionID = sectionID
      } catch {
        print("Error computing scroll offset")
        print(error)
      }
    }
  }
}

struct SectionLink: Identifiable {
  let id: String
  let title: String

  init(jsEntry: [String: Any]) {
    id = jsEntry["id"] as! String
    let titleEntry = jsEntry["title"] as! String
    title =
      titleEntry
      .replacingOccurrences(of: "\n", with: "")
      .replacingOccurrences(of: "  ", with: " ")
      .trimmingCharacters(in: .whitespacesAndNewlines)
  }
}
