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
    url = "http://10.1.1.138:8000/duo/device"
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

### Get Device data

```python
def get_data(token):
    url = "http://10.1.1.138:8000/duo/device"
    header = {"Authorization": "Token {}".format(token)}
    r = requests.get(url, headers=header)
    return r.json()

get_data(get_token())

```

### Get Device's Power Archive

 * Get power readings in last 24 hours ( Device: "A001" )

```python
def get_data(token):
    url = "http://10.1.1.138:8000/duo/device/A001/power"
    header = {"Authorization": "Token {}".format(token)}
    r = requests.get(url, headers=header)
    return r.json()

get_data(get_token())

```

 * Get power readings in other periods:
   * "24hours", last 24 hours
   * "48hours", last 48 hours,
   * "7days", in last 7 days,
   * "14days", in last 14 days,
   * "1month", in last month,
   * "3months", in last 3 months,

  Example: ( Device: "A001", period: "24hours")

 ```python
 def get_data(token):
     url = "http://10.1.1.138:8000/duo/device/A001/power?period=24hours"
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
