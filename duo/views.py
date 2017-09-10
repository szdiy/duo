from django.http import HttpResponse, Http404
from rest_framework import generics
from rest_framework.response import Response
from rest_framework.views import APIView
from rest_framework import status
from django.core.cache import cache

from .models import Node, NodePowerArchive
from .serializers import NodeSerializer, NodePowerArchiveSimpleSerializer, NodePowerArchiveDetailSerializer
from .permissions import IsAdminOrReadOnly

import json
from django.utils.timezone import datetime, timedelta
import logging

# Create your views here.
logger = logging.getLogger(__name__)


class DeviceList(generics.ListCreateAPIView):
    queryset = Node.objects.all()  # descending by time
    serializer_class = NodeSerializer
    permission_classes = (IsAdminOrReadOnly, )


class DevicePowerArchiveList(generics.ListCreateAPIView):
    queryset = NodePowerArchive.objects.all()  # descending by time
    permission_classes = (IsAdminOrReadOnly, )

    def create(self, request, *args, **kwargs):
        node_id = request.POST.get("node_id", None)
        node_query, node_validator = self.node_id_validator(node_id)
        if node_validator:
            time = request.POST.get("time", None)
            total = request.POST.get('total', None)
            archive_date = datetime.date.fromtimestamp(float(time))
            node = node_query[0]
            archive_query = node.power_archive.filter(date=archive_date)
            archive = archive_query[0] if archive_query.exists(
            ) else NodePowerArchive(node=node, date=archive_date)
            power_list = archive.power_list()
            power_list.append({"total": total, "time": time})
            archive.to_power_list(power_list)
            archive.save()
            data = {"node": node_id, "archive_json": power_list}
            return Response(data, status=status.HTTP_201_CREATED)
        else:
            return Response({"msg": "node_id not Found"}, status=status.HTTP_404_NOT_FOUND)

    def get_serializer_class(self):
        data_type = self.get_query_params()[2]
        if data_type == 'detail':
            return NodePowerArchiveDetailSerializer
        else:
            return NodePowerArchiveSimpleSerializer

    def get_query_params(self):

        date_format = {
            "24hours": (0, 1, 'detail'),
            "48hours": (0, 2, 'detail'),
            "7days": (0, 7, 'simple'),
            "14days": (0, 14, 'simple'),
            "1month": (0, 30, 'simple'),
            "2months": (0, 60, 'simple'),
        }

        query_date = self.request.GET.get("period", None)

        if not query_date or not query_date in date_format:
            query_date = "24hours"

        return date_format[query_date]

    def get_queryset(self):
        start_time, end_time, data_type = self.get_query_params()
        print('start time: {0} end time: {1} data type: {2}'.format(start_time, end_time, data_type))
        date_filter = {}
        now = datetime.now()
        date_filter['date__lte'] = now - timedelta(days=start_time)
        date_filter['date__gt'] = now - timedelta(days=end_time)
        queryset = self.queryset.filter(**date_filter)
        # print(queryset)
        return queryset
        # data = [{"total": float(cache.get(i).split(',')[0]), "node_id":int(
        #     cache.get(i).split(',')[1]), "time":int(i)} for i in cache.keys('*')]
        # print(data)

    def list(self, request, *args, **kwargs):
        node_id = kwargs["node_id"]
        node_query, node_validator = self.node_id_validator(node_id)
        # queryset = self.filter_queryset(self.get_queryset()) # if not used with filter backend, this is not required
        queryset = self.get_queryset()

        if queryset is not False:
            if node_validator:
                print("node_validator")
                page = self.paginate_queryset(queryset)
                if page is not None:
                    serializer = self.get_serializer(page, many=True)
                    # print(serializer.data)
                    return self.get_paginated_response(serializer.data)
                serializer = self.get_serializer(queryset, many=True)



                return Response(serializer.data, status=status.HTTP_200_OK)
                # else:
                # return Response({"msg": "invalid date format, please try again"},
                # status=status.HTTP_404_NOT_FOUND)
            else:
                return Response({"msg": "node_id not Found"}, status=status.HTTP_404_NOT_FOUND)
        else:
            return Response({"msg": "dateformat error, please trye again"}, status=status.HTTP_404_NOT_FOUND)

    def node_id_validator(self, node_id):
        queryset = Node.objects.all()
        print(node_id)
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
    archive_query = node.power_archive.filter(date=archive_date)
    archive = archive_query[0] if archive_query.exists(
    ) else NodePowerArchive(node=node, date=archive_date)
    power_list = archive.power_list()
    power_list.append({"total": total, "time": time})
    archive.to_power_list(power_list)

    archive.save()

    return HttpResponse("OK")
