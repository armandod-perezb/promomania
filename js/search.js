// Search functionality

let searchResults = [];
let currentFilters = {};
let currentPage = 1;
const itemsPerPage = 12;

document.addEventListener('DOMContentLoaded', function() {
    if (document.getElementById('search-text')) {
        initializeSearch();
    }
});

function initializeSearch() {
    // Initialize search from URL parameters
    initializeFromURL();
    
    // Initialize search form
    initializeSearchForm();
    
    // Initialize filters
    initializeFilters();
    
    // Initialize sorting
    initializeSorting();
    
    // Perform initial search
    performSearch();
    
    console.log('Search initialized');
}

function initializeFromURL() {
    const urlParams = new URLSearchParams(window.location.search);
    
    // Set search text from URL
    const query = urlParams.get('q');
    if (query) {
        document.getElementById('search-text').value = query;
        currentFilters.query = query;
    }
    
    // Set category filter from URL
    const category = urlParams.get('category');
    if (category) {
        const categoryCheckbox = document.querySelector(`input[name="category"][value="${category}"]`);
        if (categoryCheckbox) {
            categoryCheckbox.checked = true;
            if (!currentFilters.categories) currentFilters.categories = [];
            currentFilters.categories.push(category);
        }
    }
}

function initializeSearchForm() {
    const searchForm = document.querySelector('.search-input-group');
    const searchInput = document.getElementById('search-text');
    const searchButton = document.getElementById('search-btn');
    
    searchButton.addEventListener('click', function() {
        const query = searchInput.value.trim();
        currentFilters.query = query;
        currentPage = 1;
        performSearch();
    });
    
    searchInput.addEventListener('keypress', function(e) {
        if (e.key === 'Enter') {
            e.preventDefault();
            searchButton.click();
        }
    });
}

function initializeFilters() {
    // Category filters
    const categoryCheckboxes = document.querySelectorAll('input[name="category"]');
    categoryCheckboxes.forEach(checkbox => {
        checkbox.addEventListener('change', function() {
            updateCategoryFilters();
            currentPage = 1;
            performSearch();
        });
    });
    
    // Supermarket filters
    const supermarketCheckboxes = document.querySelectorAll('input[name="supermarket"]');
    supermarketCheckboxes.forEach(checkbox => {
        checkbox.addEventListener('change', function() {
            updateSupermarketFilters();
            currentPage = 1;
            performSearch();
        });
    });
    
    // City filter
    const citySelect = document.getElementById('city-filter');
    citySelect.addEventListener('change', function() {
        currentFilters.city = this.value;
        currentPage = 1;
        performSearch();
    });
    
    // Discount range
    const discountRange = document.getElementById('discount-range');
    const discountValue = document.getElementById('discount-value');
    
    discountRange.addEventListener('input', function() {
        const value = this.value;
        discountValue.textContent = `${value}%`;
        currentFilters.minDiscount = parseInt(value);
        currentPage = 1;
        performSearch();
    });
    
    // Max price
    const maxPriceInput = document.getElementById('max-price');
    maxPriceInput.addEventListener('input', function() {
        currentFilters.maxPrice = parseFloat(this.value) || null;
        currentPage = 1;
        performSearch();
    });
    
    // Validation filters
    const validationCheckboxes = document.querySelectorAll('input[name="validation"]');
    validationCheckboxes.forEach(checkbox => {
        checkbox.addEventListener('change', function() {
            updateValidationFilters();
            currentPage = 1;
            performSearch();
        });
    });
    
    // Filter action buttons
    document.getElementById('apply-filters').addEventListener('click', function() {
        currentPage = 1;
        performSearch();
    });
    
    document.getElementById('clear-filters').addEventListener('click', clearAllFilters);
}

function initializeSorting() {
    const sortSelect = document.getElementById('sort-by');
    sortSelect.addEventListener('change', function() {
        currentFilters.sortBy = this.value;
        currentPage = 1;
        performSearch();
    });
}

function updateCategoryFilters() {
    const checked = Array.from(document.querySelectorAll('input[name="category"]:checked'))
        .map(cb => cb.value);
    currentFilters.categories = checked.length > 0 ? checked : null;
}

