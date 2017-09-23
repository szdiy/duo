from django.utils.timezone import datetime


# convert seconds to microseconds (which api favors)
def seconds_to_micros(seconds):
    return int(seconds) * 1000000

# convert microseconds to seconds (which python favors)
def micros_to_seconds(micros):
    return float(micros) / 1000000


# parameter: timestamp - unix timestamp in seconds(which python favors)
# return an django DateField accepted value
def seconds_to_date_field(timestamp_str):
    dt = datetime.fromtimestamp(float(timestamp_str))
    return dt.date()
