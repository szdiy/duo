# Project duo - Server Side (Django version)

This is the first and a Django imlementation of the server side for the SZDIY **duo** project.



##How To

### Get Token
```python
import requests

def get_token():
    url = "http://api.szdiy.org/duo/api-token-auth"
    data = {
        "username": 'root',
        "password": "test1234",
        }
    r = requests.post(url, data=data)
    return r.json()['token']
```

### Create Device
```python
def create_device(token):
    url = "http://api.szdiy.org/duo/device"
    data = {
        "node_id": 'NODE1',
        "node_type": 'POWER',
        }
    header = {"Authorization": "Token {}".format(token)}
    r = requests.post(url, data=data, headers=header)
    return r.content

create_device(get_token())

```

### Get Device List

```python
def list_device():
    url = "http://api.szdiy.org/duo/device"
    header = {"Authorization": "Token {}".format(token)}
    r = requests.get(url, headers=header)
    return r.json()

list_device(get_token())

```

### Upload Power readings

```python

def upload_power(token, node_id, total, time):
    url = "http://api.szdiy.org/duo/device/{0}/power".format(node_id)
    data = {
        "node_id": 'NODE1',
        "total": 4567890,
        "time": 672384956,
        }
    header = {"Authorization": "Token {}".format(token)}
    r = requests.get(url, headers=header)
    return r.json()

```
### Get Device's Power Archive

There are two types of power data: **simple**(daily), **detail**(in every pulse).

####  __[detail]__ Get power readings in last 24 hours

```python
def latest_power(token, node_id):
    url = "http://api.szdiy.org/duo/device/{0}/power".format(node_id)
    header = {"Authorization": "Token {}".format(token)}
    r = requests.get(url, headers=header)
    return r.json()

latest_power(get_token(), 'NODE1')

```

#### Get power readings in other periods:

   * __[detail]__ "24hours", last 24 hours
   * __[detail]__ "48hours", last 48 hours,
   * __[simple]__ "7days", in last 7 days,
   * __[simple]__ "14days", in last 14 days,
   * __[simple]__ "1month", in last month,
   * __[simple]__ "3months", in last 3 months,

  Example: ( Device: "A001", period: "24hours")

 ```python
 def get_power_archive(token, node_id, period):
     url = "http://api.szdiy.org/duo/device/{0}/power?period={1}".format(node_id, period)
     header = {"Authorization": "Token {}".format(token)}
     r = requests.get(url, headers=header)
     return r.json()

 get_power_archive(get_token(), 'NODE1', '7days')

 ```

#### __[detail]__ Get power archive by date

```python
def get_power_archive_by_date(token, node_id, date):
    url = "http://api.szdiy.org/duo/device/{0}/power?date={1}".format(node_id, date)
    header = {"Authorization": "Token {}".format(token)}
    r = requests.get(url, headers=header)
    return r.json()

get_power_archive_by_date(get_token(), 'NODE1', '2017-09-24') # date format "YYYY-MM-dd"

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