function updateSupermarketFilters() {
    const checked = Array.from(document.querySelectorAll('input[name="supermarket"]:checked'))
        .map(cb => cb.value);
    currentFilters.supermarkets = checked.length > 0 ? checked : null;
}

function updateValidationFilters() {
    const checked = Array.from(document.querySelectorAll('input[name="validation"]:checked'))
        .map(cb => cb.value);
    currentFilters.validation = checked.length > 0 ? checked : null;
}

function performSearch() {
    showLoading(true);
    
    // Simulate API delay
    setTimeout(() => {
        const allPromotions = window.PromotionsModule ? window.PromotionsModule.promotionsData : [];
        
        // Apply filters
        let filteredResults = filterPromotions(allPromotions, currentFilters);
        
        // Apply sorting
        filteredResults = sortPromotions(filteredResults, currentFilters.sortBy || 'relevance');
        
        // Store results
        searchResults = filteredResults;
        
        // Render results
        renderSearchResults();
        renderActiveFilters();
        renderPagination();
        
        showLoading(false);
        
    }, 500);
}

function filterPromotions(promotions, filters) {
    return promotions.filter(promotion => {
        // Text search
        if (filters.query) {
            const query = filters.query.toLowerCase();
            const searchableText = [
                promotion.productName,
                promotion.brand,
                promotion.description,
                window.PromotionsModule.getStoreName(promotion.supermarket),
                window.PromotionsModule.getCategoryName(promotion.category)
            ].join(' ').toLowerCase();
            
            if (!searchableText.includes(query)) {
                return false;
            }
        }
        
        // Category filter
        if (filters.categories && !filters.categories.includes(promotion.category)) {
            return false;
        }
        
        // Supermarket filter
        if (filters.supermarkets && !filters.supermarkets.includes(promotion.supermarket)) {
            return false;
        }
        
        // City filter
        if (filters.city && promotion.city !== filters.city) {
            return false;
        }
        
        // Minimum discount filter
        if (filters.minDiscount && promotion.discountPercentage < filters.minDiscount) {
            return false;
        }
        
        // Maximum price filter
        if (filters.maxPrice && promotion.promoPrice > filters.maxPrice) {
            return false;
        }
        
        // Validation filters
        if (filters.validation) {
            if (filters.validation.includes('verified') && !promotion.verified) {
                return false;
            }
            if (filters.validation.includes('with-photos') && (!promotion.images || promotion.images.length === 0)) {
                return false;
            }
            if (filters.validation.includes('high-rating') && promotion.rating < 4.0) {
                return false;
            }
        }
        
        return true;
    });
}

function sortPromotions(promotions, sortBy) {
    const sorted = [...promotions];
    
    switch (sortBy) {
        case 'discount-desc':
            return sorted.sort((a, b) => b.discountPercentage - a.discountPercentage);
        case 'discount-asc':
            return sorted.sort((a, b) => a.discountPercentage - b.discountPercentage);
        case 'price-asc':
            return sorted.sort((a, b) => a.promoPrice - b.promoPrice);
        case 'price-desc':
            return sorted.sort((a, b) => b.promoPrice - a.promoPrice);
        case 'newest':
            return sorted.sort((a, b) => new Date(b.created) - new Date(a.created));
        case 'rating':
            return sorted.sort((a, b) => b.rating - a.rating);
        case 'relevance':
        default:
            // For relevance, prioritize verified, high-rated, and recent promotions
            return sorted.sort((a, b) => {
                const aScore = calculateRelevanceScore(a, currentFilters.query);
                const bScore = calculateRelevanceScore(b, currentFilters.query);
                return bScore - aScore;
            });
    }
}

function calculateRelevanceScore(promotion, query) {
    let score = 0;
    
    // Verified promotions get bonus
    if (promotion.verified) score += 10;
    
    // High ratings get bonus
    score += promotion.rating * 2;
    
    // Recent promotions get bonus
    const daysSinceCreated = (Date.now() - new Date(promotion.created).getTime()) / (1000 * 60 * 60 * 24);
    score += Math.max(0, 7 - daysSinceCreated); // Bonus for promotions less than a week old
    
    // High discount gets bonus
    score += promotion.discountPercentage * 0.1;
    
    // Query match relevance
    if (query) {
        const queryLower = query.toLowerCase();
        if (promotion.productName.toLowerCase().includes(queryLower)) score += 15;
        if (promotion.brand && promotion.brand.toLowerCase().includes(queryLower)) score += 10;
        if (promotion.description && promotion.description.toLowerCase().includes(queryLower)) score += 5;
    }
    
    return score;
}

