from .models import Node, NodePowerArchive
from rest_framework import serializers


class NodeSerializer(serializers.ModelSerializer):

    node = serializers.PrimaryKeyRelatedField(many=True, read_only=True)
    
    class Meta:
        model = Node
        fields = ('node_id', 'node_type')


class NodeArchiveSerializer(serializers.ModelSerializer):
    
    class Meta:
        model = NodePowerArchive
        fields = ('node', 'archive_json')
