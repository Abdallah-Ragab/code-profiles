#!/bin/bash
APP_DIR="$HOME/.codeprofiles/"
PROFILES_DIR="$APP_DIR/profiles/"


BRED='\033[1;91m'
LRED='\033[1;31m'
BGREEN="\033[1;92m"
LGREEN='\033[1;32m'
BBLUE="\033[1;94m"
LBLUE='\033[1;34m'
LYELLOW='\033[1;33m'
BYELLOW='\033[1;93m'
GRAY='\033[1;30m'
LGRAY='\033[0;37m'
BWHITE='\033[1;97m'
LCYAN="\033[1;36m"
BCYAN="\033[1;96m"
MAGENTA="\033[1;95m"
LMAGENTA="\033[1;35m"
NC='\033[0m'

render_app(){
    clear
    printf "${MAGENTA}> Welcome${BWHITE} $USER ${MAGENTA}:)\n\n${NC}"
    for err in "$@" ; do
        printf "$err \n"
    done
    if [[ ! -z $1 ]];then
        printf "\n"
    fi

    printf "${BWHITE}Choose a profile to start vs code:\n${NC}"
    render_profile_list
    render_options

    if [ ! -z ${LAUNCH_PROFILE+x} ];then
        launch_code $LAUNCH_PROFILE
        unset LAUNCH_PROFILE
    fi

    while :;
    do
        listen_for_keys
    done
}
check_dirs(){
    if [ ! -d "$APP_DIR" ];
    then 
        sudo mkdir $APP_DIR
    fi
    sudo chmod 777 $APP_DIR

    if [ ! -d "$PROFILES_DIR" ];
    then 
        sudo mkdir $PROFILES_DIR
    fi
    sudo chmod 777 $PROFILES_DIR
}
render_profile_list(){
    profiles_list
    if [[ ${#PROFILES_LIST[@]} == "0" ]];then
        printf "${BYELLOW}    You don't have any profiles.\n"
        printf "    Press ${BWHITE}N${BYELLOW} to create a new profile.\n${NC}"
    fi
    for P in ${!PROFILES_LIST[@]};do
        printf "    ${BBLUE}[$P]${LGRAY} ${PROFILES_LIST[P]}\n${NC}"
    done
    printf "\n"
}
profiles_list(){
    PROFILES_STRING=$(echo $(read_profiles) | tr " " ",")
    IFS=',' read -r -a PROFILES_LIST <<< "$PROFILES_STRING"
}
read_profiles(){
    for DIR in $(ls $PROFILES_DIR); do
        if [[ -d $PROFILES_DIR/$DIR ]];then
            echo "$DIR" 
        fi
    done
}
render_options(){
    printf "${BWHITE}Choose another option:\n${NC}"
    printf "    ${BGREEN}[N]${NC} Create a new profile.\n"
    printf "    ${BGREEN}[D]${NC} Delete a profile.\n"
}
listen_for_keys(){
    read -rsn1 input

    if $(key_exists_in_profiles $input);then
        USER_CHOSEN_PROFILE=${PROFILES_LIST[$input]}
        launch_code $USER_CHOSEN_PROFILE
    elif [[ $input = "n" ]] || [[ $input = "N" ]];then
        handle_new_profile_name
    elif [[ $input = "d" ]] || [[ $input = "D" ]];then
        if [[ ${#PROFILES_LIST[@]} == "0" ]];then
            render_app "${LRED}Error:${BRED} You don't have any profiles to delete.${NC}"
        fi
        handle_delete_profile
    fi
}
key_exists_in_profiles(){
    re='^[0-9]+$'
    if ! [[ $1 =~ $re ]] ; then
        echo "false"
    else
        if [ -v PROFILES_LIST[$1] ];then
            echo "true"
        else
            echo "false"
        fi
    fi
}
launch_code(){
    local PROFILE=$1
    local PROFILE_DIR="$PROFILES_DIR/$PROFILE"
    printf "\n${BYELLOW}launching${BWHITE} $PROFILE ${BYELLOW}... ${NC}"
    code --user-data-dir $PROFILE_DIR/data --extensions-dir $PROFILE_DIR/extensions
    if [[ $? = "0" ]];then
        printf "${BGREEN}Done${NC}"
    else
        printf "${BRED}Failed${NC}"
    fi
}
handle_new_profile_name(){
    clear

    printf "${BWHITE}Creating a new profile for you.\n\n${NC}"

    for err in "$@" ; do
        printf "$err \n"
    done
    if [[ ! -z $1 ]];then
        printf "\n"
    fi

    set -o emacs
    bind '"\C-w": kill-whole-line'
    bind '"\e": "\C-w\C-d"'
    bind '"\e\e": "\C-w\C-d"'
    printf "What do you want to call the profile ? (${BWHITE}ESC${NC} to return): " 
    IFS= read -rep '' NEW_PROFILE_INPUT || {
        render_app
    }

    local PROFILE_EXISTS=$(check_if_profile_exists $NEW_PROFILE_INPUT)
    local PROFILE_VALID=$(check_if_profile_name_is_valid $NEW_PROFILE_INPUT)

    if [[ -z "${NEW_PROFILE_INPUT// }" ]];then
        handle_new_profile_name "${LRED}Error:${BRED} profile name can't be empty.${NC}"
    fi

    if $PROFILE_EXISTS;then
        handle_new_profile_name "${LRED}Error:${BRED} '$NEW_PROFILE_INPUT' already exists.${NC}"
    else 
         if $PROFILE_VALID;then
            add_profile $NEW_PROFILE_INPUT
        else
            handle_new_profile_name "${LRED}Error:${BRED} profile name is not valid." "Allowed characters [Alphabetical letters, Numbers, '_' and '-']." "Whitespaces are not allowed.${NC}"
        fi
    fi

}
add_profile(){
    mkdir "$PROFILES_DIR/$1"
    if [[ $? = "0" ]];then
        render_app
    else
        render_app "${LRED}Error:${BRED} profile creation failed. Make sure you have the right permissions to create directories.${NC}"
    fi
}
handle_delete_profile(){
    clear

    printf "${BWHITE}Choose a profile to delete:\n${NC}"
    render_profile_list
    
    for err in "$@" ; do
        printf "$err \n"
    done
    if [[ ! -z $1 ]];then
        printf "\n"
    fi

    set -o emacs
    bind '"\C-w": kill-whole-line'
    bind '"\e": "\C-w\C-d"'
    bind '"\e\e": "\C-w\C-d"'
    printf "choose a profile from the list (${BWHITE}ESC${NC} to return):"
    IFS= read -rep "" DELETE_PROFILE_NAME || {
        render_app
    }
    DELETE_PROFILE_NAME=${DELETE_PROFILE_NAME// }
    if $(key_exists_in_profiles $DELETE_PROFILE_NAME);then
        DELETE_PROFILE_NAME=${PROFILES_LIST[DELETE_PROFILE_NAME]}
    elif $(check_if_profile_exists $DELETE_PROFILE_NAME);then
        DELETE_PROFILE_NAME=$DELETE_PROFILE_NAME
    else
        handle_delete_profile "${LRED}Error:${BRED} profile does not exist." "Make sure to enter the correct profile name or number from the list above.${NC}"
    fi

    printf "${BYELLOW}\nAre you sure you want to delete ${BWHITE}'$DELETE_PROFILE_NAME'${BYELLOW} ?\n${NC}"
    printf "  you will lose all extentions and user data.\n"
    printf "  this action is permanant and deleted profiles cannot be restored.\n"
    printf "[Press ${BWHITE}Y${NC} to confirm or ${BWHITE}N${NC} to cancel]\n"
    while :;do
        read -rsn1 conf
        if [[ $conf = "y" ]] || [[ $conf = "Y" ]]; then
            delete_profile $DELETE_PROFILE_NAME
            render_app
        elif [[ $conf = "n" ]] || [[ $conf = "N" ]]; then
            render_app
        fi
    done
}
delete_profile(){
    sudo rm -rfd bash "$PROFILES_DIR/$1"
}
check_if_profile_exists(){
    IFS=','
    if [[ "${IFS}${PROFILES_STRING[*]}${IFS}" =~ "${IFS}${1}${IFS}" ]]; then
        echo "true"
    else
        echo "false"
    fi
    unset IFS
}
check_if_profile_name_is_valid(){
    if [[ "$1" =~ [^A-Za-z0-9_-] ]];then
        echo "false"
    else
        echo "true"
    fi

}

check_dirs

if [ ! -z ${1+x} ];then
    profiles_list
    if $(check_if_profile_exists $1);then
        LAUNCH_PROFILE=$1
        render_app
    else 
        render_app "${LRED}Error:${BRED} profile ${BWHITE}'$1'${BRED} was not found.${NC}"
    fi
else
    render_app
fi