function renderSearchResults() {
    const container = document.getElementById('results-container');
    const resultsCount = document.getElementById('results-count');
    const noResults = document.getElementById('no-results');
    
    if (!container) return;
    
    // Update results count
    resultsCount.textContent = `${searchResults.length} promociones encontradas`;
    
    if (searchResults.length === 0) {
        container.innerHTML = '';
        noResults.classList.remove('hidden');
        return;
    }
    
    noResults.classList.add('hidden');
    
    // Calculate pagination
    const startIndex = (currentPage - 1) * itemsPerPage;
    const endIndex = startIndex + itemsPerPage;
    const pageResults = searchResults.slice(startIndex, endIndex);
    
    // Render promotions
    if (window.PromotionsModule) {
        container.innerHTML = '';
        window.PromotionsModule.renderPromotions(pageResults, container);
        
        // Add quick view functionality
        addQuickViewListeners(container);
    }
}

function addQuickViewListeners(container) {
    container.querySelectorAll('.promotion-card').forEach(card => {
        // Add double-click for quick view
        card.addEventListener('dblclick', function(e) {
            e.preventDefault();
            const promotionId = this.dataset.id;
            showQuickView(promotionId);
        });
        
        // Add quick view button
        const actionsDiv = card.querySelector('.promotion-actions');
        if (actionsDiv) {
            const quickViewBtn = document.createElement('button');
            quickViewBtn.className = 'action-btn quick-view-btn';
            quickViewBtn.title = 'Vista rápida';
            quickViewBtn.innerHTML = '<i class="fas fa-eye"></i>';
            quickViewBtn.addEventListener('click', function(e) {
                e.stopPropagation();
                const promotionId = card.dataset.id;
                showQuickView(promotionId);
            });
            actionsDiv.appendChild(quickViewBtn);
        }
    });
}

function showQuickView(promotionId) {
    const promotion = searchResults.find(p => p.id == promotionId);
    if (!promotion) return;
    
    const modal = document.getElementById('quick-view-modal');
    const modalTitle = document.getElementById('modal-title');
    const modalBody = document.getElementById('modal-body');
    
    if (!modal || !modalTitle || !modalBody) return;
    
    modalTitle.textContent = promotion.productName;
    
    const formattedOriginalPrice = window.PromoMania ? window.PromoMania.formatPrice(promotion.originalPrice) : `$${promotion.originalPrice}`;
    const formattedPromoPrice = window.PromoMania ? window.PromoMania.formatPrice(promotion.promoPrice) : `$${promotion.promoPrice}`;
    const savings = promotion.originalPrice - promotion.promoPrice;
    const formattedSavings = window.PromoMania ? window.PromoMania.formatPrice(savings) : `$${savings}`;
    
    modalBody.innerHTML = `
        <div class="quick-view-content">
            <div class="quick-view-image">
                <img src="${promotion.images[0]}" alt="${promotion.productName}">
            </div>
            <div class="quick-view-info">
                <div class="price-section">
                    <span class="original-price">${formattedOriginalPrice}</span>
                    <span class="promo-price">${formattedPromoPrice}</span>
                    <span class="discount-badge">${promotion.discountPercentage}% OFF</span>
                </div>
                <div class="savings">Ahorras ${formattedSavings}</div>
                
                <div class="promotion-meta">
                    <span><i class="fas fa-tag"></i> ${window.PromotionsModule.getCategoryName(promotion.category)}</span>
                    <span><i class="fas fa-store"></i> ${window.PromotionsModule.getStoreName(promotion.supermarket)}</span>
                    <span><i class="fas fa-map-marker-alt"></i> ${window.PromotionsModule.getCityName(promotion.city)}</span>
                </div>
                
                <div class="description">
                    <p>${promotion.description}</p>
                </div>
                
                <div class="validation-info">
                    <div class="rating">
                        <span class="stars">${renderStars(promotion.rating)}</span>
                        <span>${promotion.rating} (${promotion.votes.yes + promotion.votes.no} votos)</span>
                    </div>
                    ${promotion.verified ? '<span class="verified"><i class="fas fa-check-circle"></i> Verificada</span>' : ''}
                </div>
                
                <div class="quick-actions">
                    <button class="btn btn-primary" onclick="window.location.href='promotion.html?id=${promotion.id}'">
                        Ver Detalles Completos
                    </button>
                    <button class="btn btn-secondary" onclick="closeQuickView()">
                        Cerrar
                    </button>
                </div>
            </div>
        </div>
    `;
    
    if (window.PromoMania) {
        window.PromoMania.openModal('quick-view-modal');
    }
}

