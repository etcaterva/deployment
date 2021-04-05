#!/bin/bash
DJANGO_SETTINGS_MODULE={{ echaloasuerte_3_app_settings }} {{ echaloasuerte_3_venv }}/bin/python {{ echaloasuerte_3_app }}/manage.py backup load /tmp/backend-backup
