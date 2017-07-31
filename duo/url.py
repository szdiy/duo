from django.conf.urls import url
from django.contrib import admin
from . import views

urlpatterns = [
    url(r'^device/$', views.DeviceList.as_view()),
    url(r'^device/(?P<node_id>\w+)/power_archive$', views.DevicePowerArchiveList.as_view()),
    url(r'^duo/upload/$', views.upload_reading),
]
