# from django.test import TestCase, Client
from rest_framework.test import APITestCase, APIClient

class TestApiDevice(APITestCase):
    fixtures = ["test_users.json"]
    API_TOKEN_AUTH = '/api-token-auth/'
    API_DEVICE_LIST = '/duo/device'

    client = APIClient()

    def setUp(self):
        token_response = self.client.post(self.API_TOKEN_AUTH, {
            "username": 'root',
            "password": "test1234",
        })
        token_data = token_response.json()
        self.client.credentials(HTTP_AUTHORIZATION='Token ' + token_data["token"])


    def testCreateDevice(self):
        device = {
            "node_id": "A003",
            "node_type": "POWER"
        }
        response = self.client.post(self.API_DEVICE_LIST, device)
        self.assertEqual(response.data, device, "create device error")


    def testListDevice(self):
        response = self.client.get(self.API_DEVICE_LIST)
        print('test response: {0}'.format(response.json()))
