from django.http import HttpResponse, Http404
from rest_framework import generics
from rest_framework.response import Response
from rest_framework.views import APIView
from rest_framework import status
from django.core.cache import cache

from .models import Device, Node, NodePowerArchive
from .serializers import DeviceSerializer
from .permissions import IsAdminOrReadOnly

import json, datetime

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




def upload_reading(request):
    """上传设备读数

    HTTP GET: http://api.szdiy.org/duo/upload?node=<node_id>&total=<reading>&time=<timestamp>
        
        node_id: 节点id
        total: 度数
        time: unix timestamp
    """
    node_id = request.GET.get('node', None)
    total = request.GET.get('total', None)
    time = request.GET.get('time', None)

    if node_id is None or total is None or time is None:
        return HttpResponse("Parameter Error", status=400)

    node_query = Node.objects.filter(node_id=node_id)
    if not node_query.exists():
        return HttpResponse("Node not found", status=404)

    node = node_query[0]
    archive_date = datetime.date.fromtimestamp(float(time))

    # 保存读数到该天的archive记录
    archive_query = node.power_archive.filter(date=archive_date)
    archive = archive_query[0] if archive_query.exists() else NodePowerArchive(node=node, date=archive_date)
    power_list = archive.power_list()
    power_list.append({"total": total, "time": time})
    archive.to_power_list(power_list)
    
    archive.save()

        
    return HttpResponse("OK")


