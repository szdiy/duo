from .models import Device
from rest_framework import serializers

class DeviceSerializer(serializers.ModelSerializer):
    class Meta:
        model = Device
        fields = ('node_id', 'total', 'time')
