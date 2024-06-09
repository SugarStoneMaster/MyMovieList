from factory import create_app

import os
import configparser


if __name__ == "__main__":
    app = create_app()
    app.run(debug=True)