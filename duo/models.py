from __future__ import unicode_literals
from django.db import models
import json
# Create your models here.


class Node(models.Model):
    NODE_TYPE_CHOICES = (
        ('POWER', 'Power'),
        ('WATER', 'Water'),
    )
    node_id = models.CharField(max_length=15)
    node_type = models.CharField(
        max_length=20, choices=NODE_TYPE_CHOICES, default="POWER")

    def __str__(self):
        return self.node_id


# 电力的记录（如果节点有其他类型时可创建其他的记录模型
class NodePowerArchive(models.Model):
    node = models.ForeignKey(
        Node, related_name='power_archive', on_delete=models.CASCADE)
    archive_json = models.TextField(default="[]")
    date = models.DateField(auto_now=False, auto_now_add=False)
    latest_total = models.FloatField(default=0)
    latest_time = models.DateTimeField(null=True, blank=True)


    def power_list(self):
        return json.loads(self.archive_json) if self.archive_json else []

    def to_power_list(self, power_list):
        self.archive_json = json.dumps(power_list)

    def simple(self):
        if self.latest_time:
            return {
                "total": self.latest_total,
                "time": self.latest_time,
            }
        else:
            return None

    def detail(self):
        return self.power_list()
