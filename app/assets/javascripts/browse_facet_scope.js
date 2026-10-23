// Browse Facet Scope - Appends collection ID to facet URLs when on browse pages
// Also controls visibility of the "Collection" (set_spec) search field
console.log('[BrowseFacetScope] Script loaded v2');

class BrowseFacetScope {
  constructor() {
    this.cache = {}
    this.exhibitId = this.extractExhibitId()
    this.init()
  }

  init() {
    try {
      const pathname = window.location.pathname
      const urlParams = new URLSearchParams(window.location.search)
      const pathMatch = pathname.match(/\/browse\/([^/]+)$/)
      
      if (pathMatch) {
        this.collectionId = pathMatch[1]
        this.isCollectionBrowsePage = true
        this.activateCollectionScope(this.collectionId)
        console.log('[BrowseFacetScope] Initialized with collection ID:', this.collectionId)

        this.preModifyFacetLinks()
        document.addEventListener("click", (event) => this.handleLinkClick(event), true)
        this.enableSetSpecSearchField()
        this.interceptSearchFormSubmission()
        this.updateSearchTitle()
      } else if (pathname.includes('/browse') || pathname.includes('/catalog')) {
        if (pathname.includes('/browse')) {
          this.isBrowseListPage = true
          this.clearCollectionScope()
          console.log('[BrowseFacetScope] On browse list page')
        } else {
          // Check if this is an item detail page (e.g., /catalog/p16022coll99:36 or /spotlight/tc/catalog/p16022coll99:36)
          const itemMatch = pathname.match(/\/catalog\/([^/:]+):/)
          if (itemMatch) {
            this.isItemDetailPage = true
            this.collectionId = itemMatch[1]
            console.log('[BrowseFacetScope] On item detail page with collection ID:', this.collectionId)

            if (this.isCollectionScopeActive()) {
              document.addEventListener("click", (event) => this.handleItemPageFacetClick(event), true)
              this.transformItemPageFacetLinks()
            } else {
              console.log('[BrowseFacetScope] Item page not in collection-scope journey; skipping collection facet propagation')
            }

            // Item pages should provide collection-scoped search UX.
            this.enableSetSpecSearchField()
            this.interceptSearchFormSubmission()
          } else {
            this.isCatalogPage = true
            console.log('[BrowseFacetScope] On catalog search page')
            this.cleanPageTitle()

            const hasCollectionFilter = urlParams.getAll('f[collection_name_s][]').length > 0
            const setSpecs = urlParams.getAll('f[set_spec][]')
            const hasSetSpec = setSpecs.length > 0

            if (hasCollectionFilter || hasSetSpec) {
              this.activateCollectionScope(this.getCollectionScopeId() || this.collectionId)
            } else {
              this.clearCollectionScope()
            }
            
            // Check if current page has set_spec filter and modify facet links
            if (setSpecs && setSpecs.length > 0) {
              console.log('[BrowseFacetScope] Found set_spec filters on catalog page, setting up facet link transformation')
              this.setSpecOnCatalogPage = setSpecs[0]
              document.addEventListener("click", (event) => this.handleCatalogPageFacetClick(event), true)
              this.transformCatalogPageFacetLinks()
            }
          }
        }
        
        if (!this.isCollectionBrowsePage && !this.isItemDetailPage) {
          this.disableSetSpecSearchField()
        }
        this.updateSearchTitle()
        this.modifySpotlightStartOverLink()
        document.addEventListener("click", (event) => this.handleRemoveConstraintClick(event), true)
      } else {
        console.log('[BrowseFacetScope] On exhibit home page')
        this.clearCollectionScope()
        this.disableSetSpecSearchField()
        this.updateSearchTitle()
      }
    } catch (error) {
      console.error('[BrowseFacetScope] Error during initialization:', error);
    }
  }

  encodeFormParam(value) {
    // Encode parameter the same way as HTML forms (+ for spaces instead of %20)
    // This matches Blacklight's URL encoding style
    return encodeURIComponent(value).replace(/%20/g, '+')
  }

