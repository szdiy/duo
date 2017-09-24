from .models import Node, NodePowerArchive
from rest_framework import serializers


class NodeSerializer(serializers.ModelSerializer):

    # power_archive = serializers.PrimaryKeyRelatedField(many=True, read_only=True)

    class Meta:
        model = Node
        fields = ('node_id', 'node_type')
        # fields = ('node_id', 'node_type', 'power_archive')


class NodePowerArchiveSimpleSerializer(serializers.ModelSerializer):
    node_id = serializers.ReadOnlyField(source='node.node_id')

    class Meta:
        model = NodePowerArchive
        fields = ('node_id', 'date', 'simple') # last reading at the day

class NodePowerArchiveDetailSerializer(serializers.ModelSerializer):
    node_id = serializers.ReadOnlyField(source='node.node_id')

    class Meta:
        model = NodePowerArchive
        fields = ('node_id', 'date', 'latest_total', 'latest_timestamp', 'detail') # TODO: here the json string is parse and will be dumps again, enhance this!
