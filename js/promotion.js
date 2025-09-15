// Promotion detail page functionality

let currentPromotion = null;
let currentImageIndex = 0;

document.addEventListener('DOMContentLoaded', function() {
    if (window.location.pathname.includes('promotion.html')) {
        initializePromotionDetail();
    }
});

function initializePromotionDetail() {
    // Get promotion ID from URL
    const urlParams = new URLSearchParams(window.location.search);
    const promotionId = urlParams.get('id');
    
    if (!promotionId) {
        showError('Promoción no encontrada');
        return;
    }
    
    // Load promotion data
    loadPromotionData(promotionId);
    
    // Initialize components
    initializeImageGallery();
    initializeVoting();
    initializeRating();
    initializeSharing();
    initializeReporting();
    
    console.log('Promotion detail initialized');
}

function loadPromotionData(promotionId) {
    // Get promotion from data
    const promotions = window.PromotionsModule ? window.PromotionsModule.promotionsData : [];
    currentPromotion = promotions.find(p => p.id == promotionId);
    
    if (!currentPromotion) {
        showError('Promoción no encontrada');
        return;
    }
    
    // Render promotion data
    renderPromotionData();
    loadSimilarPromotions();
    loadComments();
}

function renderPromotionData() {
    if (!currentPromotion) return;
    
    // Update breadcrumb
    document.getElementById('promotion-breadcrumb').textContent = currentPromotion.productName;
    
    // Update main content
    document.getElementById('promotion-title').textContent = currentPromotion.productName;
    document.getElementById('promotion-category').textContent = window.PromotionsModule.getCategoryName(currentPromotion.category);
    document.getElementById('promotion-store').textContent = window.PromotionsModule.getStoreName(currentPromotion.supermarket);
    document.getElementById('promotion-location').textContent = `${window.PromotionsModule.getCityName(currentPromotion.city)}, ${currentPromotion.neighborhood}`;
    
    // Update prices
    const formattedOriginalPrice = window.PromoMania ? window.PromoMania.formatPrice(currentPromotion.originalPrice) : `$${currentPromotion.originalPrice}`;
    const formattedPromoPrice = window.PromoMania ? window.PromoMania.formatPrice(currentPromotion.promoPrice) : `$${currentPromotion.promoPrice}`;
    const savings = currentPromotion.originalPrice - currentPromotion.promoPrice;
    const formattedSavings = window.PromoMania ? window.PromoMania.formatPrice(savings) : `$${savings}`;
    
    document.getElementById('original-price').textContent = formattedOriginalPrice;
    document.getElementById('promo-price').textContent = formattedPromoPrice;
    document.getElementById('discount-badge').textContent = `${currentPromotion.discountPercentage}% OFF`;
    document.getElementById('savings-amount').textContent = `Ahorras ${formattedSavings}`;
    
    // Update description
    document.getElementById('promotion-details').textContent = currentPromotion.description;
    
    // Update validity
    if (currentPromotion.endDate) {
        const startDate = window.PromoMania ? window.PromoMania.formatDate(currentPromotion.startDate) : currentPromotion.startDate;
        const endDate = window.PromoMania ? window.PromoMania.formatDate(currentPromotion.endDate) : currentPromotion.endDate;
        document.getElementById('validity-dates').textContent = `Del ${startDate} al ${endDate}`;
        
        // Check if still valid
        const today = new Date();
        const expiryDate = new Date(currentPromotion.endDate);
        const statusElement = document.getElementById('validity-status');
        
        if (today <= expiryDate) {
            statusElement.textContent = 'Vigente';
            statusElement.className = 'validity-status valid';
        } else {
            statusElement.textContent = 'Vencida';
            statusElement.className = 'validity-status expired';
        }
    } else {
        document.getElementById('validity-dates').textContent = 'Sin fecha de vencimiento específica';
        document.getElementById('validity-status').textContent = 'Vigente';
        document.getElementById('validity-status').className = 'validity-status valid';
    }
    
    // Update store info
    document.getElementById('store-name').textContent = `${window.PromotionsModule.getStoreName(currentPromotion.supermarket)} ${currentPromotion.neighborhood}`;
    document.getElementById('store-address').textContent = currentPromotion.storeAddress || 'Dirección no especificada';
    
    // Update validation stats
    document.getElementById('validation-score').textContent = currentPromotion.rating.toFixed(1);
    document.getElementById('validation-stars').innerHTML = renderStars(currentPromotion.rating);
    document.getElementById('total-votes').textContent = `${currentPromotion.votes.yes + currentPromotion.votes.no} votos`;
    document.getElementById('yes-count').textContent = currentPromotion.votes.yes;
    document.getElementById('no-count').textContent = currentPromotion.votes.no;
    
    // Update stats
    document.getElementById('view-count').textContent = currentPromotion.views;
    document.getElementById('publish-date').textContent = window.PromoMania ? window.PromoMania.formatTimeAgo(currentPromotion.created) : 'Reciente';
    document.getElementById('update-date').textContent = window.PromoMania ? window.PromoMania.formatTimeAgo(currentPromotion.updated) : 'Reciente';
    
    // Update images
    updateImageGallery();
    
    // Increment view count (simulation)
    currentPromotion.views++;
}

