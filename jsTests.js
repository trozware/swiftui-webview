const listH = () => {
  const headers = document.querySelectorAll("h3")
  return [...headers].map(header => ({
    id: header.textContent.replaceAll(" ", "-").toLowerCase(),
    title: header.textContent.replaceAll("\n", "").trim()
  }))
}

console.log(listH())

const sectionOffsets = (sectionID, sectionTitle) => {
  const element = document.getElementById(sectionID)
  if (element) {
    return element.offsetTop
  }

  const headers = document.querySelectorAll("h3")
  const matchingHeader = [...headers].find(header => header.textContent.replaceAll("\n", "").trim() === sectionTitle)
  if (matchingHeader) {
    return matchingHeader.offsetTop
  }

  return undefined
}

console.log(sectionOffsets("web-view", "Web view"))


// given a scroll position, find the section that is currently visible
const findVisibleSection = (scrollPosition) => {
  const headers = [...document.querySelectorAll("h3")]
  console.log(headers)

  for (let i = 1; i < headers.length; i++) {
    const prevHeader = headers[i - 1]
    const currHeader = headers[i]
    console.log(prevHeader, currHeader)
    const prevHeaderTop = prevHeader.offsetTop
    const currHeaderTop = currHeader.offsetTop
    console.log(prevHeaderTop, currHeaderTop)

    if (scrollPosition >= headers[i - 1].offsetTop && scrollPosition <= headers[i].offsetTop) {
      return headers[i - 1].textContent
    }
  }
  return undefined
}

console.log(findVisibleSection(1000))

const listAllScrolls = () => {
  const headers = [...document.querySelectorAll("h3")]
  return headers.map(header => ({
    id: header.textContent.replaceAll(" ", "-").toLowerCase(),
    offset: header.offsetTop
  }))
}

console.log(listAllScrolls())


const findScroll = (scrollPosition) => {
  const headers = [...document.querySelectorAll("h3")]
  const scrolls = headers.map(header => ({
    id: header.textContent.replaceAll(" ", "-").toLowerCase(),
    offset: header.offsetTop
  }))

  if (scrollPosition < scrolls[0].offset) {
    return undefined
  }

  for (let i = 1; i < scrolls.length; i++) {
    if (scrollPosition >= scrolls[i - 1].offset && scrollPosition < scrolls[i].offset) {
      return scrolls[i - 1].id
    }
  }

  return undefined
}

console.log(findScroll(1000))

// detect when scroll is at the end of the page
const isAtEndOfPage = () => {
  const scrollPosition = window.scrollY
  const windowHeight = window.innerHeight
  const documentHeight = document.documentElement.scrollHeight
  return scrollPosition + windowHeight >= documentHeight
}

console.log(isAtEndOfPage())