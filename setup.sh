#!/usr/bin/env bash
PROJECT_NAME="kernelmechanic"

ZEPHYR_GETTING_STARTED_URL="https://docs.zephyrproject.org/latest/develop/getting_started/index.html"

PROJECT_DIR=""
PROJECT_SCRIPT_DIR=""
PROJECT_THIRD_PARTY_DIR=""
PROJECT_SRC_DIR=""
PROJECT_BOARD_DIR=""


failure(){
    if [ $# -ne 1 ]; then
	>&2 echo -n "failure: "
	if [ $# -gt 1 ]; then
            >&2 echo "Too many arguments"
        else
            >&2 echo "Too few arguments"
        fi
    fi

    >&2 echo "Unable to initialize project environment."
    local __tainted_env=$1
    if [ "$__tainted_env" = "True" ]; then 
         >&2 echo "Do not continue using this console session."
         >&2 echo "Instead, start a new session by either killing"
         >&2 echo "your remote session, if connecting remotely, or"
         >&2 echo "by killing your terminal emulator and then launching"
         >&2 echo "it again."
    fi

    >&2 echo
    >&2 echo
}


zephyr_not_found(){ 
    if [ $# -ne 1 ]; then
        >&2 echo -n "zephyr_not_found: "
	if [ $# -gt 1 ]; then
            >&2 echo "Too many arguments"
        else
            >&2 echo "Too few arguments" 
	fi
	failure "True"
    
    fi

    local __tainted_env=$1

    >&2 echo "Unable to find the required Zephyr codebase."
    >&2 echo "If you checked out this project using Git directly,"
    >&2 echo "that will not work.  You need to use The Zephyr"
    >&2 echo "Project's \"west\" tool in order to ensure that"
    >&2 echo "all Zephyr-related dependencies are correctly"
    >&2 echo "installed and the build system properly configured."
    >&2 echo "Please see"
    >&2 echo 
    >&2 echo "\"$ZEPHYR_GETTING_STARTED_URL\""
    >&2 echo
    >&2 echo "for detailed instructions on how to install \"west\","
    >&2 echo "as well as the Zephyr SDK, which you will also need."
    >&2 echo
    >&2 echo
    >&2 echo "If you did use \"west\" to check out this repository,"
    >&2 echo "make sure you also run \"west update\" to actually"
    >&2 echo "pull in the Zephyr-based dependencies. Fret not."
    >&2 echo "That is an easy step to miss."
    >&2 echo
    >&2 echo
    failure "$__tainted_env"
}

west_not_found(){
    if [ $# -ne 1 ]; then
        >&2 echo -n "west_not_found: "
	if [ $# -gt 1 ]; then
            >&2 echo "Too many arguments"
        else
            >&2 echo "Too few arguments" 
	fi
	failure "True" 
    fi

    local __tainted_env=$1
    >&2 echo "\"west\" could not be found in your environment."
    >&2 echo "Hence, we refuse to continue. You will need to figure where and how"
    >&2 echo "you will want to install \"west\".  We recommend using a virtual environment,"
    >&2 echo "such as one created using Python's \"venv\" module. When you install \"west\","
    >&2 echo "ensure it gets placed somewhere in your system PATH and re-run this script."

    >&2 echo
    >&2 echo
    failure "$__tainted_env"
}


load_board(){
   if [ $# -lt 1 ]; then
       >&2 echo "load_board: Too few arguments."
   fi

   if [ $# -gt 1 ]; then
       >&2 echo "load_board: Too many arguments."
   fi

   if [ ! "$BOARD_NAME" = "" ]; then
       board_deinit
   fi

   .  $PROJECT_BOARD_DIR/$1
   board_init
   export BOARD=$1
   unset board_init #prevent board from being initialized twice.

   echo "Build environment initialized for BOARD=$BOARD"
   return 0
}

board_menu(){
    #Get board list
    if [ ! -d "$PROJECT_BOARD_DIR" ]; then
	>&2 echo "Unable to get supported board list."
        return 1
    fi

    local board_selection=""
    local user_input=0
    local selection_made=0
    local sanity_check_re='^[0-9]+$'
    local counter=0
    local string_arr=()

    echo "Select the board against which you wish to build:"

    while read var; do
	 string_arr+=($var)
	 printf "$counter.)\t${var}\n"
         counter=$((counter + 1))
    done <<<$(ls $PROJECT_BOARD_DIR)

    while [ $selection_made -lt 1 ]; do
	echo "selection_made: $selection_made"
        read -p 'Your selection?: ' user_input

        if [[ $user_input =~ $re ]] && \
	   [ $user_input -ge 0 ] && \
	   [ $user_input -le $counter ]; then
	    selection_made=1
	else
            >&2 echo "error: Not a valid menu item."
        fi
    done
    #echo "${string_arr[$@]}"
    board_selection="${string_arr[$user_input]}"
    load_board "$board_selection"
    echo "$board_selection" > $PROJECT_DIR/.board_choice
    return 0
}

FUNC_RETVAL=""
clear_retval(){
    FUNC_RETVAL=""
}

find_project_dir(){
    local old_IFS=$IFS
    IFS="/"
    local found=0
    local str_accum=''
    local retval=""
    local abs_path=`realpath "$PWD"`
    
    for var in $abs_path; do
	str_accum="$str_accum $var"
        if [ "$var" == "$PROJECT_NAME" ]; then
	    found=1
            break;
	fi
    done

    if [ $found -ne 1 ]; then
        return 1
    fi
    
    IFS=" "
    for var in $str_accum; do 
        retval="$retval/$var"
    done

    FUNC_RETVAL=$retval
    IFS=$old_IFS
    return 0
}



# Put everything that only needs to run once here:
# This is so you can tweak function code without
# attempting to set environmental variables and
# settings more than once, potentially breaking
# your build environment.

if  [ "$ALREADY_SETUP" = "" ]; then
    echo "Setting up build environment"
    echo
    tainted_env="False"
    #Put anything that won't affect the shell environment in the block
    #starting here and ending with "tainted_env="True"" 
    ! find_project_dir && >&2 printf "Unable to find project directory.\n\n" && failure "$tainted_env"    
    PROJECT_DIR=$FUNC_RETVAL
    clear_retval

    #Look for Zephyr
    [ ! -f "$PROJECT_DIR/../zephyr/zephyr-env.sh" ] && zephyr_not_found "$tainted_env"
    if ! which west 2>&1 >/dev/null; then
	WEST_FOUND="False"
	echo "\"west\" was not found in your environment."
	echo "Checking to see if we can load it automatically."
	echo

	if python3 -c 'import sys; exit (sys.prefix != sys.base_prefix)'; then  #Bash uses inverted boolean logic values.
	    #We are NOT in the virtual env, so, let's look for it.
	    VENV_BIN_DIR=""
	    if [ -d "$PROJECT_DIR/.venv/bin" ]; then
                 VENV_BIN_DIR="$PROJECT_DIR/.venv/bin"
	    elif [ -d "$PROJECT_DIR/../.venv/bin" ]; then
                 VENV_BIN_DIR="$PROJECT_DIR/../.venv/bin"
	    fi

	    if [ "$VENV_BIN_DIR" != "" ]; then
	       echo "\"bin\" of \"venv\" virtual environment found: $VENV_BIN_DIR"
	       echo "Attempting to activate the virtual environment"
	       echo
               . $VENV_BIN_DIR/activate

	       echo "Virtual environment activated."
	       echo "Checking again for \"west\"."
	       echo

	       if  which west 2>&1 >/dev/null; then
                   WEST_FOUND="True"
	       fi 
	    else
               >&2 echo "We did not find a virtual environment in or near the project directory."
	    fi
        else
            >&2 echo "You are running this script in a Virtual Environment, but \"west\" is not installed."
	    >&2 echo "Please run \"pip install west\" to install it before re-running this script."
	    >&2 echo
	    >&2 echo
	fi

	if [ "$WEST_FOUND" != "True" ]; then
            west_not_found "$tainted_env"
	fi

    fi

    tainted_env="True"
    
    PROJECT_SCRIPT_DIR="$PROJECT_DIR/scripts"
    PROJECT_THIRD_PARTY_DIR="$PROJECT_DIR/third_party"
    PROJECT_SRC_DIR="$PROJECT_DIR/src"
    PROJECT_BOARD_DIR="$PROJECT_DIR/board_config"
    
    echo "******************************************"
    echo "PROJECT_DIR: $PROJECT_DIR"
    echo "PROJECT_SCRIPT_DIR: $PROJECT_SCRIPT_DIR"
    echo "PROJECT_THIRD_PARTY_DIR: $PROJECT_THIRD_PARTY_DIR"
    echo "PROJECT_SRC_DIR: $PROJECT_SRC_DIR"
    echo "PROJECT_BOARD_DIR: $PROJECT_BOARD_DIR"
    echo "******************************************"
    echo

    export PYTHONPATH="$PROJECT_SCRIPT_DIR:$PYTHONPATH"
    export PS1="(kernelmechanic_build) $PS1"
    __board_select=""
    if [ -f "$PROJECT_DIR/.board_choice" ]; then
        __board_select="$(<$PROJECT_DIR/.board_choice)"
        load_board "$__board_select"
    fi

    ALREADY_SETUP=1
fi

echo "Finished"
echo
