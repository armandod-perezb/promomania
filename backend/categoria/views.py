from django.shortcuts import render
from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
from django.views.decorators.http import require_http_methods
from .models import Categoria

# Create your views here.
@csrf_exempt
@require_http_methods(["GET"])
def categoria_list(request):
    try:
        print("Fetching categories...")
        categories = Categoria.objects.all()
        return JsonResponse({'message': 'Categorias cargadas exitosamente.', 'categories': list(categories.values())}, status=200)
    except Exception as e:
        return JsonResponse({'error': 'An error occurred while fetching categories.'}, status=500)