"""
WSGI config for echaloasuerte project.

It exposes the WSGI callable as a module-level variable named ``application``.

For more information on this file, see
https://docs.djangoproject.com/en/1.6/howto/deployment/wsgi/
"""

import os
os.environ.setdefault("DJANGO_SETTINGS_MODULE", "echaloasuerte.settings.prod")
os.environ.setdefault("ECHALOASUERTE_LOGS_PATH", "{{echaloasuerte_logs}}")
os.environ.setdefault("EAS_PUSHER_SECRET", "{{pusher_secret}}")
os.environ.setdefault("EAS_MAIL_PASSWORD", "{{echaloasuerte_gmail_password}}")

# Activate your virtual env
activate_env=os.path.expanduser("{{ echaloasuerte_venv }}/bin/activate_this.py")
execfile(activate_env, dict(__file__=activate_env))

from django.core.wsgi import get_wsgi_application
application = get_wsgi_application()

