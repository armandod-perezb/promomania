// Publish promotion functionality

document.addEventListener('DOMContentLoaded', function() {
    if (document.getElementById('publish-promotion-form')) {
        initializePublishForm();
    }
});

function initializePublishForm() {
    const form = document.getElementById('publish-promotion-form');
    if (!form) return;
    
    // Initialize form components
    initializePriceCalculation();
    initializeFileUpload();
    initializeDependentFields();
    initializeFormValidation();
    
    // Form submission
    form.addEventListener('submit', handleFormSubmission);
    
    console.log('Publish form initialized');
}

function initializePriceCalculation() {
    const originalPriceInput = document.getElementById('original-price');
    const promoPriceInput = document.getElementById('promo-price');
    const discountDisplay = document.getElementById('discount-display');
    
    function updateDiscount() {
        const originalPrice = parseFloat(originalPriceInput.value) || 0;
        const promoPrice = parseFloat(promoPriceInput.value) || 0;
        
        if (originalPrice > 0 && promoPrice >= 0 && promoPrice < originalPrice) {
            const discount = Math.round(((originalPrice - promoPrice) / originalPrice) * 100);
            discountDisplay.textContent = `${discount}%`;
            discountDisplay.style.color = discount >= 50 ? '#dc3545' : '#28a745';
        } else {
            discountDisplay.textContent = '0%';
            discountDisplay.style.color = '#6c757d';
        }
    }
    
    originalPriceInput.addEventListener('input', updateDiscount);
    promoPriceInput.addEventListener('input', updateDiscount);
}

function initializeFileUpload() {
    const uploadArea = document.getElementById('photo-upload-area');
    const photoInput = document.getElementById('photo-input');
    const photoPreview = document.getElementById('photo-preview');
    
    let uploadedFiles = [];
    
    // Click to upload
    uploadArea.addEventListener('click', () => photoInput.click());
    
    // Drag and drop functionality
    uploadArea.addEventListener('dragover', function(e) {
        e.preventDefault();
        this.classList.add('dragover');
    });
    
    uploadArea.addEventListener('dragleave', function(e) {
        e.preventDefault();
        this.classList.remove('dragover');
    });
    
    uploadArea.addEventListener('drop', function(e) {
        e.preventDefault();
        this.classList.remove('dragover');
        
        const files = Array.from(e.dataTransfer.files);
        handleFileSelection(files);
    });
    
    // File input change
    photoInput.addEventListener('change', function() {
        const files = Array.from(this.files);
        handleFileSelection(files);
    });
    
    function handleFileSelection(files) {
        const imageFiles = files.filter(file => file.type.startsWith('image/'));
        
        if (imageFiles.length === 0) {
            if (window.PromoMania) {
                window.PromoMania.showToast('Error', 'Por favor selecciona solo archivos de imagen', 'error');
            }
            return;
        }
        
        // Limit to 5 images total
        const remainingSlots = 5 - uploadedFiles.length;
        const filesToAdd = imageFiles.slice(0, remainingSlots);
        
        if (filesToAdd.length < imageFiles.length) {
            if (window.PromoMania) {
                window.PromoMania.showToast('Límite alcanzado', 'Máximo 5 imágenes por promoción', 'warning');
            }
        }
        
        filesToAdd.forEach(file => {
            if (file.size > 5 * 1024 * 1024) { // 5MB limit
                if (window.PromoMania) {
                    window.PromoMania.showToast('Archivo muy grande', `${file.name} excede el límite de 5MB`, 'error');
                }
                return;
            }
            
            uploadedFiles.push(file);
            addPhotoPreview(file);
        });
        
        updateUploadArea();
    }
    
    function addPhotoPreview(file) {
        const reader = new FileReader();
        reader.onload = function(e) {
            const photoItem = document.createElement('div');
            photoItem.className = 'photo-item';
            photoItem.innerHTML = `
                <img src="${e.target.result}" alt="Preview">
                <button type="button" class="photo-remove" onclick="removePhoto(this)" data-filename="${file.name}">
                    <i class="fas fa-times"></i>
                </button>
            `;
            
            photoPreview.appendChild(photoItem);
        };
        reader.readAsDataURL(file);
    }
    
    function updateUploadArea() {
        if (uploadedFiles.length >= 5) {
            uploadArea.style.display = 'none';
        } else {
            uploadArea.style.display = 'block';
            const remaining = 5 - uploadedFiles.length;
            uploadArea.querySelector('p').textContent = `Arrastra las fotos aquí o haz clic para seleccionar (${remaining} restantes)`;
        }
    }
    
    // Global function to remove photos
    window.removePhoto = function(button) {
        const filename = button.dataset.filename;
        uploadedFiles = uploadedFiles.filter(file => file.name !== filename);
        button.closest('.photo-item').remove();
        updateUploadArea();
    };
}

