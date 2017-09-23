# Scripts to help for maintenance or cron jobs

---

Requirement: you need to install `django-extensions` to run the script in a command way.

Run a script:

```bash

$ python manage.py runscript 01_script_name_xxx

```

### 01: `01_migrate_power_archive_values_and_sort.py`

Originally the readings and the time values are store as string, but in frontend, we need it converted as integer and float.

```bash

$ python manage.py runscript 01_migrate_power_archive_values_and_sort

```
