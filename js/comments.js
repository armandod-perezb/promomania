// Comments functionality

let comments = [];
let commentsPage = 1;
const commentsPerPage = 10;

document.addEventListener('DOMContentLoaded', function() {
    if (document.getElementById('comment-form')) {
        initializeComments();
    }
});

function initializeComments() {
    // Initialize comment form
    const commentForm = document.getElementById('comment-form');
    if (commentForm) {
        commentForm.addEventListener('submit', handleCommentSubmission);
    }
    
    // Initialize load more button
    const loadMoreBtn = document.getElementById('load-more-comments');
    if (loadMoreBtn) {
        loadMoreBtn.addEventListener('click', loadMoreComments);
    }
    
    // Load initial comments
    loadInitialComments();
    
    console.log('Comments system initialized');
}

function loadInitialComments() {
    // Mock comments data for the promotion
    comments = [
        {
            id: 1,
            author: 'María González',
            avatar: 'https://ui-avatars.com/api/?name=Maria+Gonzalez&background=007bff&color=fff',
            date: '2024-09-14T10:30:00Z',
            text: 'Excelente promoción! Pude conseguir el aceite a este precio en la tienda de Chapinero. La calidad es muy buena y el descuento realmente vale la pena. Totalmente recomendado para quienes buscan aceite de oliva de calidad.',
            helpful: 5,
            replies: 2,
            verified: true
        },
        {
            id: 2,
            author: 'Carlos Ruiz',
            avatar: 'https://ui-avatars.com/api/?name=Carlos+Ruiz&background=28a745&color=fff',
            date: '2024-09-14T15:20:00Z',
            text: 'Confirmo que la promoción es real. Aproveché y compré varios para tener stock en casa. El personal de la tienda me comentó que la promoción durará hasta fin de mes, así que hay tiempo para aprovecharla.',
            helpful: 3,
            replies: 1,
            verified: false
        },
        {
            id: 3,
            author: 'Ana Martínez',
            avatar: 'https://ui-avatars.com/api/?name=Ana+Martinez&background=dc3545&color=fff',
            date: '2024-09-13T20:45:00Z',
            text: 'Me pareció un buen descuento, pero hay que verificar las fechas de vencimiento del producto. Algunos aceites que encontré tenían fechas muy próximas. Aún así, el precio está muy bien.',
            helpful: 8,
            replies: 0,
            verified: false
        },
        {
            id: 4,
            author: 'Luis Hernández',
            avatar: 'https://ui-avatars.com/api/?name=Luis+Hernandez&background=ffc107&color=000',
            date: '2024-09-13T14:15:00Z',
            text: 'Fui ayer por la tarde y ya no tenían en stock. Según me dijeron, se agotó muy rápido por el buen precio. Esperaré a que repongan para aprovechar la promoción.',
            helpful: 2,
            replies: 3,
            verified: false
        },
        {
            id: 5,
            author: 'Sandra López',
            avatar: 'https://ui-avatars.com/api/?name=Sandra+Lopez&background=6f42c1&color=fff',
            date: '2024-09-12T18:30:00Z',
            text: 'Perfecto! Justo necesitaba aceite de oliva y con este descuento me sale súper conveniente. Gracias por compartir la promoción, es exactamente lo que estaba buscando.',
            helpful: 1,
            replies: 0,
            verified: true
        }
    ];
    
    renderComments();
    updateLoadMoreButton();
}

function renderComments() {
    const container = document.getElementById('comments-list');
    if (!container) return;
    
    if (comments.length === 0) {
        container.innerHTML = `
            <div class="no-comments">
                <i class="far fa-comment"></i>
                <h4>No hay comentarios aún</h4>
                <p>¡Sé el primero en compartir tu experiencia con esta promoción!</p>
            </div>
        `;
        return;
    }
    
    // Calculate which comments to show
    const endIndex = commentsPage * commentsPerPage;
    const visibleComments = comments.slice(0, endIndex);
    
    container.innerHTML = visibleComments.map(comment => createCommentHTML(comment)).join('');
    
    // Add event listeners to new comments
    addCommentEventListeners(container);
}

