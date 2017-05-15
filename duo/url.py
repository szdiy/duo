from django.conf.urls import url
from django.contrib import admin
from . import views

urlpatterns = [
    url(r'^device/$', views.device_list.as_view()),
    url(r'^duo/upload/$', views.upload_reading),
]
