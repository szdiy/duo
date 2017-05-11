from django.contrib import admin
from .models import *
# Register your models here.

@admin.register(Device)
class DeviceAdmin(admin.ModelAdmin):
    pass


@admin.register(Node)
class NodeAdmin(admin.ModelAdmin):
    list_display=['node_id', 'node_type'] 


@admin.register(NodePowerArchive)
class NodePowerArchiveAdmin(admin.ModelAdmin):
    list_display=['node', 'date', 'archive_json']

