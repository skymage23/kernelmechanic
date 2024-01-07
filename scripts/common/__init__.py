import pathlib
import sys
import .errcodes

HEAD_DIRECTORY_NAME="kernelmechanic"

__mod_name = "common"
__err_handler = errcodes.ErrcodeHandler.instance

ERRCODE_NOT_IN_PROJECT = __err_handler.registerErrcode(
                           __mod_name,
                           "ERRCODE_NOT_IN_PROJECT",
                           "This script is not being run from within the proejct tree.",
                           1
                        )



def get_project_head():
    index = -1
    proj_head_path = None
    curr_dir = pathlib.Path.cwd()
    path_parts = curr_dir.parts

    for i in range(0,len(path_parts)):
        if path_parts[i] == HEAD_DIRECTORY_NAME:
            index = i

    if index < 0:
        return False, None
    index = index + 1
    proj_head_path = pathlib.Path(path_parts[0])

    for i in range (0,index):
        proj_head_path = proj_head_path / path_parts[i]
        
    return True, proj_head_path

def die(mod_name = None, errcode = None):
    if errcode = None:
        raise ValueError("errcode cannot be None")

    quit(errcode)




