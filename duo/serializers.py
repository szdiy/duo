from .models import Node, NodePowerArchive
from rest_framework import serializers


class NodeSerializer(serializers.ModelSerializer):

    class Meta:
        model = Node
        fields = ('node_id', 'node_type')


class NodeArchiveSerializer(serializers.ModelSerializer):
    power_archive = serializers.PrimaryKeyRelatedField(
        many=True, read_only=True)

    class Meta:
        model = NodePowerArchive
        fields = ('power_archive', 'archive_json')