function renderStars(rating) {
    const fullStars = Math.floor(rating);
    const hasHalfStar = rating % 1 >= 0.5;
    const emptyStars = 5 - fullStars - (hasHalfStar ? 1 : 0);
    
    let stars = '';
    
    for (let i = 0; i < fullStars; i++) {
        stars += '<i class="fas fa-star"></i>';
    }
    
    if (hasHalfStar) {
        stars += '<i class="fas fa-star-half-alt"></i>';
    }
    
    for (let i = 0; i < emptyStars; i++) {
        stars += '<i class="far fa-star"></i>';
    }
    
    return stars;
}

function closeQuickView() {
    if (window.PromoMania) {
        window.PromoMania.closeModal('quick-view-modal');
    }
}

function renderActiveFilters() {
    const container = document.getElementById('active-filters');
    if (!container) return;
    
    const activeFilters = [];
    
    // Text search
    if (currentFilters.query) {
        activeFilters.push({
            type: 'query',
            label: `Búsqueda: "${currentFilters.query}"`,
            value: currentFilters.query
        });
    }
    
    // Categories
    if (currentFilters.categories) {
        currentFilters.categories.forEach(category => {
            activeFilters.push({
                type: 'category',
                label: window.PromotionsModule.getCategoryName(category),
                value: category
            });
        });
    }
    
    // Supermarkets
    if (currentFilters.supermarkets) {
        currentFilters.supermarkets.forEach(supermarket => {
            activeFilters.push({
                type: 'supermarket',
                label: window.PromotionsModule.getStoreName(supermarket),
                value: supermarket
            });
        });
    }
    
    // City
    if (currentFilters.city) {
        activeFilters.push({
            type: 'city',
            label: `Ciudad: ${window.PromotionsModule.getCityName(currentFilters.city)}`,
            value: currentFilters.city
        });
    }
    
    // Minimum discount
    if (currentFilters.minDiscount && currentFilters.minDiscount > 0) {
        activeFilters.push({
            type: 'minDiscount',
            label: `Descuento mín: ${currentFilters.minDiscount}%`,
            value: currentFilters.minDiscount
        });
    }
    
    // Maximum price
    if (currentFilters.maxPrice) {
        const formattedPrice = window.PromoMania ? window.PromoMania.formatPrice(currentFilters.maxPrice) : `$${currentFilters.maxPrice}`;
        activeFilters.push({
            type: 'maxPrice',
            label: `Precio máx: ${formattedPrice}`,
            value: currentFilters.maxPrice
        });
    }
    
    // Validation filters
    if (currentFilters.validation) {
        currentFilters.validation.forEach(validation => {
            const labels = {
                'verified': 'Verificadas',
                'with-photos': 'Con Fotos',
                'high-rating': 'Bien Calificadas'
            };
            activeFilters.push({
                type: 'validation',
                label: labels[validation] || validation,
                value: validation
            });
        });
    }
    
    // Render active filters
    if (activeFilters.length === 0) {
        container.innerHTML = '';
        return;
    }
    
    container.innerHTML = activeFilters.map(filter => `
        <div class="active-filter">
            <span>${filter.label}</span>
            <button onclick="removeFilter('${filter.type}', '${filter.value}')">
                <i class="fas fa-times"></i>
            </button>
        </div>
    `).join('');
}

