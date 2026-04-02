from django.core.exceptions import ImproperlyConfigured
from django.shortcuts import get_object_or_404
from rest_framework import status
from rest_framework.response import Response
from rest_framework.views import APIView


class BaseCRUDView(APIView):
    model = None
    serializer_class = None
    lookup_field = 'pk'
    lookup_url_kwarg = 'id'
    request_lookup_field = 'id'

    def get_queryset(self):
        if self.model is None:
            raise ImproperlyConfigured(
                f'{self.__class__.__name__} requires a model attribute.'
            )
        return self.model.objects.all()

    def get_serializer_class(self):
        if self.serializer_class is None:
            raise ImproperlyConfigured(
                f'{self.__class__.__name__} requires a serializer_class attribute.'
            )
        return self.serializer_class

    def get_object(self, identifier):
        queryset = self.get_queryset()
        return get_object_or_404(queryset, **{self.lookup_field: identifier})

    def get_identifier_from_request(self, request):
        identifier = request.data.get(self.request_lookup_field)
        if identifier is None and self.request_lookup_field != 'id':
            identifier = request.data.get('id')
        if identifier is None and self.request_lookup_field != 'codigo':
            identifier = request.data.get('codigo')
        return identifier


class CreateView(BaseCRUDView):
    def post(self, request, *args, **kwargs):
        serializer_class = self.get_serializer_class()
        serializer = serializer_class(data=request.data)

        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=status.HTTP_201_CREATED)

        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


class ListView(BaseCRUDView):
    def get(self, request, *args, **kwargs):
        serializer_class = self.get_serializer_class()
        queryset = self.get_queryset()
        serializer = serializer_class(queryset, many=True)
        return Response(serializer.data, status=status.HTTP_200_OK)


class DetailView(BaseCRUDView):
    def get(self, request, *args, **kwargs):
        identifier = kwargs.get(self.lookup_url_kwarg)
        if identifier is None:
            return Response(
                {'detail': 'Missing identifier.'},
                status=status.HTTP_400_BAD_REQUEST,
            )

        serializer_class = self.get_serializer_class()
        obj = self.get_object(identifier)
        serializer = serializer_class(obj)
        return Response(serializer.data, status=status.HTTP_200_OK)


class UpdateView(BaseCRUDView):
    def _update(self, request, partial=False):
        identifier = self.get_identifier_from_request(request)
        if identifier is None:
            return Response(
                {'detail': f'Missing {self.request_lookup_field} in request data.'},
                status=status.HTTP_400_BAD_REQUEST,
            )

        serializer_class = self.get_serializer_class()
        obj = self.get_object(identifier)
        serializer = serializer_class(obj, data=request.data, partial=partial)

        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=status.HTTP_200_OK)

        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    def put(self, request, *args, **kwargs):
        return self._update(request, partial=False)

    def patch(self, request, *args, **kwargs):
        return self._update(request, partial=True)


class DeleteView(BaseCRUDView):
    def delete(self, request, *args, **kwargs):
        identifier = self.get_identifier_from_request(request)
        if identifier is None:
            return Response(
                {'detail': f'Missing {self.request_lookup_field} in request data.'},
                status=status.HTTP_400_BAD_REQUEST,
            )

        obj = self.get_object(identifier)
        obj.delete()
        return Response(status=status.HTTP_204_NO_CONTENT)