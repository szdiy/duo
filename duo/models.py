from __future__ import unicode_literals   
from django.db import models
import json
# Create your models here.

class Device(models.Model):
    node_id = models.IntegerField()
    total = models.FloatField()
    time = models.BigIntegerField()


class Node(models.Model):
    NODE_TYPE_CHOICES = (
        ('POWER', 'Power'),
        ('WATER', 'Water'),
    )
    node_id = models.CharField(max_length=15)
    node_type = models.CharField(max_length=20, choices=NODE_TYPE_CHOICES, default="POWER")
    
    def __str__(self):
        return self.node_id


class NodePowerArchive(models.Model):
    node = models.ForeignKey(Node, related_name="power_archive")
    archive_json = models.TextField(default="[]")
    date = models.DateField(auto_now=False, auto_now_add=False)

    def power_list(self):
        return json.loads(self.archive_json) if self.archive_json else []

    def to_power_list(self, power_list):
        self.archive_json = json.dumps(power_list)
