// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.

import Rails from "@rails/ujs"
import Turbolinks from "turbolinks"
import * as ActiveStorage from "@rails/activestorage"
import "channels"

Rails.start()
Turbolinks.start()
ActiveStorage.start()

// Browse Facet Scope - Appends collection ID to facet URLs when on browse pages
class BrowseFacetScope {
  constructor() {
    this.init()
  }

  init() {
    // Extract collection ID from URL (e.g., /spotlight/tc/browse/p16022coll692)
    const pathMatch = window.location.pathname.match(/\/browse\/([^/]+)$/)
    if (!pathMatch) return

    this.collectionId = pathMatch[1]
    console.log('[BrowseFacetScope] Initialized with collection ID:', this.collectionId)

    // Pre-modify all existing facet links when page loads
    this.preModifyFacetLinks()

    // ALSO intercept future clicks in case links are added dynamically
    // Use CAPTURE phase to intercept BEFORE Turbolinks
    document.addEventListener("click", (event) => this.handleLinkClick(event), true)
  }

  preModifyFacetLinks() {
    // Find all facet links and modify them before any clicks happen
    const facetLinks = document.querySelectorAll("a[href*='/catalog?']")
    facetLinks.forEach((link) => {
      const href = link.getAttribute("href")
      if (!href || !href.includes("f%5B") || href.includes("set_spec")) return

      const newHref = href + "&f%5Bset_spec%5D%5B%5D=" + encodeURIComponent(this.collectionId)
      link.setAttribute("href", newHref)
      console.log('[BrowseFacetScope] Pre-modified link:', { facet: link.textContent.substring(0, 30), href: newHref })
    })
  }

  handleLinkClick(event) {
    const link = event.target.closest("a[href*='/catalog?']")
    if (!link) return

    const href = link.getAttribute("href")
    if (!href || !href.includes("f%5B")) return // Only modify facet links (those with f[ parameters)

    // Check if set_spec is already in the URL
    if (href.includes("set_spec")) return

    // Append set_spec parameter to the facet URL
    const newHref = href + "&f%5Bset_spec%5D%5B%5D=" + encodeURIComponent(this.collectionId)
    link.setAttribute("href", newHref)
    
    console.log('[BrowseFacetScope] Modified link href on click:', { original: href, modified: newHref })
  }
}

// Initialize on DOMContentLoaded
if (document.readyState === 'loading') {
  document.addEventListener("DOMContentLoaded", () => {
    new BrowseFacetScope()
  })
} else {
  // DOMContentLoaded has already fired
  new BrowseFacetScope()
}

// Also reinitialize on Turbolinks page load (for navigations within the app)
document.addEventListener("turbolinks:load", () => {
  new BrowseFacetScope()
})
