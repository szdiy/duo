from django.http import HttpResponse
from rest_framework import generics
from rest_framework.response import Response
from .models import Device
from .serializers import DeviceSerializer
from .permissions import IsAdminOrReadOnly
# Create your views here.

class device_list(generics.ListCreateAPIView):
    queryset = Device.objects.all()
    serializer_class = DeviceSerializer
    serializer_class = DeviceSerializer
    permission_classes = (IsAdminOrReadOnly, )
