// Promotions functionality

// Mock data for promotions
let promotionsData = [
    {
        id: 1,
        productName: 'Aceite de Oliva Extra Virgen Carbonell 500ml',
        brand: 'Carbonell',
        category: 'alimentos',
        supermarket: 'exito',
        originalPrice: 15900,
        promoPrice: 9540,
        discountPercentage: 40,
        city: 'bogota',
        neighborhood: 'Chapinero',
        storeAddress: 'Calle 63 #11-50',
        description: 'Promoción especial 40% de descuento en aceite de oliva extra virgen Carbonell.',
        startDate: '2024-09-15',
        endDate: '2024-09-30',
        images: [
            'https://via.placeholder.com/400x300?text=Aceite+Carbonell+1',
            'https://via.placeholder.com/400x300?text=Aceite+Carbonell+2'
        ],
        rating: 4.2,
        votes: { yes: 18, no: 5 },
        views: 347,
        verified: true,
        created: '2024-09-13T10:30:00Z',
        updated: '2024-09-14T15:20:00Z',
        userId: 1,
        lat: 4.6097,
        lng: -74.0817
    },
    {
        id: 2,
        productName: 'Arroz Diana Blanco 5kg',
        brand: 'Diana',
        category: 'alimentos',
        supermarket: 'olimpica',
        originalPrice: 12000,
        promoPrice: 8400,
        discountPercentage: 30,
        city: 'medellin',
        neighborhood: 'El Poblado',
        storeAddress: 'Carrera 43A #5-50',
        description: '2x1 en arroz Diana. Lleva 2 bolsas de 5kg por el precio de una.',
        startDate: '2024-09-14',
        endDate: '2024-09-28',
        images: [
            'https://via.placeholder.com/400x300?text=Arroz+Diana+1'
        ],
        rating: 4.8,
        votes: { yes: 32, no: 2 },
        views: 523,
        verified: true,
        created: '2024-09-14T08:15:00Z',
        updated: '2024-09-14T08:15:00Z',
        userId: 2
    },
    {
        id: 3,
        productName: 'Televisor Samsung 55" QLED 4K',
        brand: 'Samsung',
        category: 'electronica',
        supermarket: 'alkosto',
        originalPrice: 2800000,
        promoPrice: 2240000,
        discountPercentage: 20,
        city: 'bogota',
        neighborhood: 'Suba',
        storeAddress: 'Centro Comercial Santafé',
        description: 'Televisor Samsung QLED 55 pulgadas con 20% de descuento. Incluye soundbar gratis.',
        startDate: '2024-09-10',
        endDate: '2024-09-25',
        images: [
            'https://via.placeholder.com/400x300?text=TV+Samsung+1',
            'https://via.placeholder.com/400x300?text=TV+Samsung+2',
            'https://via.placeholder.com/400x300?text=TV+Samsung+3'
        ],
        rating: 4.5,
        votes: { yes: 45, no: 8 },
        views: 892,
        verified: true,
        created: '2024-09-10T14:20:00Z',
        updated: '2024-09-12T09:10:00Z',
        userId: 3
    },
    {
        id: 4,
        productName: 'Detergente Ariel Líquido 1.5L',
        brand: 'Ariel',
        category: 'hogar',
        supermarket: 'd1',
        originalPrice: 8500,
        promoPrice: 5950,
        discountPercentage: 30,
        city: 'cali',
        neighborhood: 'Granada',
        storeAddress: 'Avenida 6N #28-15',
        description: 'Detergente líquido Ariel con 30% de descuento en todas las tiendas D1.',
        startDate: '2024-09-12',
        endDate: '2024-09-26',
        images: [
            'https://via.placeholder.com/400x300?text=Detergente+Ariel'
        ],
        rating: 4.0,
        votes: { yes: 28, no: 7 },
        views: 445,
        verified: false,
        created: '2024-09-12T16:45:00Z',
        updated: '2024-09-13T11:30:00Z',
        userId: 4
    },
    {
        id: 5,
        productName: 'iPhone 13 128GB',
        brand: 'Apple',
        category: 'electronica',
        supermarket: 'falabella',
        originalPrice: 3200000,
        promoPrice: 2720000,
        discountPercentage: 15,
        city: 'barranquilla',
        neighborhood: 'Alto Prado',
        storeAddress: 'Calle 79B #57-50',
        description: 'iPhone 13 con 15% de descuento. Disponible en todos los colores.',
        startDate: '2024-09-08',
        endDate: '2024-09-22',
        images: [
            'https://via.placeholder.com/400x300?text=iPhone+13+1',
            'https://via.placeholder.com/400x300?text=iPhone+13+2'
        ],
        rating: 4.7,
        votes: { yes: 67, no: 3 },
        views: 1205,
        verified: true,
        created: '2024-09-08T12:00:00Z',
        updated: '2024-09-09T08:15:00Z',
        userId: 5
    },
    {
        id: 6,
        productName: 'Shampoo Head & Shoulders 400ml',
        brand: 'Head & Shoulders',
        category: 'personal',
        supermarket: 'carrefour',
        originalPrice: 14000,
        promoPrice: 9800,
        discountPercentage: 30,
        city: 'bogota',
        neighborhood: 'Kennedy',
        storeAddress: 'Carrera 86 #41A-32',
        description: 'Shampoo anticaspa Head & Shoulders con 30% de descuento.',
        startDate: '2024-09-11',
        endDate: '2024-09-25',
        images: [
            'https://via.placeholder.com/400x300?text=Shampoo+H%26S'
        ],
        rating: 3.8,
        votes: { yes: 22, no: 6 },
        views: 298,
        verified: true,
        created: '2024-09-11T09:20:00Z',
        updated: '2024-09-11T09:20:00Z',
        userId: 6
    }
];

