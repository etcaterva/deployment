#!/bin/bash
DJANGO_SETTINGS_MODULE={{ echaloasuerte_3_app_settings }} EAS_MAIL_PASSWORD={{ noreply_mail_password }} {{ echaloasuerte_3_venv }}/bin/celery --app celery-task worker
