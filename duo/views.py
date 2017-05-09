from django.http import HttpResponse, Http404
from rest_framework import generics
from rest_framework.response import Response
from rest_framework.views import APIView
from rest_framework import status
from django.core.cache import cache

from .models import Device
from .serializers import DeviceSerializer
from .permissions import IsAdminOrReadOnly
# Create your views here.

class device_list(generics.ListCreateAPIView):
    queryset = Device.objects.all().order_by('-time')[:144] # descending by time
    serializer_class = DeviceSerializer
    permission_classes = (IsAdminOrReadOnly, )
    def create(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        self.perform_create(serializer)
        cache.set(serializer.data['time'], "{},{}".format(serializer.data['total'], serializer.data['node_id']), timeout=60*60*24*7)
        #print(serializer.data)  
        headers = self.get_success_headers(serializer.data)
        return Response(serializer.data, status=status.HTTP_201_CREATED, headers=headers)

    def list(self, request, *args, **kwargs):
        #queryset = self.filter_queryset(self.get_queryset())
        #page = self.paginate_queryset(queryset)
        #if page is not None:
        #    serializer = self.get_serializer(page, many=True)
        #    #print(serializer.data)
        #    return self.get_paginated_response(serializer.data)
        #serializer = self.get_serializer(queryset, many=True)
        data = [{"total": float(cache.get(i).split(',')[0]), "node_id":int(cache.get(i).split(',')[1]), "time":int(i)} for i in cache.keys('*')]
        print(data)
        return Response(data)
