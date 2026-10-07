// Browse Facet Scope - Appends collection ID to facet URLs when on browse pages
// Also controls visibility of the "Collection" (set_spec) search field

class BrowseFacetScope {
  constructor() {
    this.cache = {}
    this.init()
  }

  init() {
    const pathname = window.location.pathname
    const pathMatch = pathname.match(/\/browse\/([^/]+)$/)
    
    if (pathMatch) {
      this.collectionId = pathMatch[1]
      this.isCollectionBrowsePage = true
      console.log('[BrowseFacetScope] Initialized with collection ID:', this.collectionId)

      this.preModifyFacetLinks()
      document.addEventListener("click", (event) => this.handleLinkClick(event), true)
      this.enableSetSpecSearchField()
      this.interceptSearchFormSubmission()
      this.updateSearchTitle()
    } else if (pathname.includes('/browse') || pathname.includes('/catalog')) {
      if (pathname.includes('/browse')) {
        this.isBrowseListPage = true
        console.log('[BrowseFacetScope] On browse list page')
      } else {
        this.isCatalogPage = true
        console.log('[BrowseFacetScope] On catalog search page')
        this.cleanPageTitle()
      }
      
      this.disableSetSpecSearchField()
      this.updateSearchTitle()
    } else {
      console.log('[BrowseFacetScope] On exhibit home page')
      this.disableSetSpecSearchField()
      this.updateSearchTitle()
    }
  }

  preModifyFacetLinks() {
    // Find all facet links and modify them before any clicks happen
    document.querySelectorAll("a[href*='/catalog?'][href*='f%5B']:not([href*='set_spec'])").forEach(link => {
      const href = link.getAttribute("href")
      const newHref = href + "&f%5Bset_spec%5D%5B%5D=" + encodeURIComponent(this.collectionId)
      link.setAttribute("href", newHref)
      console.log('[BrowseFacetScope] Pre-modified link:', { facet: link.textContent.substring(0, 30), href: newHref })
    })
  }

  handleLinkClick(event) {
    const link = event.target.closest("a[href*='/catalog?'][href*='f%5B']:not([href*='set_spec'])")
    if (!link) return

    const href = link.getAttribute("href")
    const newHref = href + "&f%5Bset_spec%5D%5B%5D=" + encodeURIComponent(this.collectionId)
    link.setAttribute("href", newHref)
    
    console.log('[BrowseFacetScope] Modified link href on click:', { original: href, modified: newHref })
  }

  enableSetSpecSearchField() {
    const searchFieldSelect = this.getSearchFieldSelect()
    if (!searchFieldSelect) {
      console.log('[BrowseFacetScope] Search field select not found yet')
      return
    }

    const setSpecOption = Array.from(searchFieldSelect.options).find(opt => opt.value === 'set_spec')
    if (setSpecOption) {
      if (setSpecOption.hasAttribute('disabled')) {
        setSpecOption.removeAttribute('disabled')
        console.log('[BrowseFacetScope] Enabled "Collection" search field option')
      }
    } else {
      const newOption = document.createElement('option')
      newOption.value = 'set_spec'
      newOption.textContent = 'Collection'
      searchFieldSelect.appendChild(newOption)
      console.log('[BrowseFacetScope] Created and added "Collection" search field option')
    }

    searchFieldSelect.value = 'set_spec'
    console.log('[BrowseFacetScope] Set "Collection" as default search field')
  }

  disableSetSpecSearchField() {
    const searchFieldSelect = this.getSearchFieldSelect()
    if (!searchFieldSelect) {
      console.log('[BrowseFacetScope] Search field select not found')
      return
    }

    const setSpecOption = Array.from(searchFieldSelect.options).find(opt => opt.value === 'set_spec')
    if (setSpecOption) {
      setSpecOption.setAttribute('disabled', 'disabled')
      console.log('[BrowseFacetScope] Disabled "Collection" search field option')
    }
  }

  getSearchFieldSelect() {
    return this.cache.searchFieldSelect ||= document.querySelector('select[name="search_field"], select#search_field')
  }

  getSearchForm() {
    return this.cache.searchForm ||= document.querySelector('form.search-query-form')
  }