// Initialize promotions functionality
document.addEventListener('DOMContentLoaded', function() {
    if (document.getElementById('promotions-container')) {
        initializePromotions();
    }
});

function initializePromotions() {
    loadPromotions();
    
    // Initialize sort functionality
    const sortSelect = document.getElementById('sort-select');
    if (sortSelect) {
        sortSelect.addEventListener('change', function() {
            const sortBy = this.value;
            sortPromotions(sortBy);
        });
    }
    
    // Initialize load more button
    const loadMoreBtn = document.getElementById('load-more-btn');
    if (loadMoreBtn) {
        loadMoreBtn.addEventListener('click', loadMorePromotions);
    }
    
    console.log('Promotions initialized');
}

function loadPromotions() {
    const container = document.getElementById('promotions-container');
    if (!container) return;
    
    // Show first 6 promotions initially
    const initialPromotions = promotionsData.slice(0, 6);
    renderPromotions(initialPromotions, container);
    
    // Check alerts and watches
    if (window.NotificationSystem) {
        window.NotificationSystem.alertSystem.checkPriceAlerts(promotionsData);
        window.NotificationSystem.alertSystem.checkProductWatches(promotionsData);
        window.NotificationSystem.locationNotifications.checkNearbyPromotions(promotionsData);
    }
}

function renderPromotions(promotions, container) {
    if (!container) return;
    
    const promotionsHTML = promotions.map(promotion => createPromotionCard(promotion)).join('');
    
    if (container.innerHTML.trim() === '') {
        container.innerHTML = promotionsHTML;
    } else {
        container.innerHTML += promotionsHTML;
    }
    
    // Add event listeners to new cards
    addPromotionCardListeners(container);
}

