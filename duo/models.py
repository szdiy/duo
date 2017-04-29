from __future__ import unicode_literals   
from django.db import models
# Create your models here.

class Device(models.Model):
    node_id = models.IntegerField()
    total = models.FloatField()
    time = models.BigIntegerField()