function initializeDependentFields() {
    // Supermarket dependent field
    const supermarketSelect = document.getElementById('supermarket');
    const otherSupermarketGroup = document.getElementById('other-supermarket-group');
    const otherSupermarketInput = document.getElementById('other-supermarket');
    
    supermarketSelect.addEventListener('change', function() {
        if (this.value === 'otro') {
            otherSupermarketGroup.style.display = 'block';
            otherSupermarketInput.required = true;
        } else {
            otherSupermarketGroup.style.display = 'none';
            otherSupermarketInput.required = false;
            otherSupermarketInput.value = '';
        }
    });
    
    // City dependent field
    const citySelect = document.getElementById('city');
    const otherCityGroup = document.getElementById('other-city-group');
    const otherCityInput = document.getElementById('other-city');
    
    citySelect.addEventListener('change', function() {
        if (this.value === 'otra') {
            otherCityGroup.style.display = 'block';
            otherCityInput.required = true;
        } else {
            otherCityGroup.style.display = 'none';
            otherCityInput.required = false;
            otherCityInput.value = '';
        }
    });
    
    // No expiry checkbox
    const noExpiryCheckbox = document.getElementById('no-expiry');
    const endDateInput = document.getElementById('end-date');
    
    noExpiryCheckbox.addEventListener('change', function() {
        if (this.checked) {
            endDateInput.disabled = true;
            endDateInput.required = false;
            endDateInput.value = '';
        } else {
            endDateInput.disabled = false;
            endDateInput.required = true;
        }
    });
    
    // Set minimum dates
    const today = new Date().toISOString().split('T')[0];
    document.getElementById('start-date').min = today;
    document.getElementById('end-date').min = today;
    
    // Update end date minimum when start date changes
    document.getElementById('start-date').addEventListener('change', function() {
        document.getElementById('end-date').min = this.value;
    });
}

function initializeFormValidation() {
    const form = document.getElementById('publish-promotion-form');
    const inputs = form.querySelectorAll('input, select, textarea');
    
    inputs.forEach(input => {
        input.addEventListener('blur', function() {
            validateField(this);
        });
        
        input.addEventListener('input', function() {
            if (this.classList.contains('error')) {
                validateField(this);
            }
        });
    });
    
    // Price validation
    const originalPriceInput = document.getElementById('original-price');
    const promoPriceInput = document.getElementById('promo-price');
    
    function validatePrices() {
        const originalPrice = parseFloat(originalPriceInput.value) || 0;
        const promoPrice = parseFloat(promoPriceInput.value) || 0;
        
        if (originalPrice > 0 && promoPrice >= originalPrice) {
            showFieldError(promoPriceInput, 'El precio promocional debe ser menor al precio original');
            return false;
        } else {
            clearFieldError(promoPriceInput);
            return true;
        }
    }
    
    originalPriceInput.addEventListener('input', validatePrices);
    promoPriceInput.addEventListener('input', validatePrices);
}

function validateField(field) {
    clearFieldError(field);
    
    if (field.required && !field.value.trim()) {
        showFieldError(field, 'Este campo es obligatorio');
        return false;
    }
    
    // Email validation
    if (field.type === 'email' && field.value && !isValidEmail(field.value)) {
        showFieldError(field, 'Ingresa un email válido');
        return false;
    }
    
    // URL validation
    if (field.type === 'url' && field.value && !isValidURL(field.value)) {
        showFieldError(field, 'Ingresa una URL válida');
        return false;
    }
    
    // Number validation
    if (field.type === 'number' && field.value) {
        const value = parseFloat(field.value);
        const min = parseFloat(field.min);
        const max = parseFloat(field.max);
        
        if (min !== undefined && value < min) {
            showFieldError(field, `El valor mínimo es ${min}`);
            return false;
        }
        
        if (max !== undefined && value > max) {
            showFieldError(field, `El valor máximo es ${max}`);
            return false;
        }
    }
    
    return true;
}

function showFieldError(field, message) {
    const formGroup = field.closest('.form-group');
    formGroup.classList.add('error');
    
    let errorElement = formGroup.querySelector('.error-message');
    if (!errorElement) {
        errorElement = document.createElement('div');
        errorElement.className = 'error-message';
        formGroup.appendChild(errorElement);
    }
    
    errorElement.innerHTML = `<i class="fas fa-exclamation-circle"></i> ${message}`;
}

function clearFieldError(field) {
    const formGroup = field.closest('.form-group');
    formGroup.classList.remove('error');
    
    const errorElement = formGroup.querySelector('.error-message');
    if (errorElement) {
        errorElement.remove();
    }
}

