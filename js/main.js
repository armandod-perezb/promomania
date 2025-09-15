// Main JavaScript functionality for Promomanía

// Global variables
let currentUser = null;
let notifications = [];

// Initialize app when DOM is loaded
document.addEventListener('DOMContentLoaded', function() {
    initializeApp();
});

function initializeApp() {
    // Initialize navigation
    initializeNavigation();
    
    // Initialize notifications
    initializeNotifications();
    
    // Initialize quick search
    initializeQuickSearch();
    
    // Initialize modals
    initializeModals();
    
    // Initialize user session (mock)
    initializeUserSession();
    
    console.log('Promomanía initialized successfully');
}

// Navigation functionality
function initializeNavigation() {
    const navLinks = document.querySelectorAll('.nav-menu a');
    const currentPage = window.location.pathname.split('/').pop() || 'index.html';
    
    navLinks.forEach(link => {
        const href = link.getAttribute('href');
        if (href === currentPage) {
            link.classList.add('active');
        } else {
            link.classList.remove('active');
        }
    });
    
    // Notifications button
    const notificationsBtn = document.getElementById('notifications-btn');
    if (notificationsBtn) {
        notificationsBtn.addEventListener('click', function(e) {
            e.preventDefault();
            toggleNotifications();
        });
    }
}

// Notifications functionality
function initializeNotifications() {
    // Load mock notifications
    loadNotifications();
    
    // Close notifications panel
    const closeBtn = document.getElementById('close-notifications');
    if (closeBtn) {
        closeBtn.addEventListener('click', closeNotifications);
    }
    
    // Close when clicking outside
    document.addEventListener('click', function(e) {
        const panel = document.getElementById('notifications-panel');
        const btn = document.getElementById('notifications-btn');
        
        if (panel && !panel.contains(e.target) && !btn.contains(e.target)) {
            closeNotifications();
        }
    });
}

function loadNotifications() {
    // Mock notifications data
    notifications = [
        {
            id: 1,
            title: 'Nueva promoción en tu zona',
            message: 'Aceite de oliva con 40% de descuento en Éxito Chapinero',
            time: '5 min',
            unread: true,
            type: 'promotion'
        },
        {
            id: 2,
            title: 'Tu promoción fue validada',
            message: 'La promoción de "Arroz Diana 5kg" recibió 5 votos positivos',
            time: '1 hora',
            unread: true,
            type: 'validation'
        },
        {
            id: 3,
            title: 'Comentario en tu promoción',
            message: 'Juan Carlos comentó en "Televisor Samsung 55"',
            time: '2 horas',
            unread: true,
            type: 'comment'
        },
        {
            id: 4,
            title: 'Promoción verificada',
            message: 'Tu promoción de "Shampoo Head & Shoulders" fue verificada por la comunidad',
            time: '1 día',
            unread: false,
            type: 'verification'
        }
    ];
    
    updateNotificationCount();
    renderNotifications();
}

function updateNotificationCount() {
    const unreadCount = notifications.filter(n => n.unread).length;
    const countElements = document.querySelectorAll('.notification-count');
    
    countElements.forEach(element => {
        element.textContent = unreadCount;
        element.style.display = unreadCount > 0 ? 'flex' : 'none';
    });
}

function renderNotifications() {
    const container = document.getElementById('notifications-content');
    if (!container) return;
    
    if (notifications.length === 0) {
        container.innerHTML = `
            <div class="notification-item">
                <div class="notification-header">
                    <span class="notification-title">No hay notificaciones</span>
                </div>
                <div class="notification-message">
                    Te notificaremos sobre promociones nuevas y actividad en tus publicaciones.
                </div>
            </div>
        `;
        return;
    }
    
    container.innerHTML = notifications.map(notification => `
        <div class="notification-item ${notification.unread ? 'unread' : ''}" data-id="${notification.id}">
            <div class="notification-header">
                <span class="notification-title">${notification.title}</span>
                <span class="notification-time">${notification.time}</span>
            </div>
            <div class="notification-message">${notification.message}</div>
        </div>
    `).join('');
    
    // Add click handlers to notifications
    container.querySelectorAll('.notification-item').forEach(item => {
        item.addEventListener('click', function() {
            const id = parseInt(this.dataset.id);
            markNotificationAsRead(id);
        });
    });
}

function toggleNotifications() {
    const panel = document.getElementById('notifications-panel');
    if (panel) {
        panel.classList.toggle('hidden');
    }
}

function closeNotifications() {
    const panel = document.getElementById('notifications-panel');
    if (panel) {
        panel.classList.add('hidden');
    }
}

function markNotificationAsRead(id) {
    const notification = notifications.find(n => n.id === id);
    if (notification) {
        notification.unread = false;
        updateNotificationCount();
        renderNotifications();
    }
}

function addNotification(title, message, type = 'info') {
    const newNotification = {
        id: Date.now(),
        title,
        message,
        time: 'Ahora',
        unread: true,
        type
    };
    
    notifications.unshift(newNotification);
    updateNotificationCount();
    renderNotifications();
    
    // Show toast notification
    showToast(title, message, type);
}

