from django.utils.timezone import datetime

# parameter: timestamp - unix timestamp
# return an django DateField accepted value
def unix_timestamp_to_date_field(timestamp):
    dt = datetime.fromtimestamp(float(timestamp))
    return dt.date()