function updateImageGallery() {
    if (!currentPromotion || !currentPromotion.images) return;
    
    // Update main image
    const mainImage = document.getElementById('main-image');
    if (mainImage && currentPromotion.images.length > 0) {
        mainImage.src = currentPromotion.images[0];
        mainImage.alt = currentPromotion.productName;
    }
    
    // Update thumbnails
    const thumbnailGallery = document.getElementById('thumbnail-gallery');
    if (thumbnailGallery && currentPromotion.images.length > 1) {
        thumbnailGallery.innerHTML = currentPromotion.images.map((image, index) => `
            <div class="thumbnail ${index === 0 ? 'active' : ''}" onclick="changeMainImage(${index})">
                <img src="${image}" alt="Imagen ${index + 1}">
            </div>
        `).join('');
    }
}

function initializeImageGallery() {
    const prevBtn = document.querySelector('.prev-image');
    const nextBtn = document.querySelector('.next-image');
    
    if (prevBtn) {
        prevBtn.addEventListener('click', () => {
            if (currentPromotion && currentPromotion.images.length > 1) {
                currentImageIndex = (currentImageIndex - 1 + currentPromotion.images.length) % currentPromotion.images.length;
                changeMainImage(currentImageIndex);
            }
        });
    }
    
    if (nextBtn) {
        nextBtn.addEventListener('click', () => {
            if (currentPromotion && currentPromotion.images.length > 1) {
                currentImageIndex = (currentImageIndex + 1) % currentPromotion.images.length;
                changeMainImage(currentImageIndex);
            }
        });
    }
}

function changeMainImage(index) {
    if (!currentPromotion || !currentPromotion.images || index >= currentPromotion.images.length) return;
    
    currentImageIndex = index;
    
    // Update main image
    const mainImage = document.getElementById('main-image');
    mainImage.src = currentPromotion.images[index];
    
    // Update active thumbnail
    const thumbnails = document.querySelectorAll('.thumbnail');
    thumbnails.forEach((thumb, i) => {
        if (i === index) {
            thumb.classList.add('active');
        } else {
            thumb.classList.remove('active');
        }
    });
}

function initializeVoting() {
    const yesBtn = document.getElementById('vote-yes');
    const noBtn = document.getElementById('vote-no');
    
    if (yesBtn) {
        yesBtn.addEventListener('click', () => vote('yes'));
    }
    
    if (noBtn) {
        noBtn.addEventListener('click', () => vote('no'));
    }
    
    // Load user's previous vote
    loadUserVote();
}

function vote(voteType) {
    if (!currentPromotion) return;
    
    // Check if user already voted
    const userVote = getUserVote();
    
    if (userVote === voteType) {
        // Remove vote
        removeVote();
        return;
    }
    
    if (userVote && userVote !== voteType) {
        // Change vote
        removeVote();
    }
    
    // Add new vote
    currentPromotion.votes[voteType]++;
    saveUserVote(voteType);
    updateVoteDisplay();
    
    // Show feedback
    if (window.PromoMania) {
        const message = voteType === 'yes' ? 'Gracias por validar esta promoción' : 'Gracias por tu feedback';
        window.PromoMania.showToast('Voto registrado', message, 'success');
    }
}

function removeVote() {
    if (!currentPromotion) return;
    
    const userVote = getUserVote();
    if (userVote) {
        currentPromotion.votes[userVote]--;
        removeUserVote();
        updateVoteDisplay();
    }
}

function getUserVote() {
    return localStorage.getItem(`vote_${currentPromotion.id}`);
}

function saveUserVote(voteType) {
    localStorage.setItem(`vote_${currentPromotion.id}`, voteType);
}

function removeUserVote() {
    localStorage.removeItem(`vote_${currentPromotion.id}`);
}

function loadUserVote() {
    const userVote = getUserVote();
    updateVoteDisplay(userVote);
}

