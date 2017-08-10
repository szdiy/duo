# Project duo - Server Side (Django version)

This is the first and a Django imlementation of the server side for the SZDIY **duo** project.



##How To

### Get Token
```python
import requests

def get_token():
    url = "http://10.1.1.138:8000/api-token-auth/"
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
    url = "http://10.1.1.138:8000/device/"
    data = {
        "node_id": 7654321345,
        "total": 4567890,
        "time": 672384956,
        }
    header = {"Authorization": "Token {}".format(token)}
    r = requests.post(url, data=data, headers=header)
    return r.content

Post_data(get_token())

```

### Get data

```python
def get_data(token):
    url = "http://10.1.1.138:8000/device/"
    header = {"Authorization": "Token {}".format(token)}
    r = requests.get(url, headers=header)
    return r.json()

get_data(get_token())

```

### Generate past 70 days data for testing

```python

import datetime

now = datetime.datetime.now()
test_time = now - datetime.timedelta(days=start_date)

for i in range(70):
    test_time = (now - datetime.timedelta(days=i)).timestamp()
    print(Post_data(start_time))


```