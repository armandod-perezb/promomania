// Notifications JavaScript functionality

document.addEventListener('DOMContentLoaded', function() {
    initializeNotificationSystem();
});

function initializeNotificationSystem() {
    // Real-time notification simulation
    simulateRealTimeNotifications();
    
    // Initialize notification preferences
    loadNotificationPreferences();
    
    console.log('Notification system initialized');
}

function simulateRealTimeNotifications() {
    // Simulate receiving new notifications every few minutes
    const notifications = [
        {
            title: 'Nueva promoción cerca de ti',
            message: 'Encontramos 3 nuevas promociones en supermercados cercanos a tu ubicación',
            type: 'location'
        },
        {
            title: 'Producto en tu lista de seguimiento',
            message: 'El iPhone 13 que sigues tiene una nueva promoción con 15% de descuento',
            type: 'wishlist'
        },
        {
            title: 'Promoción popular en tu categoría',
            message: 'La promoción de "Detergente Ariel" ya tiene 50 validaciones positivas',
            type: 'trending'
        },
        {
            title: 'Respuesta a tu comentario',
            message: 'María respondió a tu comentario en la promoción de "Aceite de Oliva"',
            type: 'reply'
        },
        {
            title: 'Tu promoción está expirando',
            message: 'La promoción "Televisor LG 43 pulgadas" expira mañana',
            type: 'expiry'
        }
    ];
    
    let notificationIndex = 0;
    
    // Send a notification every 30-60 seconds for demonstration
    setInterval(() => {
        if (Math.random() > 0.3 && notificationIndex < notifications.length) { // 70% chance
            const notification = notifications[notificationIndex];
            
            if (window.PromoMania && window.PromoMania.addNotification) {
                window.PromoMania.addNotification(
                    notification.title,
                    notification.message,
                    notification.type
                );
            }
            
            notificationIndex = (notificationIndex + 1) % notifications.length;
        }
    }, 45000); // 45 seconds
}

function loadNotificationPreferences() {
    // Load user notification preferences from localStorage
    const preferences = JSON.parse(localStorage.getItem('notificationPreferences')) || {
        newPromotions: true,
        nearbyOffers: true,
        priceAlerts: true,
        validationUpdates: true,
        comments: true,
        systemUpdates: false
    };
    
    return preferences;
}

function saveNotificationPreferences(preferences) {
    localStorage.setItem('notificationPreferences', JSON.stringify(preferences));
}

// Push notification simulation (would integrate with real push service)
function requestNotificationPermission() {
    if ('Notification' in window) {
        Notification.requestPermission().then(permission => {
            if (permission === 'granted') {
                console.log('Notification permission granted');
                showBrowserNotification(
                    '¡Notificaciones activadas!',
                    'Ahora recibirás alertas sobre nuevas promociones y ofertas cerca de ti'
                );
            }
        });
    }
}

function showBrowserNotification(title, body, icon = '/assets/images/logo.png') {
    if ('Notification' in window && Notification.permission === 'granted') {
        const notification = new Notification(title, {
            body,
            icon,
            badge: icon,
            tag: 'promowania-notification',
            requireInteraction: false,
            timestamp: Date.now()
        });
        
        notification.onclick = function() {
            window.focus();
            notification.close();
        };
        
        // Auto close after 5 seconds
        setTimeout(() => notification.close(), 5000);
    }
}

// Alert system for price drops and specific conditions
class AlertSystem {
    constructor() {
        this.alerts = JSON.parse(localStorage.getItem('priceAlerts')) || [];
        this.watchedProducts = JSON.parse(localStorage.getItem('watchedProducts')) || [];
    }
    
    addPriceAlert(productName, targetPrice, currentPrice, category, store) {
        const alert = {
            id: Date.now(),
            productName,
            targetPrice,
            currentPrice,
            category,
            store,
            created: new Date().toISOString(),
            active: true
        };
        
        this.alerts.push(alert);
        this.saveAlerts();
        
        if (window.PromoMania && window.PromoMania.showToast) {
            window.PromoMania.showToast(
                'Alerta creada',
                `Te notificaremos cuando ${productName} esté por debajo de ${window.PromoMania.formatPrice(targetPrice)}`,
                'success'
            );
        }
        
        return alert;
    }
    
    addProductWatch(productName, category, keywords = []) {
        const watch = {
            id: Date.now(),
            productName,
            category,
            keywords,
            created: new Date().toISOString(),
            active: true
        };
        
        this.watchedProducts.push(watch);
        this.saveWatchedProducts();
        
        if (window.PromoMania && window.PromoMania.showToast) {
            window.PromoMania.showToast(
                'Producto en seguimiento',
                `Te notificaremos sobre nuevas promociones de ${productName}`,
                'success'
            );
        }
        
        return watch;
    }
    
    checkPriceAlerts(promotions) {
        const triggeredAlerts = [];
        
        this.alerts.filter(alert => alert.active).forEach(alert => {
            promotions.forEach(promotion => {
                if (this.matchesAlert(promotion, alert) && promotion.promoPrice <= alert.targetPrice) {
                    triggeredAlerts.push({
                        alert,
                        promotion
                    });
                    
                    // Send notification
                    if (window.PromoMania && window.PromoMania.addNotification) {
                        window.PromoMania.addNotification(
                            '¡Alerta de precio!',
                            `${promotion.productName} está ahora a ${window.PromoMania.formatPrice(promotion.promoPrice)} en ${promotion.store}`,
                            'price-alert'
                        );
                    }
                    
                    // Show browser notification if enabled
                    showBrowserNotification(
                        '¡Precio objetivo alcanzado!',
                        `${promotion.productName} - ${window.PromoMania.formatPrice(promotion.promoPrice)} en ${promotion.store}`
                    );
                }
            });
        });
        
        return triggeredAlerts;
    }
    