function createCommentHTML(comment) {
    const timeAgo = window.PromoMania ? window.PromoMania.formatTimeAgo(comment.date) : 'Reciente';
    const userHelpfulVote = getUserHelpfulVote(comment.id);
    
    return `
        <div class="comment-item" data-id="${comment.id}">
            <div class="comment-avatar">
                <img src="${comment.avatar}" alt="${comment.author}">
                ${comment.verified ? '<div class="verified-badge"><i class="fas fa-check-circle"></i></div>' : ''}
            </div>
            <div class="comment-content">
                <div class="comment-header">
                    <span class="comment-author">
                        ${comment.author}
                        ${comment.verified ? '<i class="fas fa-badge-check verified-icon" title="Usuario verificado"></i>' : ''}
                    </span>
                    <span class="comment-date">${timeAgo}</span>
                </div>
                <div class="comment-text">${comment.text}</div>
                <div class="comment-actions">
                    <button class="comment-action helpful-btn ${userHelpfulVote ? 'voted' : ''}" data-id="${comment.id}">
                        <i class="far fa-thumbs-up"></i> 
                        <span>Útil</span>
                        <span class="helpful-count">(${comment.helpful})</span>
                    </button>
                    <button class="comment-action reply-btn" data-id="${comment.id}">
                        <i class="far fa-reply"></i> Responder
                    </button>
                    ${comment.replies > 0 ? `
                        <button class="comment-action view-replies-btn" data-id="${comment.id}">
                            <i class="far fa-comments"></i> Ver ${comment.replies} respuesta${comment.replies > 1 ? 's' : ''}
                        </button>
                    ` : ''}
                    <button class="comment-action report-comment-btn" data-id="${comment.id}">
                        <i class="far fa-flag"></i> Reportar
                    </button>
                </div>
                <div class="reply-form-container" id="reply-form-${comment.id}" style="display: none;">
                    <form class="reply-form" data-parent-id="${comment.id}">
                        <textarea placeholder="Escribe tu respuesta..." rows="3" required></textarea>
                        <div class="reply-actions">
                            <button type="button" class="btn btn-secondary cancel-reply">Cancelar</button>
                            <button type="submit" class="btn btn-primary">Responder</button>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    `;
}

function addCommentEventListeners(container) {
    // Helpful votes
    container.querySelectorAll('.helpful-btn').forEach(btn => {
        btn.addEventListener('click', function() {
            const commentId = parseInt(this.dataset.id);
            toggleHelpfulVote(commentId, this);
        });
    });
    
    // Reply buttons
    container.querySelectorAll('.reply-btn').forEach(btn => {
        btn.addEventListener('click', function() {
            const commentId = parseInt(this.dataset.id);
            toggleReplyForm(commentId);
        });
    });
    
    // Cancel reply buttons
    container.querySelectorAll('.cancel-reply').forEach(btn => {
        btn.addEventListener('click', function() {
            const form = this.closest('.reply-form-container');
            form.style.display = 'none';
        });
    });
    
    // Reply form submissions
    container.querySelectorAll('.reply-form').forEach(form => {
        form.addEventListener('submit', function(e) {
            e.preventDefault();
            const parentId = parseInt(this.dataset.parentId);
            const text = this.querySelector('textarea').value.trim();
            if (text) {
                submitReply(parentId, text, this);
            }
        });
    });
    
    // View replies buttons
    container.querySelectorAll('.view-replies-btn').forEach(btn => {
        btn.addEventListener('click', function() {
            const commentId = parseInt(this.dataset.id);
            loadReplies(commentId);
        });
    });
    
    // Report comment buttons
    container.querySelectorAll('.report-comment-btn').forEach(btn => {
        btn.addEventListener('click', function() {
            const commentId = parseInt(this.dataset.id);
            reportComment(commentId);
        });
    });
}