function removeFilter(type, value) {
    switch (type) {
        case 'query':
            currentFilters.query = null;
            document.getElementById('search-text').value = '';
            break;
        case 'category':
            currentFilters.categories = currentFilters.categories.filter(c => c !== value);
            if (currentFilters.categories.length === 0) currentFilters.categories = null;
            document.querySelector(`input[name="category"][value="${value}"]`).checked = false;
            break;
        case 'supermarket':
            currentFilters.supermarkets = currentFilters.supermarkets.filter(s => s !== value);
            if (currentFilters.supermarkets.length === 0) currentFilters.supermarkets = null;
            document.querySelector(`input[name="supermarket"][value="${value}"]`).checked = false;
            break;
        case 'city':
            currentFilters.city = null;
            document.getElementById('city-filter').value = '';
            break;
        case 'minDiscount':
            currentFilters.minDiscount = 0;
            document.getElementById('discount-range').value = 0;
            document.getElementById('discount-value').textContent = '0%';
            break;
        case 'maxPrice':
            currentFilters.maxPrice = null;
            document.getElementById('max-price').value = '';
            break;
        case 'validation':
            currentFilters.validation = currentFilters.validation.filter(v => v !== value);
            if (currentFilters.validation.length === 0) currentFilters.validation = null;
            document.querySelector(`input[name="validation"][value="${value}"]`).checked = false;
            break;
    }
    
    currentPage = 1;
    performSearch();
}

function clearAllFilters() {
    // Clear all filters
    currentFilters = {};
    currentPage = 1;
    
    // Reset form elements
    document.getElementById('search-text').value = '';
    document.getElementById('city-filter').value = '';
    document.getElementById('max-price').value = '';
    document.getElementById('discount-range').value = 0;
    document.getElementById('discount-value').textContent = '0%';
    
    // Uncheck all checkboxes
    document.querySelectorAll('input[type="checkbox"]').forEach(cb => cb.checked = false);
    
    // Reset sort to relevance
    document.getElementById('sort-by').value = 'relevance';
    
    // Perform search
    performSearch();
}

function renderPagination() {
    const container = document.getElementById('pagination');
    if (!container) return;
    
    const totalPages = Math.ceil(searchResults.length / itemsPerPage);
    
    if (totalPages <= 1) {
        container.innerHTML = '';
        return;
    }
    
    let pagination = '';
    
    // Previous button
    pagination += `
        <button ${currentPage === 1 ? 'disabled' : ''} onclick="goToPage(${currentPage - 1})">
            <i class="fas fa-chevron-left"></i> Anterior
        </button>
    `;
    
    // Page numbers
    const startPage = Math.max(1, currentPage - 2);
    const endPage = Math.min(totalPages, currentPage + 2);
    
    if (startPage > 1) {
        pagination += `<button onclick="goToPage(1)">1</button>`;
        if (startPage > 2) {
            pagination += `<span>...</span>`;
        }
    }
    
    for (let i = startPage; i <= endPage; i++) {
        pagination += `
            <button ${i === currentPage ? 'class="active"' : ''} onclick="goToPage(${i})">
                ${i}
            </button>
        `;
    }
    
    if (endPage < totalPages) {
        if (endPage < totalPages - 1) {
            pagination += `<span>...</span>`;
        }
        pagination += `<button onclick="goToPage(${totalPages})">${totalPages}</button>`;
    }
    
    // Next button
    pagination += `
        <button ${currentPage === totalPages ? 'disabled' : ''} onclick="goToPage(${currentPage + 1})">
            Siguiente <i class="fas fa-chevron-right"></i>
        </button>
    `;
    
    container.innerHTML = pagination;
}

function goToPage(page) {
    currentPage = page;
    renderSearchResults();
    renderPagination();
    
    // Scroll to top of results
    document.getElementById('results-container').scrollIntoView({ behavior: 'smooth' });
}

function showLoading(show) {
    const loading = document.getElementById('loading');
    const container = document.getElementById('results-container');
    
    if (show) {
        loading.classList.remove('hidden');
        container.style.opacity = '0.5';
    } else {
        loading.classList.add('hidden');
        container.style.opacity = '1';
    }
}

// Global functions for HTML onclick handlers
window.removeFilter = removeFilter;
window.goToPage = goToPage;
window.closeQuickView = closeQuickView;
window.clearAllFilters = clearAllFilters;

// Export for use in other modules
window.SearchModule = {
    performSearch,
    showQuickView,
    currentFilters,
    searchResults
};