# Project duo - Server Side (Django version)

This is the first and a Django imlementation of the server side for the SZDIY **duo** project.



##How To

### Get Token
```python
import requests

def get_token():
	url = "http://10.211.55.12:8000/api-token-auth/"
	data = {
		"username": 'root',
		"password": "test1234",
		}
    r = requests.post(url, data=data)
	return r.json()['token']
```

### Post data
```python
def Post_data(token):
	url = "http://10.211.55.12:8000/device/"
	data = {
		"node_id": 7654321345,
		"total": 4567890,
		"time": 672384956,
		}
    header = {"Authorization": "Token {}".format(token)}
	r = requests.post(url, data=data, headers=header)
	print r.content
```

### Put them together

```python
Post_data(get_token())
```