    checkProductWatches(promotions) {
        const matchedWatches = [];
        
        this.watchedProducts.filter(watch => watch.active).forEach(watch => {
            promotions.forEach(promotion => {
                if (this.matchesWatch(promotion, watch)) {
                    matchedWatches.push({
                        watch,
                        promotion
                    });
                    
                    // Send notification
                    if (window.PromoMania && window.PromoMania.addNotification) {
                        window.PromoMania.addNotification(
                            'Producto en seguimiento',
                            `Nueva promoción: ${promotion.productName} con ${promotion.discountPercentage}% de descuento en ${promotion.store}`,
                            'watch'
                        );
                    }
                }
            });
        });
        
        return matchedWatches;
    }
    
    matchesAlert(promotion, alert) {
        const productMatch = promotion.productName.toLowerCase().includes(alert.productName.toLowerCase()) ||
                           alert.productName.toLowerCase().includes(promotion.productName.toLowerCase());
        
        const categoryMatch = !alert.category || promotion.category === alert.category;
        const storeMatch = !alert.store || promotion.store === alert.store;
        
        return productMatch && categoryMatch && storeMatch;
    }
    
    matchesWatch(promotion, watch) {
        const productMatch = promotion.productName.toLowerCase().includes(watch.productName.toLowerCase()) ||
                           watch.productName.toLowerCase().includes(promotion.productName.toLowerCase());
        
        const categoryMatch = !watch.category || promotion.category === watch.category;
        
        const keywordMatch = watch.keywords.length === 0 || 
                           watch.keywords.some(keyword => 
                               promotion.productName.toLowerCase().includes(keyword.toLowerCase()) ||
                               (promotion.description && promotion.description.toLowerCase().includes(keyword.toLowerCase()))
                           );
        
        return productMatch && categoryMatch && keywordMatch;
    }
    
    removeAlert(alertId) {
        this.alerts = this.alerts.filter(alert => alert.id !== alertId);
        this.saveAlerts();
    }
    
    removeWatch(watchId) {
        this.watchedProducts = this.watchedProducts.filter(watch => watch.id !== watchId);
        this.saveWatchedProducts();
    }
    
    saveAlerts() {
        localStorage.setItem('priceAlerts', JSON.stringify(this.alerts));
    }
    
    saveWatchedProducts() {
        localStorage.setItem('watchedProducts', JSON.stringify(this.watchedProducts));
    }
    
    getActiveAlerts() {
        return this.alerts.filter(alert => alert.active);
    }
    
    getActiveWatches() {
        return this.watchedProducts.filter(watch => watch.active);
    }
}

// Initialize alert system
const alertSystem = new AlertSystem();

// Location-based notifications
class LocationNotifications {
    constructor() {
        this.userLocation = null;
        this.nearbyRadius = 5; // km
        this.requestLocation();
    }
    
    requestLocation() {
        if ('geolocation' in navigator) {
            navigator.geolocation.getCurrentPosition(
                position => {
                    this.userLocation = {
                        lat: position.coords.latitude,
                        lng: position.coords.longitude
                    };
                    console.log('User location obtained for notifications');
                },
                error => {
                    console.log('Location access denied or unavailable');
                    // Fallback to city-based notifications
                    this.userLocation = { city: 'Bogotá' }; // Default city
                }
            );
        }
    }
    
    checkNearbyPromotions(promotions) {
        if (!this.userLocation) return [];
        
        const nearbyPromotions = promotions.filter(promotion => {
            if (this.userLocation.city) {
                // City-based matching
                return promotion.city && promotion.city.toLowerCase() === this.userLocation.city.toLowerCase();
            }
            
            if (this.userLocation.lat && this.userLocation.lng && promotion.lat && promotion.lng) {
                // Distance-based matching
                const distance = this.calculateDistance(
                    this.userLocation.lat, this.userLocation.lng,
                    promotion.lat, promotion.lng
                );
                return distance <= this.nearbyRadius;
            }
            
            return false;
        });
        
        // Notify about nearby promotions
        if (nearbyPromotions.length > 0) {
            const recentPromotions = nearbyPromotions.filter(p => {
                const promoDate = new Date(p.created);
                const hoursSinceCreated = (Date.now() - promoDate.getTime()) / (1000 * 60 * 60);
                return hoursSinceCreated <= 24; // Last 24 hours
            });
            
            if (recentPromotions.length > 0) {
                if (window.PromoMania && window.PromoMania.addNotification) {
                    window.PromoMania.addNotification(
                        'Promociones cerca de ti',
                        `Encontramos ${recentPromotions.length} promociones nuevas en tu zona`,
                        'location'
                    );
                }
            }
        }
        
        return nearbyPromotions;
    }
    
    calculateDistance(lat1, lng1, lat2, lng2) {
        const R = 6371; // Earth's radius in km
        const dLat = this.deg2rad(lat2 - lat1);
        const dLng = this.deg2rad(lng2 - lng1);
        const a = 
            Math.sin(dLat/2) * Math.sin(dLat/2) +
            Math.cos(this.deg2rad(lat1)) * Math.cos(this.deg2rad(lat2)) * 
            Math.sin(dLng/2) * Math.sin(dLng/2);
        const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a));
        return R * c;
    }
    
    deg2rad(deg) {
        return deg * (Math.PI/180);
    }
}

// Initialize location notifications
const locationNotifications = new LocationNotifications();

// Export for use in other modules
window.NotificationSystem = {
    alertSystem,
    locationNotifications,
    requestNotificationPermission,
    showBrowserNotification,
    loadNotificationPreferences,
    saveNotificationPreferences
};