  extractExhibitId() {
    const match = window.location.pathname.match(/^\/spotlight\/([^/]+)/)
    return match ? match[1] : null
  }

  collectionScopeKey() {
    if (!this.exhibitId) return null
    return `browseFacetScope:${this.exhibitId}`
  }

  activateCollectionScope(collectionId) {
    const key = this.collectionScopeKey()
    if (!key) return

    try {
      if (collectionId) {
        sessionStorage.setItem(key, collectionId)
      } else if (!sessionStorage.getItem(key)) {
        sessionStorage.setItem(key, 'active')
      }
      console.log('[BrowseFacetScope] Activated collection-scope journey')
    } catch (error) {
      console.warn('[BrowseFacetScope] Could not persist collection scope:', error)
    }
  }

  clearCollectionScope() {
    const key = this.collectionScopeKey()
    if (!key) return

    try {
      sessionStorage.removeItem(key)
      console.log('[BrowseFacetScope] Cleared collection-scope journey')
    } catch (error) {
      console.warn('[BrowseFacetScope] Could not clear collection scope:', error)
    }
  }

  isCollectionScopeActive() {
    const key = this.collectionScopeKey()
    if (!key) return false

    try {
      return !!sessionStorage.getItem(key)
    } catch (error) {
      console.warn('[BrowseFacetScope] Could not read collection scope:', error)
      return false
    }
  }

  getCollectionScopeId() {
    const key = this.collectionScopeKey()
    if (!key) return null

    try {
      const value = sessionStorage.getItem(key)
      return value && value !== 'active' ? value : null
    } catch (error) {
      console.warn('[BrowseFacetScope] Could not read collection scope id:', error)
      return null
    }
  }

  async preModifyFacetLinks() {
    // Find all facet links and modify them before any clicks happen
    // Matches both /catalog? and /browse/...? links
    const collectionName = await this.getCollectionNameFromSetSpec(this.collectionId)
    
    document.querySelectorAll("a[href*='?'][href*='f%5B']:not([href*='collection_name_s'])").forEach(link => {
      const href = link.getAttribute("href")
      // Only modify links that are facet links (contain 'f%5B' and are to catalog or browse)
      if ((href.includes('/catalog?') || href.includes('/browse/')) && href.includes('f%5B')) {
        const newHref = href + "&f%5Bcollection_name_s%5D%5B%5D=" + this.encodeFormParam(collectionName)
        link.setAttribute("href", newHref)
        console.log('[BrowseFacetScope] Pre-modified link:', { facet: link.textContent.substring(0, 30), href: newHref })
      }
    })
  }

  async handleLinkClick(event) {
    // Only handle facet selection links, not remove constraint links (which have the "remove" class)
    const link = event.target.closest("a[href*='?'][href*='f%5B']:not([href*='collection_name_s']):not(.remove)")
    if (!link) return

    // Only modify links that are facet links (contain 'f%5B' and are to catalog or browse)
    const href = link.getAttribute("href")
    if (!((href.includes('/catalog?') || href.includes('/browse/')) && href.includes('f%5B'))) return

    const collectionName = await this.getCollectionNameFromSetSpec(this.collectionId)
    const newHref = href + "&f%5Bcollection_name_s%5D%5B%5D=" + this.encodeFormParam(collectionName)
    link.setAttribute("href", newHref)
    
    console.log('[BrowseFacetScope] Modified link href on click:', { original: href, modified: newHref })
  }