function createPromotionCard(promotion) {
    const savings = promotion.originalPrice - promotion.promoPrice;
    const timeAgo = window.PromoMania ? window.PromoMania.formatTimeAgo(promotion.created) : 'Reciente';
    const formattedOriginalPrice = window.PromoMania ? window.PromoMania.formatPrice(promotion.originalPrice) : `$${promotion.originalPrice}`;
    const formattedPromoPrice = window.PromoMania ? window.PromoMania.formatPrice(promotion.promoPrice) : `$${promotion.promoPrice}`;
    const formattedSavings = window.PromoMania ? window.PromoMania.formatPrice(savings) : `$${savings}`;
    
    return `
        <div class="promotion-card" data-id="${promotion.id}">
            <div class="promotion-image">
                <img src="${promotion.images[0]}" alt="${promotion.productName}" loading="lazy">
                <div class="discount-badge">${promotion.discountPercentage}% OFF</div>
                ${promotion.verified ? '<div class="verification-badge"><i class="fas fa-check-circle"></i> Verificada</div>' : ''}
            </div>
            
            <div class="promotion-content">
                <div class="promotion-header">
                    <h3 class="promotion-title">${promotion.productName}</h3>
                    <div class="promotion-meta">
                        <span><i class="fas fa-tag"></i> ${getCategoryName(promotion.category)}</span>
                        <span><i class="fas fa-store"></i> ${getStoreName(promotion.supermarket)}</span>
                        <span><i class="fas fa-map-marker-alt"></i> ${getCityName(promotion.city)}</span>
                    </div>
                </div>
                
                <div class="promotion-prices">
                    <div class="price-container">
                        <span class="original-price">${formattedOriginalPrice}</span>
                        <span class="promo-price">${formattedPromoPrice}</span>
                    </div>
                    <div class="savings">Ahorras ${formattedSavings}</div>
                </div>
                
                <div class="promotion-store">
                    <div class="store-logo">${getStoreInitial(promotion.supermarket)}</div>
                    <span>${getStoreName(promotion.supermarket)} - ${promotion.neighborhood}</span>
                </div>
                
                <div class="promotion-footer">
                    <div class="promotion-rating">
                        <div class="stars">${renderStars(promotion.rating)}</div>
                        <span>${promotion.rating} (${promotion.votes.yes + promotion.votes.no})</span>
                    </div>
                    
                    <div class="promotion-actions">
                        <button class="action-btn share-btn" title="Compartir" data-id="${promotion.id}">
                            <i class="fas fa-share-alt"></i>
                        </button>
                        <button class="action-btn favorite-btn" title="Favorito" data-id="${promotion.id}">
                            <i class="far fa-heart"></i>
                        </button>
                        <button class="action-btn alert-btn" title="Crear alerta" data-id="${promotion.id}">
                            <i class="fas fa-bell"></i>
                        </button>
                    </div>
                </div>
                
                <div class="promotion-time">
                    <small><i class="fas fa-clock"></i> ${timeAgo}</small>
                </div>
            </div>
        </div>
    `;
}

function addPromotionCardListeners(container) {
    // Click on card to view details
    container.querySelectorAll('.promotion-card').forEach(card => {
        card.addEventListener('click', function(e) {
            // Don't trigger if clicking on action buttons
            if (e.target.closest('.action-btn')) return;
            
            const promotionId = this.dataset.id;
            viewPromotionDetails(promotionId);
        });
    });
    
    // Share buttons
    container.querySelectorAll('.share-btn').forEach(btn => {
        btn.addEventListener('click', function(e) {
            e.stopPropagation();
            const promotionId = this.dataset.id;
            sharePromotion(promotionId);
        });
    });
    
    // Favorite buttons
    container.querySelectorAll('.favorite-btn').forEach(btn => {
        btn.addEventListener('click', function(e) {
            e.stopPropagation();
            const promotionId = this.dataset.id;
            toggleFavorite(promotionId, this);
        });
    });
    
    // Alert buttons
    container.querySelectorAll('.alert-btn').forEach(btn => {
        btn.addEventListener('click', function(e) {
            e.stopPropagation();
            const promotionId = this.dataset.id;
            createPriceAlert(promotionId);
        });
    });
}

function viewPromotionDetails(promotionId) {
    // Redirect to promotion detail page
    window.location.href = `promotion.html?id=${promotionId}`;
}

function sharePromotion(promotionId) {
    const promotion = promotionsData.find(p => p.id == promotionId);
    if (!promotion) return;
    
    const url = `${window.location.origin}/promotion.html?id=${promotionId}`;
    const text = `¡Mira esta promoción! ${promotion.productName} con ${promotion.discountPercentage}% de descuento en ${getStoreName(promotion.supermarket)}`;
    
    if (navigator.share) {
        navigator.share({
            title: 'Promoción en Promomanía',
            text: text,
            url: url
        });
    } else {
        // Fallback to copy to clipboard
        navigator.clipboard.writeText(`${text} ${url}`).then(() => {
            if (window.PromoMania) {
                window.PromoMania.showToast('Enlace copiado', 'El enlace de la promoción se copió al portapapeles', 'success');
            }
        });
    }
}

function toggleFavorite(promotionId, button) {
    const isFavorite = button.querySelector('i').classList.contains('fas');
    
    if (isFavorite) {
        button.querySelector('i').className = 'far fa-heart';
        button.title = 'Favorito';
        removeFavorite(promotionId);
    } else {
        button.querySelector('i').className = 'fas fa-heart';
        button.title = 'Remover de favoritos';
        addFavorite(promotionId);
    }
}

function addFavorite(promotionId) {
    let favorites = JSON.parse(localStorage.getItem('favorites') || '[]');
    if (!favorites.includes(promotionId)) {
        favorites.push(promotionId);
        localStorage.setItem('favorites', JSON.stringify(favorites));
        
        if (window.PromoMania) {
            window.PromoMania.showToast('Agregado a favoritos', 'La promoción se agregó a tus favoritos', 'success');
        }
    }
}

