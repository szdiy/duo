from django.http import HttpResponse, Http404
from rest_framework import generics
from rest_framework.response import Response
from rest_framework.views import APIView
from rest_framework import status
from django.core.cache import cache


from .models import Node, NodePowerArchive
from .serializers import NodeSerializer, NodeArchiveSerializer
from .permissions import IsAdminOrReadOnly

import json
import datetime

# Create your views here.


class device_list(generics.ListCreateAPIView):
    queryset = NodePowerArchive.objects.all()  # descending by time
    serializer_class = NodeArchiveSerializer
    permission_classes = (IsAdminOrReadOnly, )

    def create(self, request, *args, **kwargs):
        node_id = request.POST.get("node_id", None)
        node_query, node_validator = self.node_id_validator()
        if node_validator:
            time = request.POST.get("time", None)
            total = request.POST.get('total', None)
            archive_date = datetime.date.fromtimestamp(float(time))
            node = node_query[0]
            archive_query = node.node.filter(date=archive_date)
            archive = archive_query[0] if archive_query.exists(
            ) else NodePowerArchive(node=node, date=archive_date)
            power_list = archive.power_list()
            power_list.append(str({"total": total, "time": time}))
            print("power list is ", power_list)
            archive.to_power_list(power_list)
            archive.save()
            data = {"node": node_id, "archive_json": power_list}
            # serializer = self.get_serializer(
            #     data={"power_archive": node_id, "archive_json": power_list})
            # serializer.is_valid(raise_exception=True)
            # self.perform_create(serializer)
            # cache.set(serializer.data['time'], "{},{}".format(serializer.data[
            #           'total'], serializer.data['node_id']), timeout=60 * 60 * 24 * 7)
            #headers = self.get_success_headers(serializer.data)
            return Response(data, status=status.HTTP_201_CREATED)
        else:
            return Response({"msg": "node_id not Found"}, status=status.HTTP_404_NOT_FOUND)

    def list(self, request, *args, **kwargs):
        print(self.get_queryset())
        queryset = self.filter_queryset(self.get_queryset())
        page = self.paginate_queryset(queryset)
        if page is not None:
            serializer = self.get_serializer(page, many=True)
            # print(serializer.data)
            return self.get_paginated_response(serializer.data)
        serializer = self.get_serializer(queryset, many=True)
        # data = [{"total": float(cache.get(i).split(',')[0]), "node_id":int(
        #     cache.get(i).split(',')[1]), "time":int(i)} for i in cache.keys('*')]
        # print(data)
        return Response(serializer.data)

    def node_id_validator(self):
        queryset = Node.objects.all()
        node_id = self.request.POST.get("node_id", None)
        if node_id:
            queryset = queryset.filter(node_id=node_id)
            if queryset.exists():
                return queryset, True
            else:
                return queryset, False

        return False, False


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
    archive_query = node.node.filter(date=archive_date)
    archive = archive_query[0] if archive_query.exists(
    ) else NodePowerArchive(node=node, date=archive_date)
    power_list = archive.power_list()
    power_list.append({"total": total, "time": time})
    archive.to_power_list(power_list)

    archive.save()

    return HttpResponse("OK")