function handleCommentSubmission(e) {
    e.preventDefault();
    
    const textarea = document.getElementById('comment-text');
    const text = textarea.value.trim();
    
    if (!text) {
        if (window.PromoMania) {
            window.PromoMania.showToast('Error', 'Por favor escribe un comentario', 'error');
        }
        return;
    }
    
    if (text.length < 10) {
        if (window.PromoMania) {
            window.PromoMania.showToast('Error', 'El comentario debe tener al menos 10 caracteres', 'error');
        }
        return;
    }
    
    // Show loading state
    const submitBtn = e.target.querySelector('button[type="submit"]');
    const originalText = submitBtn.innerHTML;
    submitBtn.disabled = true;
    submitBtn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Publicando...';
    
    // Simulate API call
    setTimeout(() => {
        const newComment = {
            id: Date.now(),
            author: window.PromoMania?.currentUser?.name || 'Usuario Anónimo',
            avatar: `https://ui-avatars.com/api/?name=${encodeURIComponent(window.PromoMania?.currentUser?.name || 'Usuario Anonimo')}&background=007bff&color=fff`,
            date: new Date().toISOString(),
            text: text,
            helpful: 0,
            replies: 0,
            verified: window.PromoMania?.currentUser?.verified || false
        };
        
        // Add to beginning of comments array
        comments.unshift(newComment);
        
        // Re-render comments
        renderComments();
        
        // Clear form
        textarea.value = '';
        
        // Show success message
        if (window.PromoMania) {
            window.PromoMania.showToast('Comentario publicado', 'Tu comentario ha sido publicado exitosamente', 'success');
            window.PromoMania.addNotification(
                'Comentario publicado',
                'Tu comentario en la promoción está visible para la comunidad',
                'comment'
            );
        }
        
        // Restore button
        submitBtn.disabled = false;
        submitBtn.innerHTML = originalText;
        
        // Scroll to new comment
        setTimeout(() => {
            const newCommentElement = document.querySelector(`[data-id="${newComment.id}"]`);
            if (newCommentElement) {
                newCommentElement.scrollIntoView({ behavior: 'smooth', block: 'center' });
                newCommentElement.style.backgroundColor = '#e3f2fd';
                setTimeout(() => {
                    newCommentElement.style.backgroundColor = '';
                }, 2000);
            }
        }, 100);
        
    }, 1000);
}

function toggleHelpfulVote(commentId, button) {
    const comment = comments.find(c => c.id === commentId);
    if (!comment) return;
    
    const userVoted = getUserHelpfulVote(commentId);
    
    if (userVoted) {
        // Remove vote
        comment.helpful--;
        removeUserHelpfulVote(commentId);
        button.classList.remove('voted');
        
        if (window.PromoMania) {
            window.PromoMania.showToast('Voto removido', 'Has removido tu voto útil', 'info');
        }
    } else {
        // Add vote
        comment.helpful++;
        saveUserHelpfulVote(commentId);
        button.classList.add('voted');
        
        if (window.PromoMania) {
            window.PromoMania.showToast('Voto registrado', 'Gracias por marcar este comentario como útil', 'success');
        }
    }
    
    // Update count display
    button.querySelector('.helpful-count').textContent = `(${comment.helpful})`;
}

function toggleReplyForm(commentId) {
    const replyContainer = document.getElementById(`reply-form-${commentId}`);
    
    // Hide all other reply forms
    document.querySelectorAll('.reply-form-container').forEach(container => {
        if (container.id !== `reply-form-${commentId}`) {
            container.style.display = 'none';
        }
    });
    
    // Toggle current reply form
    if (replyContainer.style.display === 'none') {
        replyContainer.style.display = 'block';
        replyContainer.querySelector('textarea').focus();
    } else {
        replyContainer.style.display = 'none';
    }
}

function submitReply(parentId, text, form) {
    const comment = comments.find(c => c.id === parentId);
    if (!comment) return;
    
    // Show loading
    const submitBtn = form.querySelector('button[type="submit"]');
    const originalText = submitBtn.textContent;
    submitBtn.disabled = true;
    submitBtn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Respondiendo...';
    
    // Simulate API call
    setTimeout(() => {
        // Increment replies count
        comment.replies++;
        
        // Clear form and hide
        form.querySelector('textarea').value = '';
        form.closest('.reply-form-container').style.display = 'none';
        
        // Update display
        renderComments();
        
        // Show success
        if (window.PromoMania) {
            window.PromoMania.showToast('Respuesta publicada', 'Tu respuesta ha sido publicada', 'success');
        }
        
        // Restore button
        submitBtn.disabled = false;
        submitBtn.textContent = originalText;
        
    }, 800);
}

function loadReplies(commentId) {
    // Mock replies data
    const replies = [
        {
            id: 101,
            parentId: commentId,
            author: 'Pedro García',
            avatar: 'https://ui-avatars.com/api/?name=Pedro+Garcia&background=17a2b8&color=fff',
            date: '2024-09-14T11:00:00Z',
            text: 'Totalmente de acuerdo! Yo también aproveché esta promoción.',
            helpful: 1
        }
    ];
    
    // For demo purposes, just show a message
    if (window.PromoMania) {
        window.PromoMania.showToast('Cargando respuestas', 'Esta funcionalidad se implementaría con la API backend', 'info');
    }
}

