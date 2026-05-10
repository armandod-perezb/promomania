/// Validadores para entrada de usuario.
///
/// Proporciona funciones reutilizables para validar correos, contraseñas,
/// números telefónicos y otros datos comunes.
class Validators {
  /// Valida un correo electrónico.
  ///
  /// Retorna null si es válido, o un mensaje de error si no.
  static String? validateEmail(String? email) {
    if (email == null || email.isEmpty) {
      return 'El correo no puede estar vacío';
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(email)) {
      return 'Por favor ingresa un correo válido';
    }

    return null;
  }

  /// Valida una contraseña.
  ///
  /// Requiere al menos 8 caracteres, una mayúscula, una minúscula y un número.
  static String? validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      return 'La contraseña no puede estar vacía';
    }

    if (password.length < 8) {
      return 'La contraseña debe tener al menos 8 caracteres';
    }

    if (!password.contains(RegExp(r'[A-Z]'))) {
      return 'La contraseña debe contener al menos una mayúscula';
    }

    if (!password.contains(RegExp(r'[a-z]'))) {
      return 'La contraseña debe contener al menos una minúscula';
    }

    if (!password.contains(RegExp(r'[0-9]'))) {
      return 'La contraseña debe contener al menos un número';
    }

    return null;
  }

  /// Valida un nombre de usuario.
  static String? validateName(String? name) {
    if (name == null || name.isEmpty) {
      return 'El nombre no puede estar vacío';
    }

    if (name.length < 2) {
      return 'El nombre debe tener al menos 2 caracteres';
    }

    if (name.length > 100) {
      return 'El nombre no puede exceder 100 caracteres';
    }

    return null;
  }

  /// Valida un número telefónico colombiano.
  static String? validatePhoneNumber(String? phone) {
    if (phone == null || phone.isEmpty) {
      return 'El teléfono no puede estar vacío';
    }

    final phoneRegex = RegExp(r'^(\+57|0057|57)?\s?3\d{2}\s?\d{7}$');

    if (!phoneRegex.hasMatch(phone)) {
      return 'Por favor ingresa un teléfono válido';
    }

    return null;
  }

  /// Valida que dos contraseñas coincidan.
  static String? validatePasswordMatch(String? password, String? confirm) {
    if (password != confirm) {
      return 'Las contraseñas no coinciden';
    }

    return null;
  }

  /// Valida un título de promoción.
  static String? validatePromotionTitle(String? title) {
    if (title == null || title.isEmpty) {
      return 'El título no puede estar vacío';
    }

    if (title.length < 5) {
      return 'El título debe tener al menos 5 caracteres';
    }

    if (title.length > 150) {
      return 'El título no puede exceder 150 caracteres';
    }

    return null;
  }

  /// Valida un precio.
  static String? validatePrice(String? price) {
    if (price == null || price.isEmpty) {
      return 'El precio no puede estar vacío';
    }

    final priceValue = double.tryParse(price);
    if (priceValue == null || priceValue <= 0) {
      return 'Por favor ingresa un precio válido mayor a 0';
    }

    return null;
  }
}