function removeFavorite(promotionId) {
    let favorites = JSON.parse(localStorage.getItem('favorites') || '[]');
    favorites = favorites.filter(id => id != promotionId);
    localStorage.setItem('favorites', JSON.stringify(favorites));
    
    if (window.PromoMania) {
        window.PromoMania.showToast('Removido de favoritos', 'La promoción se removió de tus favoritos', 'info');
    }
}

function createPriceAlert(promotionId) {
    const promotion = promotionsData.find(p => p.id == promotionId);
    if (!promotion) return;
    
    // Create an alert for 10% less than current promo price
    const targetPrice = Math.floor(promotion.promoPrice * 0.9);
    
    if (window.NotificationSystem) {
        window.NotificationSystem.alertSystem.addPriceAlert(
            promotion.productName,
            targetPrice,
            promotion.promoPrice,
            promotion.category,
            promotion.supermarket
        );
    }
}

function sortPromotions(sortBy) {
    let sortedPromotions = [...promotionsData];
    
    switch (sortBy) {
        case 'recent':
            sortedPromotions.sort((a, b) => new Date(b.created) - new Date(a.created));
            break;
        case 'discount':
            sortedPromotions.sort((a, b) => b.discountPercentage - a.discountPercentage);
            break;
        case 'popular':
            sortedPromotions.sort((a, b) => b.views - a.views);
            break;
        case 'validated':
            sortedPromotions.sort((a, b) => {
                const aRatio = a.votes.yes / (a.votes.yes + a.votes.no);
                const bRatio = b.votes.yes / (b.votes.yes + b.votes.no);
                return bRatio - aRatio;
            });
            break;
        default:
            break;
    }
    
    const container = document.getElementById('promotions-container');
    if (container) {
        container.innerHTML = '';
        renderPromotions(sortedPromotions.slice(0, 6), container);
    }
}

function loadMorePromotions() {
    const container = document.getElementById('promotions-container');
    const loadMoreBtn = document.getElementById('load-more-btn');
    
    if (!container || !loadMoreBtn) return;
    
    const currentCount = container.children.length;
    const nextPromotions = promotionsData.slice(currentCount, currentCount + 6);
    
    if (nextPromotions.length > 0) {
        renderPromotions(nextPromotions, container);
        
        // Hide load more button if no more promotions
        if (currentCount + nextPromotions.length >= promotionsData.length) {
            loadMoreBtn.style.display = 'none';
        }
    }
}

// Utility functions
function getCategoryName(category) {
    const categories = {
        'alimentos': 'Alimentos',
        'electronica': 'Electrónica',
        'hogar': 'Hogar',
        'personal': 'Cuidado Personal',
        'ropa': 'Ropa',
        'deportes': 'Deportes',
        'mascotas': 'Mascotas',
        'farmacia': 'Farmacia'
    };
    return categories[category] || category;
}

function getStoreName(store) {
    const stores = {
        'exito': 'Éxito',
        'olimpica': 'Olímpica',
        'carrefour': 'Carrefour',
        'jumbo': 'Jumbo',
        'd1': 'D1',
        'ara': 'Ara',
        'metro': 'Metro',
        'alkosto': 'Alkosto',
        'homecenter': 'Homecenter',
        'falabella': 'Falabella'
    };
    return stores[store] || store;
}

function getCityName(city) {
    const cities = {
        'bogota': 'Bogotá',
        'medellin': 'Medellín',
        'cali': 'Cali',
        'barranquilla': 'Barranquilla',
        'cartagena': 'Cartagena',
        'bucaramanga': 'Bucaramanga',
        'pereira': 'Pereira',
        'manizales': 'Manizales',
        'santa-marta': 'Santa Marta',
        'ibague': 'Ibagué'
    };
    return cities[city] || city;
}

function getStoreInitial(store) {
    const initials = {
        'exito': 'E',
        'olimpica': 'O',
        'carrefour': 'C',
        'jumbo': 'J',
        'd1': 'D1',
        'ara': 'A',
        'metro': 'M',
        'alkosto': 'AL',
        'homecenter': 'H',
        'falabella': 'F'
    };
    return initials[store] || store.charAt(0).toUpperCase();
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

// Export for use in other modules
window.PromotionsModule = {
    promotionsData,
    loadPromotions,
    renderPromotions,
    createPromotionCard,
    sortPromotions,
    getCategoryName,
    getStoreName,
    getCityName
};