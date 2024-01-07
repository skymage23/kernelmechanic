#!/usr/bin/env python3
import common
from common import errcodes

mod_name="build_linux"
err_handle = errcodes.ErrcodeHandler.instance

def main():
    result, proj_head_dir = common.get_project_head()
    if not result:
        common.die(common.ERRCODE_NOT_IN_PROJECT)

if __name__ == "__main__":
    main()
