#!/usr/bin/env bash

# -----------------
# --- MAIN MENU ---
# -----------------

# Define the dialog exit status codes
: ${DIALOG_OK=0}
: ${DIALOG_CANCEL=1}
: ${DIALOG_HELP=2}
: ${DIALOG_EXTRA=3}
: ${DIALOG_ITEM_HELP=4}
: ${DIALOG_ESC=255}

function main_menu() {

    CHOICE=$(dialog --clear \
        --title "SYSTEM MANAGER" \
        --menu "Select an option" \
        15 0 5 \
        n "Network Information" \
        g "Group Management" \
        u "User Management" \
        f "Folder Management" \
        2>&1 >/dev/tty) 

    clear
    case $CHOICE in
        n)
            network_info
            ;;
        g)
            group_menu
            ;;
        u)
            user_menu
            ;;
        f)
            folder_menu
            ;;
    esac
}

# ---------------------------
# --- NETWORK INFORMATION ---
# ---------------------------

function network_info() {

    dialog --clear \
        --title "SYSTEM MANAGER" \
        --msgbox "Select an option" \
        15 0

    return_value=$?

    # Act on it
    case $return_value in
        $DIALOG_OK)
            main_menu
            ;;
        $DIALOG_ESC)
            network_info
            ;;
    esac
}


# -----------------------
# --- GROUP FUNCTIONS ---
# -----------------------

function group_menu() {

    CHOICE=$(dialog --clear \
        --title "GROUP MENU" \
        --menu "Select an option" \
        15 0 5 \
        a "Add Group" \
        l "List Group" \
        v "View Group" \
        m "Modify Group" \
        d "Delete Group" \
        2>&1 >/dev/tty) 

    return_code=$?
    if [[ $return_code == $DIALOG_CANCEL ]]; then
        main_menu
    elif [[ $return_code == $DIALOG_ESC ]]; then
        group_menu
    fi

        clear
        case $CHOICE in
            a)
                group_add
                ;;
            l)
                group_list
                ;;
            v)
                group_view
                ;;
            m)
                group_modify
                ;;
            d)
                group_delete
                ;;
        esac

}

function group_add() {
    sleep 0
}

function group_list() {
    sleep 0
}

function group_view() {
    sleep 0
}

function group_modify() {
    sleep 0
}

function group_delete() {
    sleep 0
}

# ----------------------
# --- USER FUNCTIONS ---
# ----------------------

function user_menu() {

    CHOICE=$(dialog --clear \
        --title "USER MENU" \
        --menu "Select an option" \
        15 0 5 \
        a "Add User" \
        l "List User" \
        v "View User" \
        m "Modify User" \
        d "Delete User" \
        2>&1 >/dev/tty) 

    return_code=$?
    if [[ $return_code == $DIALOG_CANCEL ]]; then
        main_menu
    elif [[ $return_code == $DIALOG_ESC ]]; then
        user_menu
    fi

        clear
        case $CHOICE in
            a)
                user_add
                ;;
            l)
                user_list
                ;;
            v)
                user_view
                ;;
            m)
                user_modify
                ;;
            d)
                user_delete
                ;;
        esac

}

function user_add() {

    FULLNAME=$(dialog --clear \
        --title "FULLNAME" \
        --inputbox "Enter your full name" \
        15 0 \
        2>&1 >/dev/tty) 

    USERNAME=$(dialog --clear \
        --title "USERNAME" \
        --inputbox "Enter a username" \
        15 0 \
        2>&1 >/dev/tty) 

    PASSWORD=$(dialog --clear \
        --title "PASSWORD" \
        --passwordbox "Enter a password" \
        15 0 \
        2>&1 >/dev/tty) 

}

function user_list() {

    USER=$(cat /etc/passwd | cut -d ':' -f 1)
    CHOICE=$(dialog --clear \
        --title "USERS" \
        --msgbox "$USER" \
        15 0 \
        2>&1 >/dev/tty) 

    return_code=$?
    if [[ $return_code == $DIALOG_OK ]]; then
        main_menu
    elif [[ $return_code == $DIALOG_ESC ]]; then
        user_list
    fi

    sleep 0
}

function user_view() {
    sleep 0
}

function user_modify() {
    sleep 0
}

function user_delete() {
    sleep 0
}

# ------------------------
# --- FOLDER FUNCTIONS ---
# ------------------------

function folder_menu() {

    CHOICE=$(dialog --clear \
        --title "FOLDER MENU" \
        --menu "Select an option" \
        15 0 5 \
        a "Add Folder" \
        l "List Folder" \
        v "View Folder" \
        m "Modify Folder" \
        d "Delete Folder" \
        2>&1 >/dev/tty) 

    return_code=$?
    if [[ $return_code == $DIALOG_CANCEL ]]; then
        main_menu
    elif [[ $return_code == $DIALOG_ESC ]]; then
        folder_menu
    fi

        clear
        case $CHOICE in
            a)
                folder_add
                ;;
            l)
                folder_list
                ;;
            v)
                folder_view
                ;;
            m)
                folder_modify
                ;;
            d)
                folder_delete
                ;;
        esac
}

function folder_add() {

    FOLDER=$(dialog --clear \
        --title "ADD FOLDER" \
        --inputbox "Enter a folder name" \
        15 0 \
        2>&1 >/dev/tty) 

    mkdir $FOLDER
    if [[ $? == 0 ]]; then
        CHOICE=$(dialog --clear \
        --title "FOLDER CREATED" \
        --msgbox "Created folder '$FOLDER'" \
        15 0 \
        2>&1 >/dev/tty) 
        else
        CHOICE=$(dialog --clear \
        --title "ERROR" \
        --msgbox "Some kind of error!" \
        15 0 \
        2>&1 >/dev/tty) 
    fi

    if [[ $? == $DIALOG_OK ]]; then
        main_menu
    fi
}

function folder_list() {
    DIR=$(dialog --clear \
        --title "ADD FOLDER" \
        --inputbox "Enter a folder name" \
        15 0 \
        2>&1 >/dev/tty) 

    CONTENT=$(ls $DIR)
    if [[ $? == 0 ]]; then
        CHOICE=$(dialog --clear \
        --title "FOLDER CONTENT" \
        --msgbox "$CONTENT" \
        15 0 \
        2>&1 >/dev/tty) 
        else
        CHOICE=$(dialog --clear \
        --title "ERROR" \
        --msgbox "Some kind of error!" \
        15 0 \
        2>&1 >/dev/tty) 
    fi

    # TODO Not finished

}

function folder_view() {
    sleep 0
}

function folder_modify() {
    sleep 0
}

function folder_delete() {
    sleep 0
}

main_menu
