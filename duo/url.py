from django.conf.urls import url
from django.contrib import admin
from . import views

urlpatterns = [
    url(r'^device$', views.DeviceList.as_view()),
    url(r'^device/(?P<node_id>\w+)/power$', views.DevicePowerArchiveList.as_view()),
    url(r'^upload/$', views.upload_reading),
]
