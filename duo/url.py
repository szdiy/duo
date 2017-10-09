from django.conf.urls import url
from django.contrib import admin
from django.views.decorators.cache import cache_page
from django.core.cache.backends.base import DEFAULT_TIMEOUT
from django.conf import settings

from . import views

CACHE_TTL = getattr(settings, 'CACHE_TTL', DEFAULT_TIMEOUT)

urlpatterns = [
    url(r'^device$', cache_page(CACHE_TTL)(views.DeviceList.as_view())),
    url(r'^device/(?P<node_id>\w+)/power$',
        cache_page(CACHE_TTL)(views.DevicePowerArchiveList.as_view())),
    url(r'^upload$', views.upload_reading),
]
