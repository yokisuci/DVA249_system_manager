#!/usr/bin/env bash

# ----------------------
# --- PRINT MAIN MENU---
# ----------------------

function print_menu() {
    echo "***********************"
    echo "     SYSTEM MANAGER    "
    echo "-----------------------"
    echo
    echo "ni - Network Info"
    echo
    echo "ua - User Add"
    echo "ul - User List"
    echo "uv - User View"
    echo "um - User Modify"
    echo "ud - User Delete"
    echo
    echo "ga - Group Add"
    echo "gl - Group List"
    echo "gv - Group View"
    echo "gm - Group Modify"
    echo "gd - Group Delete"
    echo
    echo "fa - Folder Add"
    echo "fl - Folder List"
    echo "fv - Folder View"
    echo "fm - Folder Modify"
    echo "fd - Folder Delete"
    echo
    echo "ex - Exit"
    echo "-----------------------"
}

# ---------------------------
# --- NETWORK INFORMATION ---
# ---------------------------

function network_info() {
    sleep 0
}


# ----------------------
# --- USER FUNCTIONS ---
# ----------------------

function user_add() {
    sleep 0
}

function user_list() {
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

# -----------------------
# --- GROUP FUNCTIONS ---
# -----------------------

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

# ------------------------
# --- FOLDER FUNCTIONS ---
# ------------------------

function folder_add() {
    sleep 0
}

function folder_list() {
    sleep 0
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

while [[ $INPUT != "ex" ]]; do
    print_menu
    read -p "Choice: " INPUT
done
