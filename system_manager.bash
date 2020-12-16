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
    
    CHOICE=$(dialog --clear \
    	--title "NETWORK INFO" \
        --menu "Select an option" \
        15 0 4\
        a "Return to main menu" \
        b "Print computer name"\
        c "Print all network devices name"\
        2>&1 >/dev/tty)

    RETURN_CODE=$? 
    if [[ $RETURN_CODE == $DIALOG_CANCEL ]]; then
        main_menu
    elif [[ $RETURN_CODE == $DIALOG_ESC ]]; then
        network_info
    fi

	clear
	case $CHOICE in 
		a)
		    main_menu
		    ;;
		b) 
			computer_name
			;;
		c)
		    name_network_interfaces
			;;
	esac
}

function computer_name(){
	dialog --backtitle "Computer Name" \
	--title "About" \
	--msgbox $HOSTNAME 10 20

    RETURN_CODE=$? 
    if [[ $RETURN_CODE == $DIALOG_OK ]]; then
        network_info
    elif [[ $RETURN_CODE == $DIALOG_ESC ]]; then
        network_info
    fi
}


function name_network_interfaces(){
	
	
	IP=$(hostname -I)
	MAC=$(ip a | grep ether | cut -d " " -f6)
	GATEWAY=$(ip -4 route show default | cut -d " " -f 3)
	UP=$(ip a | awk '/state UP/ {printf $2}')
	DOWN=$(ip a | awk '/state DOWN/ {printf $2}')

	dialog --backtitle "network interfaces" \
	--title "About" \
	--msgbox "  Ip address:  $IP\n
		Mac address:  $MAC\n
		Gateway:  $GATEWAY\n
		IP addr up:  $UP\n
		IP addr down:  $DOWN" 10 40

	RETURN_CODE=$?
	if [[ $RETURN_CODE == $DIALOG_OK ]]; then
		main_menu
	elif [[ $RETURN_CODE == $DIALOG_ESC ]]; then
		network_info
	fi
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

    RETURN_CODE=$?
    if [[ $RETURN_CODE == $DIALOG_CANCEL ]]; then
        main_menu
    elif [[ $RETURN_CODE == $DIALOG_ESC ]]; then
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
    
	dialog --backtitle "Add group" \
	--title "About" \
	--msgbox "Some information will be put here later..." 10 25

	RETURN_CODE=$?
	if [[ $RETURN_CODE == $DIALOG_OK ]]; then
		main_menu
	elif [[ $RETURN_CODE == $DIALOG_ESC ]]; then
		group_menu
	fi
}

function group_list() {
    
	dialog --backtitle "List all groups" \
	--title "About" \
	--msgbox "Some information will be put here later..." 10 25

	RETURN_CODE=$?
	if [[ $RETURN_CODE == $DIALOG_OK ]]; then
		main_menu
	elif [[ $RETURN_cODE == $DIALOG_ESC ]]; then
		group_menu
	fi
}

function group_view() {
    
	dialog --backtitle "View group" \
	--title "About" \
	--msgbox "Some information will be put here later..." 10 25

	RETURN_CODE=$?
	if [[ $RETURN_CODE == $DIALOG_OK ]]; then
		main_menu
	elif [[ $RETURN_CODE == $DIALOG_ESC ]]; then
		group_menu
	fi
}

function group_modify() {
    
	dialog --backtitle "Modify group" \
	--title "About" \
	--msgbox "Some information will be put here later..." 10 25

	RETURN_CODE=$?
	if [[ $RETURN_CODE == $DIALOG_OK ]]; then
		main_menu
	elif [[ $RETURN_CODE == $DIALOG_ESC ]]; then
		group_menu
	fi
}

function group_delete() {
    
	dialog --backtitle "Modify group" \
	--title "About" \
	--msgbox "Some information will be put here later..." 10 25

	RETURN_CODE=$?
	if [[ $RETURN_CODE == $DIALOG_OK ]]; then
		main_menu
	elif [[ $RETURN_CODE == $DIALOG_ESC ]]; then
		group_menu
	fi

}