// Quick search functionality
function initializeQuickSearch() {
    const searchForm = document.getElementById('quick-search');
    if (searchForm) {
        searchForm.addEventListener('submit', function(e) {
            e.preventDefault();
            const searchInput = document.getElementById('search-input');
            const query = searchInput.value.trim();
            
            if (query) {
                // Redirect to search page with query
                window.location.href = `search.html?q=${encodeURIComponent(query)}`;
            }
        });
    }
    
    // Quick filter buttons
    const filterButtons = document.querySelectorAll('.filter-btn');
    filterButtons.forEach(btn => {
        btn.addEventListener('click', function() {
            const category = this.dataset.category;
            if (category) {
                window.location.href = `search.html?category=${category}`;
            }
        });
    });
}

// Modal functionality
function initializeModals() {
    // Close modal when clicking on backdrop
    document.addEventListener('click', function(e) {
        if (e.target.classList.contains('modal')) {
            closeModal(e.target.id);
        }
    });
    
    // Close modal when pressing Escape
    document.addEventListener('keydown', function(e) {
        if (e.key === 'Escape') {
            const openModal = document.querySelector('.modal:not(.hidden)');
            if (openModal) {
                closeModal(openModal.id);
            }
        }
    });
}

function openModal(modalId) {
    const modal = document.getElementById(modalId);
    if (modal) {
        modal.classList.remove('hidden');
        document.body.style.overflow = 'hidden';
    }
}

function closeModal(modalId) {
    const modal = document.getElementById(modalId);
    if (modal) {
        modal.classList.add('hidden');
        document.body.style.overflow = '';
    }
}

// User session (mock)
function initializeUserSession() {
    // Mock user data
    currentUser = {
        id: 1,
        name: 'Usuario Demo',
        email: 'demo@promowania.com',
        location: 'Bogotá',
        verified: true
    };
}

// Utility functions
function formatPrice(price) {
    return new Intl.NumberFormat('es-CO', {
        style: 'currency',
        currency: 'COP',
        minimumFractionDigits: 0
    }).format(price);
}

function formatDate(date) {
    return new Intl.DateTimeFormat('es-CO', {
        year: 'numeric',
        month: 'long',
        day: 'numeric'
    }).format(new Date(date));
}

function formatTimeAgo(date) {
    const now = new Date();
    const diff = now - new Date(date);
    const minutes = Math.floor(diff / (1000 * 60));
    const hours = Math.floor(diff / (1000 * 60 * 60));
    const days = Math.floor(diff / (1000 * 60 * 60 * 24));
    
    if (minutes < 60) {
        return `Hace ${minutes} min`;
    } else if (hours < 24) {
        return `Hace ${hours} hora${hours > 1 ? 's' : ''}`;
    } else {
        return `Hace ${days} día${days > 1 ? 's' : ''}`;
    }
}

function calculateDiscount(originalPrice, promoPrice) {
    if (originalPrice <= 0 || promoPrice < 0) return 0;
    return Math.round(((originalPrice - promoPrice) / originalPrice) * 100);
}

function showToast(title, message, type = 'info') {
    // Create toast element
    const toast = document.createElement('div');
    toast.className = `alert ${type}`;
    toast.style.cssText = `
        position: fixed;
        top: 100px;
        right: 20px;
        z-index: 3000;
        max-width: 400px;
        animation: slideInRight 0.3s ease;
    `;
    
    toast.innerHTML = `
        <strong>${title}</strong><br>
        ${message}
    `;
    
    document.body.appendChild(toast);
    
    // Remove toast after 5 seconds
    setTimeout(() => {
        toast.style.animation = 'slideOutRight 0.3s ease';
        setTimeout(() => {
            if (toast.parentNode) {
                toast.parentNode.removeChild(toast);
            }
        }, 300);
    }, 5000);
}

// Add slide animations
const style = document.createElement('style');
style.textContent = `
    @keyframes slideInRight {
        from { transform: translateX(100%); opacity: 0; }
        to { transform: translateX(0); opacity: 1; }
    }
    
    @keyframes slideOutRight {
        from { transform: translateX(0); opacity: 1; }
        to { transform: translateX(100%); opacity: 0; }
    }
`;
document.head.appendChild(style);

// API simulation functions
function simulateApiCall(data, delay = 1000) {
    return new Promise(resolve => {
        setTimeout(() => resolve(data), delay);
    });
}

// Error handling
window.addEventListener('error', function(e) {
    console.error('Error en la aplicación:', e.error);
    showToast('Error', 'Ocurrió un error inesperado. Por favor, recarga la página.', 'error');
});

// Export functions for use in other modules
window.PromoMania = {
    openModal,
    closeModal,
    addNotification,
    showToast,
    formatPrice,
    formatDate,
    formatTimeAgo,
    calculateDiscount,
    simulateApiCall,
    currentUser
};