  enableSetSpecSearchField() {
    try {
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
    } catch (error) {
      console.error('[BrowseFacetScope] Error enabling set_spec search field:', error);
    }
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
    try {
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
        
        // Build the catalog URL with query and collection_name_s filter
        const currentUrl = new URL(window.location.href)
        let catalogUrl = `${currentUrl.origin}/spotlight/${exhibitId}/catalog`
        
        const params = new URLSearchParams()
        params.set('q', query)
        params.set('exhibit_id', exhibitId)
        
        // Fetch collection_name_s from Solr and add as facet parameter
        this.getCollectionNameFromSetSpec(this.collectionId).then(collectionName => {
          if (collectionName) {
            catalogUrl += `?${params.toString()}&f%5Bcollection_name_s%5D%5B%5D=${this.encodeFormParam(collectionName)}`
          } else {
            // Fallback to set_spec if collection_name_s is not found
            catalogUrl += `?${params.toString()}&f%5Bset_spec%5D%5B%5D=${encodeURIComponent(this.collectionId)}`
          }
          
          console.log('[BrowseFacetScope] Intercepted Collection search:', { 
            query, 
            exhibitId,
            collectionId: this.collectionId, 
            collectionName,
            url: catalogUrl 
          })
          
          // Navigate to the search results
          window.location.href = catalogUrl
        }).catch(error => {
          console.error('[BrowseFacetScope] Error in search form submission:', error)
          // Fallback to set_spec if there's an error
          catalogUrl += `?${params.toString()}&f%5Bset_spec%5D%5B%5D=${encodeURIComponent(this.collectionId)}`
          window.location.href = catalogUrl
        })
      })