# ----------------------
# --- USER FUNCTIONS ---
# ----------------------

function user_menu() {

    CHOICE=$(dialog --clear \
        --backtitle "MAIN MENU" \
        --title "USER MENU" \
        --menu "Select an option" \
        15 0 5 \
        a "Add User" \
        l "List User" \
        v "View User" \
        m "Modify User" \
        d "Delete User" \
        2>&1 >/dev/tty) 

    RETURN_CODE=$?
    if [[ $RETURN_CODE == $DIALOG_CANCEL ]]; then
        main_menu
    elif [[ $RETURN_CODE == $DIALOG_ESC ]]; then
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
        --backtitle "USER MENU" \
        --title "FULLNAME" \
        --inputbox "Enter your full name" \
        15 0 \
        2>&1 >/dev/tty) 

    USERNAME=$(dialog --clear \
        --backtitle "USER MENU" \
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
        --backtitle "USER MENU" \
        --title "USERS" \
        --msgbox "$USER" \
        15 0 \
        2>&1 >/dev/tty) 

    RETURN_CODE=$?
    if [[ $RETURN_CODE == $DIALOG_OK ]]; then
        main_menu
    elif [[ $RETURN_CODE == $DIALOG_ESC ]]; then
        user_list
    fi

    sleep 0
}

function user_view() {

    USER=$(dialog --clear \
        --backtitle "USER MENU" \
        --title "USER VIEW" \
        --inputbox "Enter a user to view:" \
        15 0 \
        2>&1 >/dev/tty) 

    # Check if user exist
    if id "$USER" &> /dev/null; then
        CHOICE=$(dialog --clear \
            --backtitle "USER MENU" \
            --title "ERROR" \
            --msgbox "User exist!" \
            15 0 \
            2>&1 >/dev/tty) 
            user_menu
    else
        CHOICE=$(dialog --clear \
            --backtitle "USER MENU" \
            --title "ERROR" \
            --msgbox "You've typed wrong username!" \
            15 0 \
            2>&1 >/dev/tty) 
        user_menu
    fi

}

function user_modify() {

    USER=$(dialog --clear \
        --backtitle "USER MENU" \
        --title "USER MODIFY" \
        --inputbox "Enter a user to modify:" \
        15 0 \
        2>&1 >/dev/tty) 

    # Check if user exist
    if id "$USER" &> /dev/null; then
        CHOICE=$(dialog --clear \
            --backtitle "USER MENU" \
            --title "ERROR" \
            --msgbox "User exists!" \
            15 0 \
            2>&1 >/dev/tty) 
        user_menu
    else
        CHOICE=$(dialog --clear \
            --backtitle "USER MENU" \
            --title "ERROR" \
            --msgbox "You've typed an invalid username!" \
            15 0 \
            2>&1 >/dev/tty) 
        user_menu
    fi

}

function user_delete() {

    USER=$(dialog --clear \
        --backtitle "USER MENU" \
        --title "USER DELETE" \
        --inputbox "Enter a user to delete:" \
        15 0 \
        2>&1 >/dev/tty) 

    # Check if user exist
    if id "$USER" &> /dev/null; then
        CHOICE=$(dialog --clear \
            --backtitle "USER MENU" \
            --title "ERROR" \
            --msgbox "User exist!" \
            15 0 \
            2>&1 >/dev/tty) 
        user_menu
    else
        CHOICE=$(dialog --clear \
            --backtitle "USER MENU" \
            --title "ERROR" \
            --msgbox "User doesn't!" \
            15 0 \
            2>&1 >/dev/tty) 
        user_menu
    fi

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

    RETURN_CODE=$?
    if [[ $RETURN_CODE == $DIALOG_CANCEL ]]; then
        main_menu
    elif [[ $RETURN_CODE == $DIALOG_ESC ]]; then
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

if [[ $EUID == 0 ]]; then
    main_menu
else
    echo "This script must run as root"
fi