function updateVoteDisplay(userVote = null) {
    if (!currentPromotion) return;
    
    if (userVote === null) {
        userVote = getUserVote();
    }
    
    // Update vote counts
    document.getElementById('yes-count').textContent = currentPromotion.votes.yes;
    document.getElementById('no-count').textContent = currentPromotion.votes.no;
    document.getElementById('total-votes').textContent = `${currentPromotion.votes.yes + currentPromotion.votes.no} votos`;
    
    // Update button states
    const yesBtn = document.getElementById('vote-yes');
    const noBtn = document.getElementById('vote-no');
    
    yesBtn.classList.remove('voted');
    noBtn.classList.remove('voted');
    
    if (userVote === 'yes') {
        yesBtn.classList.add('voted');
    } else if (userVote === 'no') {
        noBtn.classList.add('voted');
    }
    
    // Recalculate rating
    const totalVotes = currentPromotion.votes.yes + currentPromotion.votes.no;
    if (totalVotes > 0) {
        currentPromotion.rating = (currentPromotion.votes.yes / totalVotes) * 5;
        document.getElementById('validation-score').textContent = currentPromotion.rating.toFixed(1);
        document.getElementById('validation-stars').innerHTML = renderStars(currentPromotion.rating);
    }
}

function initializeRating() {
    const stars = document.querySelectorAll('#user-rating-stars i');
    let userRating = getUserRating();
    
    stars.forEach((star, index) => {
        star.addEventListener('click', function() {
            const rating = index + 1;
            setUserRating(rating);
        });
        
        star.addEventListener('mouseenter', function() {
            highlightStars(index + 1);
        });
    });
    
    document.getElementById('user-rating-stars').addEventListener('mouseleave', function() {
        highlightStars(userRating);
    });
    
    // Set initial rating display
    highlightStars(userRating);
}

function setUserRating(rating) {
    if (!currentPromotion) return;
    
    saveUserRating(rating);
    highlightStars(rating);
    
    if (window.PromoMania) {
        window.PromoMania.showToast('Calificación guardada', `Has calificado esta promoción con ${rating} estrella${rating > 1 ? 's' : ''}`, 'success');
    }
}

function highlightStars(rating) {
    const stars = document.querySelectorAll('#user-rating-stars i');
    stars.forEach((star, index) => {
        if (index < rating) {
            star.className = 'fas fa-star active';
        } else {
            star.className = 'far fa-star';
        }
    });
}

function getUserRating() {
    return parseInt(localStorage.getItem(`rating_${currentPromotion.id}`)) || 0;
}

function saveUserRating(rating) {
    localStorage.setItem(`rating_${currentPromotion.id}`, rating);
}

function initializeSharing() {
    const shareBtn = document.getElementById('share-btn');
    if (shareBtn) {
        shareBtn.addEventListener('click', () => {
            if (window.PromoMania) {
                window.PromoMania.openModal('share-modal');
            }
        });
    }
}

function sharePromotion(platform) {
    if (!currentPromotion) return;
    
    const url = window.location.href;
    const text = `¡Mira esta promoción! ${currentPromotion.productName} con ${currentPromotion.discountPercentage}% de descuento en ${window.PromotionsModule.getStoreName(currentPromotion.supermarket)}`;
    
    const shareUrls = {
        whatsapp: `https://wa.me/?text=${encodeURIComponent(text + ' ' + url)}`,
        facebook: `https://www.facebook.com/sharer/sharer.php?u=${encodeURIComponent(url)}`,
        twitter: `https://twitter.com/intent/tweet?text=${encodeURIComponent(text)}&url=${encodeURIComponent(url)}`
    };
    
    if (shareUrls[platform]) {
        window.open(shareUrls[platform], '_blank', 'width=600,height=400');
    }
    
    if (window.PromoMania) {
        window.PromoMania.closeModal('share-modal');
    }
}

function copyLink() {
    const url = window.location.href;
    
    navigator.clipboard.writeText(url).then(() => {
        if (window.PromoMania) {
            window.PromoMania.showToast('Enlace copiado', 'El enlace se copió al portapapeles', 'success');
            window.PromoMania.closeModal('share-modal');
        }
    });
}

function initializeReporting() {
    const reportBtn = document.getElementById('report-btn');
    if (reportBtn) {
        reportBtn.addEventListener('click', () => {
            if (window.PromoMania) {
                window.PromoMania.openModal('report-modal');
            }
        });
    }
    
    const reportForm = document.getElementById('report-form');
    if (reportForm) {
        reportForm.addEventListener('submit', handleReport);
    }
}

function handleReport(e) {
    e.preventDefault();
    
    const reason = document.getElementById('report-reason').value;
    const details = document.getElementById('report-details').value;
    
    if (!reason) {
        if (window.PromoMania) {
            window.PromoMania.showToast('Error', 'Por favor selecciona un motivo para el reporte', 'error');
        }
        return;
    }
    
    // Simulate sending report
    console.log('Report submitted:', { promotionId: currentPromotion.id, reason, details });
    
    if (window.PromoMania) {
        window.PromoMania.showToast('Reporte enviado', 'Gracias por tu reporte. Lo revisaremos pronto.', 'success');
        window.PromoMania.closeModal('report-modal');
    }
    
    // Reset form
    e.target.reset();
}

