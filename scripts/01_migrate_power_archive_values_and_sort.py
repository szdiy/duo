from duo.models import *
from utils.datetime import seconds_to_micros

def run():
    for archive in NodePowerArchive.objects.all():
        power_list = archive.power_list()
        if len(power_list) == 0:
            continue

        # 转换total和timestamp类型
        for p in power_list:
            if isinstance(p['time'], str):
                # used to save as float string(in seconds), now convert to integer(in microseconds)
                p['time'] = int(seconds_to_micros(float(p['time'])))
            if isinstance(p['total'], str):
                p['total'] = float(p['total'])

        # 排序
        power_list.sort(key=lambda x: x['time'])

        # 设最后的时间
        latest = power_list[-1]
        archive.latest_total = latest['total']
        archive.latest_time = latest['time']

        # 保存
        archive.to_power_list(power_list)
        archive.save()