function reportComment(commentId) {
    const comment = comments.find(c => c.id === commentId);
    if (!comment) return;
    
    const reason = prompt('¿Por qué quieres reportar este comentario?\n\n1. Spam\n2. Contenido inapropiado\n3. Información falsa\n4. Otro\n\nEscribe el número correspondiente:');
    
    if (reason) {
        // Simulate report submission
        if (window.PromoMania) {
            window.PromoMania.showToast('Reporte enviado', 'Gracias por reportar. Revisaremos el comentario.', 'success');
        }
        
        console.log('Comment reported:', { commentId, reason });
    }
}

function loadMoreComments() {
    commentsPage++;
    renderComments();
    updateLoadMoreButton();
    
    if (window.PromoMania) {
        window.PromoMania.showToast('Comentarios cargados', 'Se han cargado más comentarios', 'info');
    }
}

function updateLoadMoreButton() {
    const loadMoreBtn = document.getElementById('load-more-comments');
    if (!loadMoreBtn) return;
    
    const totalVisible = commentsPage * commentsPerPage;
    
    if (totalVisible >= comments.length) {
        loadMoreBtn.style.display = 'none';
    } else {
        loadMoreBtn.style.display = 'block';
        const remaining = comments.length - totalVisible;
        loadMoreBtn.textContent = `Cargar ${Math.min(remaining, commentsPerPage)} comentarios más`;
    }
}

// Local storage helpers for user votes
function getUserHelpfulVote(commentId) {
    const votes = JSON.parse(localStorage.getItem('helpfulVotes') || '{}');
    return votes[commentId] || false;
}

function saveUserHelpfulVote(commentId) {
    const votes = JSON.parse(localStorage.getItem('helpfulVotes') || '{}');
    votes[commentId] = true;
    localStorage.setItem('helpfulVotes', JSON.stringify(votes));
}

function removeUserHelpfulVote(commentId) {
    const votes = JSON.parse(localStorage.getItem('helpfulVotes') || '{}');
    delete votes[commentId];
    localStorage.setItem('helpfulVotes', JSON.stringify(votes));
}

// Comment filtering and sorting
function filterComments(filter) {
    let filteredComments = [...comments];
    
    switch (filter) {
        case 'newest':
            filteredComments.sort((a, b) => new Date(b.date) - new Date(a.date));
            break;
        case 'oldest':
            filteredComments.sort((a, b) => new Date(a.date) - new Date(b.date));
            break;
        case 'most-helpful':
            filteredComments.sort((a, b) => b.helpful - a.helpful);
            break;
        case 'verified-only':
            filteredComments = filteredComments.filter(c => c.verified);
            break;
        default:
            break;
    }
    
    comments = filteredComments;
    commentsPage = 1;
    renderComments();
    updateLoadMoreButton();
}

// Comment search
function searchComments(query) {
    if (!query.trim()) {
        loadInitialComments();
        return;
    }
    
    const searchResults = comments.filter(comment => 
        comment.text.toLowerCase().includes(query.toLowerCase()) ||
        comment.author.toLowerCase().includes(query.toLowerCase())
    );
    
    comments = searchResults;
    commentsPage = 1;
    renderComments();
    updateLoadMoreButton();
}

// Comment moderation (for admin users)
function moderateComment(commentId, action) {
    const comment = comments.find(c => c.id === commentId);
    if (!comment) return;
    
    switch (action) {
        case 'delete':
            comments = comments.filter(c => c.id !== commentId);
            break;
        case 'hide':
            comment.hidden = true;
            break;
        case 'feature':
            comment.featured = true;
            break;
    }
    
    renderComments();
    
    if (window.PromoMania) {
        window.PromoMania.showToast('Acción realizada', `Comentario ${action === 'delete' ? 'eliminado' : action === 'hide' ? 'ocultado' : 'destacado'}`, 'success');
    }
}

// Export for use in other modules
window.CommentsModule = {
    comments,
    loadInitialComments,
    handleCommentSubmission,
    filterComments,
    searchComments,
    moderateComment
};