function loadSimilarPromotions() {
    if (!currentPromotion) return;
    
    const allPromotions = window.PromotionsModule ? window.PromotionsModule.promotionsData : [];
    
    // Find similar promotions
    const similar = allPromotions
        .filter(p => p.id !== currentPromotion.id)
        .filter(p => 
            p.category === currentPromotion.category || 
            p.supermarket === currentPromotion.supermarket ||
            p.brand === currentPromotion.brand
        )
        .sort((a, b) => b.rating - a.rating)
        .slice(0, 3);
    
    renderSimilarPromotions(similar);
}

function renderSimilarPromotions(promotions) {
    const container = document.getElementById('similar-promotions-list');
    if (!container) return;
    
    if (promotions.length === 0) {
        container.innerHTML = '<p>No hay promociones similares disponibles.</p>';
        return;
    }
    
    container.innerHTML = promotions.map(promotion => {
        const formattedPrice = window.PromoMania ? window.PromoMania.formatPrice(promotion.promoPrice) : `$${promotion.promoPrice}`;
        
        return `
            <div class="similar-item" onclick="window.location.href='promotion.html?id=${promotion.id}'">
                <div class="similar-image">
                    <img src="${promotion.images[0]}" alt="${promotion.productName}">
                </div>
                <div class="similar-info">
                    <div class="similar-title">${promotion.productName}</div>
                    <div class="similar-price">${formattedPrice} (-${promotion.discountPercentage}%)</div>
                </div>
            </div>
        `;
    }).join('');
}

function loadComments() {
    // Mock comments data
    const comments = [
        {
            id: 1,
            author: 'María González',
            date: '2024-09-14T10:30:00Z',
            text: 'Excelente promoción! Pude conseguir el aceite a este precio en la tienda de Chapinero. Totalmente recomendado.',
            helpful: 5
        },
        {
            id: 2,
            author: 'Carlos Ruiz',
            date: '2024-09-14T15:20:00Z',
            text: 'Confirmo que la promoción es real. Aproveché y compré varios para tener stock en casa.',
            helpful: 3
        },
        {
            id: 3,
            author: 'Ana Martínez',
            date: '2024-09-13T20:45:00Z',
            text: 'Me pareció un buen descuento, pero hay que verificar las fechas de vencimiento del producto.',
            helpful: 2
        }
    ];
    
    renderComments(comments);
}

function renderComments(comments) {
    const container = document.getElementById('comments-list');
    if (!container) return;
    
    if (comments.length === 0) {
        container.innerHTML = '<p>No hay comentarios aún. ¡Sé el primero en comentar!</p>';
        return;
    }
    
    container.innerHTML = comments.map(comment => {
        const timeAgo = window.PromoMania ? window.PromoMania.formatTimeAgo(comment.date) : 'Reciente';
        
        return `
            <div class="comment-item">
                <div class="comment-header">
                    <span class="comment-author">${comment.author}</span>
                    <span class="comment-date">${timeAgo}</span>
                </div>
                <div class="comment-text">${comment.text}</div>
                <div class="comment-actions">
                    <button class="comment-action" onclick="likeComment(${comment.id})">
                        <i class="far fa-thumbs-up"></i> Útil (${comment.helpful})
                    </button>
                    <button class="comment-action">
                        <i class="far fa-reply"></i> Responder
                    </button>
                </div>
            </div>
        `;
    }).join('');
}

function likeComment(commentId) {
    if (window.PromoMania) {
        window.PromoMania.showToast('Voto registrado', 'Gracias por marcar este comentario como útil', 'success');
    }
}

function showError(message) {
    document.body.innerHTML = `
        <div style="text-align: center; padding: 4rem; color: #666;">
            <i class="fas fa-exclamation-triangle" style="font-size: 4rem; margin-bottom: 2rem; color: #dc3545;"></i>
            <h2>Error</h2>
            <p>${message}</p>
            <a href="index.html" class="btn btn-primary" style="margin-top: 2rem;">Volver al Inicio</a>
        </div>
    `;
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

// Global functions for HTML onclick handlers
window.changeMainImage = changeMainImage;
window.sharePromotion = sharePromotion;
window.copyLink = copyLink;
window.likeComment = likeComment;

// Export for use in other modules
window.PromotionDetailModule = {
    currentPromotion,
    loadPromotionData,
    vote,
    setUserRating
};