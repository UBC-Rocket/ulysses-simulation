"""PlatformIO extra script: launches manual_logger.py automatically after firmware upload.

Added to platformio.ini via:
    extra_scripts = post:post_upload.py
"""

Import("env")

import subprocess
import sys
import os
import time


def after_upload(source, target, env):
    """Called by PlatformIO after the upload target completes."""
    project_dir = env.subst("$PROJECT_DIR")
    logger_path = os.path.join(project_dir, "manual_logger.py")

    # Brief delay so the ESP32 finishes its reset after upload.
    time.sleep(2)

    cmd = [sys.executable, logger_path]

    print(f"\n>>> Starting logger: {' '.join(cmd)}\n")
    try:
        subprocess.call(cmd)
    except KeyboardInterrupt:
        print("\n>>> Logger stopped.")


env.AddPostAction("upload", after_upload)
