from django.conf.urls import url
from django.contrib import admin
from . import views

urlpatterns = [
    url(r'^duo/$', views.DevicePowerArchiveList.as_view()),
    url(r'^duo/upload/$', views.DevicePowerArchiveList.as_view()),
]