      console.log('[BrowseFacetScope] Installed search form submission interceptor')
    } catch (error) {
      console.error('[BrowseFacetScope] Error setting up form submission interceptor:', error);
    }
  }

  async updateSearchTitle() {
    // Find the "Start your search" heading
    const searchHeading = Array.from(document.querySelectorAll('h3, h2, h1')).find(h => h.textContent.includes('Start your search'))
    
    if (!searchHeading) {
      console.log('[BrowseFacetScope] Search heading not found')
      return
    }

    let newTitle = 'Start your search'

    if (this.isItemDetailPage && this.collectionId) {
      // On item pages, show the collection name in the search heading.
      const collectionName = await this.getCollectionNameFromSetSpec(this.collectionId)
      if (collectionName) {
        newTitle = `Search ${collectionName}`
        console.log('[BrowseFacetScope] Updated title for item collection:', newTitle)
      }
    } else if (this.collectionId) {
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

  modifySpotlightStartOverLink() {
    // For Spotlight catalog pages, modify the "Start Over" link to clear facets
    // while staying on the catalog page, instead of going back to exhibit home
    const isSpotlightCatalog = window.location.pathname.match(/\/spotlight\/[^/]+\/catalog/)
    if (!isSpotlightCatalog) return

    // First, try to find and modify the link immediately
    this.findAndModifyStartOverLink()

    // NOTE: Disabling MutationObserver as it was causing issues with remove constraint links
    // The observer was continuously modifying links during Turbolinks navigation, causing race conditions
    // Blacklight already generates correct links, so we don't need continuous monitoring
    /*
    // Also watch for changes to the DOM in case the constraints component is rendered dynamically
    const observer = new MutationObserver(() => {
      this.findAndModifyStartOverLink()
    })

    observer.observe(document.body, {
      childList: true,
      subtree: true
    })
    */
  }

  findAndModifyStartOverLink() {
    // Find the "Start Over" link in the constraints component
    const allLinks = document.querySelectorAll('a')

    for (const link of allLinks) {
      if (link.textContent.trim() === 'Start Over') {
        // Always modify for Spotlight catalog pages to ensure correct query params
        const isSpotlightCatalog = window.location.pathname.match(/\/spotlight\/[^/]+\/catalog/)
        if (isSpotlightCatalog) {
          this.updateStartOverLink(link)
          break
        }
      }
    }
    
    // Also fix "Remove constraint" links (the X buttons on facets)
    this.fixRemoveConstraintLinks()
  }

  fixRemoveConstraintLinks() {
    // Ensure "remove constraint" links keep users on Spotlight catalog,
    // even when removing the final constraint.
    const pathMatch = window.location.pathname.match(/\/spotlight\/([^/]+)\/catalog/)
    if (!pathMatch) return

    const exhibitId = pathMatch[1]
    const selectors = [
      '.constraints-container a.remove',
      '.constraints a.remove',
      '.constraint a.remove',
      'a.remove'
    ]
    const allLinks = document.querySelectorAll(selectors.join(', '))

    for (const link of allLinks) {
      const href = link.getAttribute('href')
      if (!href) continue

      const newHref = this.normalizeSpotlightCatalogHref(href, exhibitId)
      if (newHref && newHref !== href) {
        link.setAttribute('href', newHref)
        console.log('[BrowseFacetScope] Normalized remove link:', { original: href, modified: newHref })
      }
    }
  }

  normalizeSpotlightCatalogHref(href, exhibitId) {
    try {
      const url = new URL(href, window.location.origin)
      const exhibitRoot = `/spotlight/${exhibitId}`
      const catalogPath = `${exhibitRoot}/catalog`

      // Only rewrite links within the current exhibit scope.
      if (!(url.pathname === exhibitRoot || url.pathname.startsWith(`${exhibitRoot}/`))) {
        return null
      }

      // If link points to exhibit home (or browse), force catalog endpoint.
      if (url.pathname === exhibitRoot || url.pathname === `${exhibitRoot}/browse`) {
        url.pathname = catalogPath
      }

      // Guarantee core params used by exhibit catalog search state.
      if (!url.searchParams.has('exhibit_id')) {
        url.searchParams.set('exhibit_id', exhibitId)
      }
      if (!url.searchParams.has('search_field')) {
        url.searchParams.set('search_field', 'all_fields')
      }
      if (!url.searchParams.has('q')) {
        url.searchParams.set('q', '')
      }

      return `${url.pathname}?${url.searchParams.toString()}`
    } catch (error) {
      console.warn('[BrowseFacetScope] Could not normalize remove link:', href, error)
      return null
    }
  }

  updateStartOverLink(link) {
    // Extract exhibit_id from pathname (e.g., /spotlight/ihrca/catalog -> ihrca)
    const pathMatch = window.location.pathname.match(/\/spotlight\/([^/]+)\/catalog/)
    if (!pathMatch) return
    
    const exhibitId = pathMatch[1]
    
    // Always direct to a clean catalog page
    const newUrl = `/spotlight/${exhibitId}/catalog?exhibit_id=${exhibitId}&q=&search_field=all_fields`
    
    link.setAttribute('href', newUrl)
  }

  handleRemoveConstraintClick(event) {
    const pathMatch = window.location.pathname.match(/\/spotlight\/([^/]+)\/catalog/)
    if (!pathMatch) return

    const link = event.target.closest('a.remove')
    if (!link) return

    const href = link.getAttribute('href')
    if (!href) return

    const exhibitId = pathMatch[1]
    const newHref = this.normalizeSpotlightCatalogHref(href, exhibitId)
    if (newHref && newHref !== href) {
      link.setAttribute('href', newHref)
      console.log('[BrowseFacetScope] Normalized remove link on click:', { original: href, modified: newHref })
    }
  }

  async getCollectionNameFromSetSpec(setSpec) {
    // Check cache first
    if (this.cache[setSpec]) {
      return this.cache[setSpec]
    }

    try {
      // Use the Rails endpoint to get the collection_name_s
      const response = await fetch(`/catalog/collection_name_from_set_spec?set_spec=${encodeURIComponent(setSpec)}`)
      const data = await response.json()
      const collectionName = data.collection_name_s
      
      if (collectionName) {
        this.cache[setSpec] = collectionName
        console.log('[BrowseFacetScope] Retrieved collection_name_s:', { setSpec, collectionName })
      }
      
      return collectionName
    } catch (error) {
      console.error('[BrowseFacetScope] Error querying for collection_name_s:', error)
      return null
    }
  }

  async transformCatalogPageFacetLinks() {
    // Modify facet links on catalog pages that have set_spec filters
    const collectionName = await this.getCollectionNameFromSetSpec(this.setSpecOnCatalogPage)
    
    if (!collectionName) {
      console.log('[BrowseFacetScope] Could not get collection_name_s for set_spec:', this.setSpecOnCatalogPage)
      return
    }

    document.querySelectorAll("a[href*='/catalog?'][href*='f%5B']:not([href*='collection_name_s']):not(.remove)").forEach(link => {
      let href = link.getAttribute("href")
      // Remove set_spec parameter if present
      href = href.replace(/&?f%5Bset_spec%5D%5B%5D=[^&]*/g, '')
      // Add collection_name_s parameter
      const separator = href.includes('?') ? '&' : '?'
      const newHref = href + separator + "f%5Bcollection_name_s%5D%5B%5D=" + this.encodeFormParam(collectionName)
      link.setAttribute("href", newHref)
      console.log('[BrowseFacetScope] Transformed catalog page facet link:', { original: href, modified: newHref })
    })
  }

  async handleCatalogPageFacetClick(event) {
    // Handle facet clicks on catalog pages with set_spec filters
    if (!window.location.pathname.match(/\/catalog$/)) return

    const link = event.target.closest("a[href*='/catalog?'][href*='f%5B']:not([href*='collection_name_s']):not(.remove)")
    if (!link) return

    const collectionName = await this.getCollectionNameFromSetSpec(this.setSpecOnCatalogPage)
    
    if (!collectionName) {
      console.log('[BrowseFacetScope] Could not get collection_name_s for set_spec:', this.setSpecOnCatalogPage)
      return
    }

    let href = link.getAttribute("href")
    // Remove set_spec parameter if present
    href = href.replace(/&?f%5Bset_spec%5D%5B%5D=[^&]*/g, '')
    // Add collection_name_s parameter
    const separator = href.includes('?') ? '&' : '?'
    const newHref = href + separator + "f%5Bcollection_name_s%5D%5B%5D=" + this.encodeFormParam(collectionName)
    link.setAttribute("href", newHref)
    
    console.log('[BrowseFacetScope] Transformed catalog page facet link on click:', { original: href, modified: newHref })
  }

  async transformItemPageFacetLinks() {
    // Modify facet links on item detail pages to include collection_name_s
    const collectionName = await this.getCollectionNameFromSetSpec(this.collectionId)
    
    if (!collectionName) {
      console.log('[BrowseFacetScope] Could not get collection_name_s for collection ID:', this.collectionId)
      return
    }

    document.querySelectorAll("a[href*='/catalog?'][href*='f%5B']:not([href*='collection_name_s']):not(.remove)").forEach(link => {
      let href = link.getAttribute("href")
      // Add collection_name_s parameter
      const separator = href.includes('?') ? '&' : '?'
      const newHref = href + separator + "f%5Bcollection_name_s%5D%5B%5D=" + this.encodeFormParam(collectionName)
      link.setAttribute("href", newHref)
      console.log('[BrowseFacetScope] Transformed item page facet link:', { original: href, modified: newHref })
    })
  }

  async handleItemPageFacetClick(event) {
    // Handle facet clicks on item detail pages
    if (!window.location.pathname.match(/\/catalog\/([^/:]+):/)) return

    const link = event.target.closest("a[href*='/catalog?'][href*='f%5B']:not([href*='collection_name_s']):not(.remove)")
    if (!link) return

    const collectionName = await this.getCollectionNameFromSetSpec(this.collectionId)
    
    if (!collectionName) {
      console.log('[BrowseFacetScope] Could not get collection_name_s for collection ID:', this.collectionId)
      return
    }

    let href = link.getAttribute("href")
    // Add collection_name_s parameter
    const separator = href.includes('?') ? '&' : '?'
    const newHref = href + separator + "f%5Bcollection_name_s%5D%5B%5D=" + this.encodeFormParam(collectionName)
    link.setAttribute("href", newHref)
    
    console.log('[BrowseFacetScope] Transformed item page facet link on click:', { original: href, modified: newHref })
  }



}

// Initialize on DOMContentLoaded
try {
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
} catch (error) {
  console.error('[BrowseFacetScope] Fatal error during initialization:', error);
}

