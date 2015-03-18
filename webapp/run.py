#!/usr/bin/env python
from app import create_app

application = create_app('app.settings.Config')

if __name__ == '__main__':
    application.run(debug=True)
