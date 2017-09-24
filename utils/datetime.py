from django.utils.timezone import datetime
from django.utils import timezone


# parameter: timestamp - unix timestamp in seconds(which python favors)
# return an django DateTimeField accepting value
def seconds_to_datetime_field(timestamp_str):
    return timezone.make_aware(datetime.fromtimestamp(float(timestamp_str)))

# parameter: timestamp - unix timestamp in seconds(which python favors)
# return an django DateField accepting value
def seconds_to_date_field(timestamp_str):
    dt = seconds_to_datetime_field(timestamp_str)
    return dt.date()

def datetime_field_to_seconds(dt):
    return dt.timestamp()
