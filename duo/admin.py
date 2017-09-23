from django.contrib import admin
from .models import *
# Register your models here.


@admin.register(Node)
class NodeAdmin(admin.ModelAdmin):
    list_display = ['node_id', 'node_type']


@admin.register(NodePowerArchive)
class NodePowerArchiveAdmin(admin.ModelAdmin):
    list_display = ['node', 'date', 'latest_time', 'latest_total', 'archive_json']
