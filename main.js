// Main JavaScript functionality for Promomanía

document.addEventListener('DOMContentLoaded', function() {
  // Initialize Bootstrap components
  const addPromoModalEl = document.getElementById('addPromoModal');
  const addPromoModal = new bootstrap.Modal(addPromoModalEl);
  
  // Navbar scroll effect
  const navbar = document.querySelector('header.navbar');
  window.addEventListener('scroll', () => {
    if (window.scrollY > 50) {
      navbar.classList.add('scrolled');
    } else {
      navbar.classList.remove('scrolled');
    }
  });
  
  // Add event listeners for filter changes
  const categoryFilter = document.getElementById('categoryFilter');
  const cityFilter = document.getElementById('cityFilter');
  const storeFilter = document.getElementById('storeFilter');
  const discountFilter = document.getElementById('discountFilter');
  const searchInput = document.querySelector('.search-form input');
  
  // Filter change event handler
  function applyFilters() {
    const selectedCategory = categoryFilter.value;
    const selectedCity = cityFilter.value;
    const selectedStore = storeFilter.value;
    const selectedDiscount = discountFilter.value;
    const searchQuery = searchInput.value.toLowerCase();
    
    // Get all promotion cards
    const promoCards = document.querySelectorAll('#promotionsGrid .col');
    
    // Count filtered results
    let visibleCount = 0;
    
    promoCards.forEach(card => {
      // In a real implementation, we would check each card against filters
      // For demo purposes, show all cards except when specific filters are set
      let shouldShow = true;
      
      // If we have specific filter values, randomly hide some cards to simulate filtering
      if (selectedCategory !== 'Todos' || selectedCity !== 'Todas' || 
          selectedStore !== 'Todos' || parseInt(selectedDiscount) > 0 || 
          searchQuery.length > 0) {
        // Randomly hide some cards based on filter values
        shouldShow = Math.random() > 0.3;
      }
      
      // Show or hide card based on filter match
      if (shouldShow) {
        card.style.display = '';
        visibleCount++;
        
        // Add animation effect to visible cards
        card.classList.add('animate__animated', 'animate__fadeIn');
        setTimeout(() => {
          card.classList.remove('animate__animated', 'animate__fadeIn');
        }, 500);
      } else {
        card.style.display = 'none';
      }
    });
    
    // Update results title based on search/filters
    const resultsTitle = document.getElementById('resultsTitle');
    if (searchQuery || selectedCategory !== 'Todos' || 
        selectedCity !== 'Todas' || selectedStore !== 'Todos' ||
        selectedDiscount !== '0') {
      resultsTitle.textContent = 'Resultados de búsqueda';
    } else {
      resultsTitle.textContent = 'Promociones destacadas';
    }
    
    // Update the results count
    const resultsCount = document.getElementById('resultsCount');
    resultsCount.textContent = `${visibleCount} promociones encontradas`;
    
    // Show/hide appropriate message
    const promotionsGrid = document.getElementById('promotionsGrid');
    const noResultsMessage = document.getElementById('noResultsMessage');
    
    if (visibleCount === 0) {
      promotionsGrid.classList.add('d-none');
      noResultsMessage.classList.remove('d-none');
    } else {
      promotionsGrid.classList.remove('d-none');
      noResultsMessage.classList.add('d-none');
    }
  }
  
  // Clear filters function
  function clearFilters() {
    categoryFilter.value = 'Todos';
    cityFilter.value = 'Todas';
    storeFilter.value = 'Todos';
    discountFilter.value = '0';
    searchInput.value = '';
    applyFilters();
  }
  
  // Add event listeners
  if (categoryFilter) categoryFilter.addEventListener('change', applyFilters);
  if (cityFilter) cityFilter.addEventListener('change', applyFilters);
  if (storeFilter) storeFilter.addEventListener('change', applyFilters);
  if (discountFilter) discountFilter.addEventListener('change', applyFilters);
  if (searchInput) searchInput.addEventListener('input', applyFilters);
  
  // Clear filters buttons
  const clearFiltersBtn = document.getElementById('clearFilters');
  const resetFiltersBtn = document.getElementById('resetFiltersBtn');
  if (clearFiltersBtn) clearFiltersBtn.addEventListener('click', clearFilters);
  if (resetFiltersBtn) resetFiltersBtn.addEventListener('click', clearFilters);
  
  // Handle form submission for new promotions
  const addPromoForm = document.getElementById('addPromoForm');
  if (addPromoForm) {
    addPromoForm.addEventListener('submit', function(event) {
      event.preventDefault();
      
      // In a real app, we would process form data here and add the new promotion
      // For this demo, we'll just close the modal
      addPromoModal.hide();
      
      // Create a toast notification
      createToast('¡Promoción agregada con éxito!', 'success');
    });
  }
  
  // Handle click on "Agregar Promoción" buttons
  const addPromoButtons = document.querySelectorAll('.btn-orange');
  addPromoButtons.forEach(button => {
    if (button.textContent.trim() === 'Agregar Promoción') {
      button.addEventListener('click', function() {
        addPromoModal.show();
      });
    }
  });
  
  // Handle voting buttons
  const voteButtons = document.querySelectorAll('.card-footer .btn');
  voteButtons.forEach(button => {
    button.addEventListener('click', function() {
      // Get current count from button text
      const countElement = this.textContent.trim().split(' ')[1];
      const count = parseInt(countElement || '0');
      
      // Update count and add visual feedback
      const icon = this.querySelector('i');
      if (icon.classList.contains('fa-thumbs-up') || icon.classList.contains('fa-thumbs-down')) {
        this.innerHTML = `<i class="${icon.className}"></i> ${count + 1}`;
        
        // Add a temporary highlight effect
        this.classList.add('active', 'btn-orange', 'text-white');
        this.classList.remove('btn-outline-secondary');
        
        setTimeout(() => {
          this.classList.remove('active', 'btn-orange', 'text-white');
          this.classList.add('btn-outline-secondary');
        }, 500);
        
        createToast('¡Gracias por tu voto!', 'info');
      }
    });
  });
  
  // Helper function to create toast notifications
  function createToast(message, type = 'info') {
    // Create toast container if it doesn't exist
    let toastContainer = document.querySelector('.toast-container');
    if (!toastContainer) {
      toastContainer = document.createElement('div');
      toastContainer.className = 'toast-container position-fixed bottom-0 end-0 p-3';
      document.body.appendChild(toastContainer);
    }
    
    // Create toast element
    const toastEl = document.createElement('div');
    toastEl.className = `toast align-items-center text-white bg-${type === 'success' ? 'success' : 'primary'} border-0`;
    toastEl.setAttribute('role', 'alert');
    toastEl.setAttribute('aria-live', 'assertive');
    toastEl.setAttribute('aria-atomic', 'true');
    
    // Toast content
    toastEl.innerHTML = `
      <div class="d-flex">
        <div class="toast-body">
          <i class="fas fa-${type === 'success' ? 'check-circle' : 'info-circle'} me-2"></i>
          ${message}
        </div>
        <button type="button" class="btn-close btn-close-white me-2 m-auto" data-bs-dismiss="toast" aria-label="Close"></button>
      </div>
    `;
    
    // Add toast to container
    toastContainer.appendChild(toastEl);
    
    // Initialize and show toast
    const toast = new bootstrap.Toast(toastEl, {
      animation: true,
      autohide: true,
      delay: 3000
    });
    
    toast.show();
    
    // Remove from DOM after hidden
    toastEl.addEventListener('hidden.bs.toast', function() {
      this.remove();
    });
  }
  
  // Initialize tooltips if available
  if (typeof bootstrap.Tooltip !== 'undefined') {
    var tooltipTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="tooltip"]'));
    tooltipTriggerList.map(function (tooltipTriggerEl) {
      return new bootstrap.Tooltip(tooltipTriggerEl);
    });
  }
});