  interceptSearchFormSubmission() {
    // Find the main search form (should be the first one with class search-query-form)
    const searchForm = document.querySelector('form.search-query-form')
    
    if (!searchForm) {
      console.log('[BrowseFacetScope] Search form not found, retrying...')
      // Retry after a short delay
      setTimeout(() => this.interceptSearchFormSubmission(), 500)
      return
    }

    // Get references to form elements
    const searchFieldSelect = searchForm.querySelector('select[name="search_field"]')
    const queryInput = searchForm.querySelector('input[name="q"]')
    
    if (!searchFieldSelect || !queryInput) {
      console.log('[BrowseFacetScope] Search form elements not found')
      return
    }

    searchForm.addEventListener('submit', (event) => {
      if (searchFieldSelect.value !== 'set_spec') {
        // Not searching with Collection field - allow default behavior
        return
      }

      // User is searching with the "Collection" field
      event.preventDefault()
      
      const query = queryInput.value
      
      // Extract exhibit ID from the pathname (e.g., /spotlight/scrb/browse/p16022coll208)
      const pathParts = window.location.pathname.split('/')
      const exhibitId = pathParts[2] // /spotlight/:exhibit_id/browse/:collection_id
      
      // Build the catalog URL with query and set_spec filter
      const currentUrl = new URL(window.location.href)
      let catalogUrl = `${currentUrl.origin}/spotlight/${exhibitId}/catalog`
      
      const params = new URLSearchParams()
      params.set('q', query)
      params.set('exhibit_id', exhibitId)
      
      // Add the set_spec filter parameter (f[set_spec][]=<collection_id>)
      catalogUrl += `?${params.toString()}&f%5Bset_spec%5D%5B%5D=${encodeURIComponent(this.collectionId)}`
      
      console.log('[BrowseFacetScope] Intercepted Collection search:', { 
        query, 
        exhibitId,
        collectionId: this.collectionId, 
        url: catalogUrl 
      })
      
      // Navigate to the search results
      window.location.href = catalogUrl
    })

    console.log('[BrowseFacetScope] Installed search form submission interceptor')
  }

  updateSearchTitle() {
    // Find the "Start your search" heading
    const searchHeading = Array.from(document.querySelectorAll('h3, h2, h1')).find(h => h.textContent.includes('Start your search'))
    
    if (!searchHeading) {
      console.log('[BrowseFacetScope] Search heading not found')
      return
    }

    let newTitle = 'Start your search'

    if (this.collectionId) {
      // We're on a specific collection browse page - get the collection title
      // Look for the main heading on the page (usually the collection name)
      const mainHeading = document.querySelector('h1')
      if (mainHeading) {
        // Extract just the title part (before any item counts)
        const collectionTitle = mainHeading.textContent.split('\n')[0].trim()
        newTitle = `Search ${collectionTitle}`
        console.log('[BrowseFacetScope] Updated title for collection:', newTitle)
      }
    } else {
      // We're on either:
      // 1. The browse collections list page (/spotlight/exhibit/browse)
      // 2. The catalog search results page (/spotlight/exhibit/catalog)
      // 3. The exhibit home page (/spotlight/exhibit)
      // All should show the exhibit title
      
      // Try multiple selectors to find the exhibit title
      const navbarBrand = document.querySelector('.navbar-brand')
      let exhibitTitle = navbarBrand?.textContent?.trim()
      
      if (exhibitTitle) {
        newTitle = `Search ${exhibitTitle}`
        console.log('[BrowseFacetScope] Updated title from navbar-brand:', newTitle)
      } else {
        // Fallback: try to get from page title, but extract just the exhibit name
        const pageTitle = document.title.split(' - ')[0].trim()
        // Remove "Browse | " prefix if present
        const cleanTitle = pageTitle.replace(/^Browse\s*\|\s*/, '').trim()
        
        if (cleanTitle && cleanTitle !== 'UMedia' && cleanTitle !== 'Browse') {
          newTitle = `Search ${cleanTitle}`
          console.log('[BrowseFacetScope] Updated title (from page title fallback):', newTitle)
        }
      }
    }

    searchHeading.textContent = newTitle
    console.log('[BrowseFacetScope] Updated search title to:', newTitle)
  }

  cleanPageTitle() {
    // On catalog pages, remove facet details from the browser page title
    // Keep exhibit name + "- UMedia Search Results" format
    if (this.isCatalogPage) {
      const currentTitle = document.title
      // Try to get exhibit name from navbar first
      const navbarBrand = document.querySelector('.navbar-brand')
      let exhibitName = navbarBrand?.textContent?.trim()
      
      // If navbar brand is empty, extract from document.title using regex
      if (!exhibitName) {
        const match = currentTitle.match(/(?:.*\s*-\s*)([^-]+)\s*-\s*UMedia Search Results$/)
        if (match && match[1]) {
          exhibitName = match[1].trim()
        }
      }
      
      if (exhibitName) {
        document.title = `${exhibitName} - UMedia Search Results`
        console.log('[BrowseFacetScope] Cleaned page title to:', document.title)
      }
    }
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