function validateForm() {
    const form = document.getElementById('publish-promotion-form');
    const inputs = form.querySelectorAll('input[required], select[required], textarea[required]');
    let isValid = true;
    
    inputs.forEach(input => {
        if (!validateField(input)) {
            isValid = false;
        }
    });
    
    // Validate prices
    const originalPrice = parseFloat(document.getElementById('original-price').value) || 0;
    const promoPrice = parseFloat(document.getElementById('promo-price').value) || 0;
    
    if (originalPrice > 0 && promoPrice >= originalPrice) {
        showFieldError(document.getElementById('promo-price'), 'El precio promocional debe ser menor al precio original');
        isValid = false;
    }
    
    // Validate terms agreement
    const termsAgree = document.getElementById('terms-agree');
    if (!termsAgree.checked) {
        showFieldError(termsAgree, 'Debes aceptar los términos para continuar');
        isValid = false;
    }
    
    return isValid;
}

async function handleFormSubmission(e) {
    e.preventDefault();
    
    if (!validateForm()) {
        if (window.PromoMania) {
            window.PromoMania.showToast('Error en el formulario', 'Por favor corrige los errores antes de continuar', 'error');
        }
        return;
    }
    
    const submitButton = e.target.querySelector('button[type="submit"]');
    const originalText = submitButton.innerHTML;
    
    // Show loading state
    submitButton.disabled = true;
    submitButton.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Publicando...';
    
    try {
        // Collect form data
        const formData = collectFormData();
        
        // Simulate API call
        await window.PromoMania.simulateApiCall(formData, 2000);
        
        // Add to promotions data (simulation)
        if (window.PromotionsModule) {
            const newPromotion = createPromotionFromFormData(formData);
            window.PromotionsModule.promotionsData.unshift(newPromotion);
        }
        
        // Show success modal
        showSuccessModal();
        
        // Add notification
        if (window.PromoMania) {
            window.PromoMania.addNotification(
                'Promoción publicada',
                'Tu promoción ha sido publicada exitosamente y está siendo revisada por la comunidad',
                'success'
            );
        }
        
    } catch (error) {
        console.error('Error publishing promotion:', error);
        if (window.PromoMania) {
            window.PromoMania.showToast('Error', 'Ocurrió un error al publicar la promoción. Inténtalo de nuevo.', 'error');
        }
    } finally {
        // Restore button state
        submitButton.disabled = false;
        submitButton.innerHTML = originalText;
    }
}

function collectFormData() {
    const form = document.getElementById('publish-promotion-form');
    const formData = new FormData(form);
    
    // Convert to object
    const data = {};
    for (const [key, value] of formData.entries()) {
        data[key] = value;
    }
    
    // Add calculated fields
    data.discountPercentage = window.PromoMania.calculateDiscount(
        parseFloat(data.originalPrice),
        parseFloat(data.promoPrice)
    );
    
    data.savings = parseFloat(data.originalPrice) - parseFloat(data.promoPrice);
    
    // Add current user info
    if (window.PromoMania && window.PromoMania.currentUser) {
        data.userId = window.PromoMania.currentUser.id;
        data.publishedBy = window.PromoMania.currentUser.name;
    }
    
    return data;
}

function createPromotionFromFormData(formData) {
    return {
        id: Date.now(),
        productName: formData.productName,
        brand: formData.brand || '',
        category: formData.category,
        supermarket: formData.supermarket === 'otro' ? formData.otherSupermarket : formData.supermarket,
        originalPrice: parseFloat(formData.originalPrice),
        promoPrice: parseFloat(formData.promoPrice),
        discountPercentage: formData.discountPercentage,
        city: formData.city === 'otra' ? formData.otherCity : formData.city,
        neighborhood: formData.neighborhood || '',
        storeAddress: formData.storeAddress || '',
        description: formData.promoDetails || '',
        startDate: formData.startDate || new Date().toISOString().split('T')[0],
        endDate: formData.endDate || null,
        images: ['https://via.placeholder.com/400x300?text=' + encodeURIComponent(formData.productName)],
        rating: 0,
        votes: { yes: 0, no: 0 },
        views: 0,
        verified: false,
        created: new Date().toISOString(),
        updated: new Date().toISOString(),
        userId: formData.userId || 1,
        additionalNotes: formData.additionalNotes || ''
    };
}

function showSuccessModal() {
    const modal = document.getElementById('success-modal');
    if (modal && window.PromoMania) {
        window.PromoMania.openModal('success-modal');
    }
}

// Utility functions
function isValidEmail(email) {
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    return emailRegex.test(email);
}

function isValidURL(url) {
    try {
        new URL(url);
        return true;
    } catch {
        return false;
    }
}

// Export for use in other modules
window.PublishModule = {
    validateForm,
    collectFormData,
    showSuccessModal
};