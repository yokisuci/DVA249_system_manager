#!/usr/bin/env bash

# Antônio Eklöf och Patrik Beijar Odh
# Grupp 19

# -----------------
# --- MAIN MENU ---
# -----------------

# Define the dialog exit status codes
: "${DIALOG_OK=0}"
: "${DIALOG_CANCEL=1}"
: "${DIALOG_HELP=2}"
: "${DIALOG_EXTRA=3}"
: "${DIALOG_ITEM_HELP=4}"
: "${DIALOG_ESC=255}"

function main_menu() {

    CHOICE=$(dialog --clear \
        --cancel-label "Quit" \
	    --title "SYSTEM MANAGER" \
        --menu "Select an option" \
	15 0 5 \
        n "Network Information" \
        g "Group Management" \
        u "User Management" \
        f "Folder Management" \
        2>&1 >/dev/tty) 

    RETURN_CODE=$? 
    if [[ $RETURN_CODE == "$DIALOG_CANCEL" ]]; then
        EXIT=1
    fi

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




function network_info(){
	
	HOSTNAME=$(hostname)	
    	INFO=$(hostname; for INTERFACE in $(ip -br addr | awk '{print $1}' | grep -v 'lo'); do
        MAC=$(cat /sys/class/net/"$INTERFACE"/address)
        IP=$(ip -br addr | grep "$INTERFACE" | awk '{print $3}' | cut -d '/' -f 1)
        GATEWAY=$(ip -4 route show default | grep "$INTERFACE" | cut -d " " -f 3 | tail -n 1)
        STATUS=$(cat /sys/class/net/"$INTERFACE"/operstate)

        if [[ -z "$IP" ]]; then
            IP="none"
        fi

        if [[ -z "$GATEWAY" ]]; then
            GATEWAY="none"
        fi

        echo "Interface: $INTERFACE"
        echo "IP: $IP"
        echo "MAC Adress: $MAC"
        echo "Gateway: $GATEWAY"
        echo "Status: $STATUS"
        echo
    done)

	dialog --backtitle "network interfaces" \
	--title "About" \
	--msgbox "$INFO" 20 40

	RETURN_CODE=$?
	if [[ $RETURN_CODE == "$DIALOG_OK" ]]; then
		main_menu
	elif [[ $RETURN_CODE == "$DIALOG_ESC" ]]; then
		network_info
	fi
}


# -----------------------
# --- GROUP FUNCTIONS ---
# -----------------------

function group_menu() {

    CHOICE=$(dialog --title "GROUP MENU" \
        --cancel-label "Back" \
        --menu "Select an option" \
        15 0 6 \
        a "Add Group" \
        l "List Group" \
        v "List User Group" \
        m "Add user to group" \
	    i "Delete user from group" \
        d "Delete Group" \
        2>&1 >/dev/tty) 

    RETURN_CODE=$?
    if [[ $RETURN_CODE == "$DIALOG_CANCEL" ]]; then
        main_menu
    elif [[ $RETURN_CODE == "$DIALOG_ESC" ]]; then
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
                group_user_view
                ;;
            m)
                group_add_user_to_group
                ;;
            i)
                group_delete_user_from_group
		        ;;
            d)
                group_delete
                ;;
        esac

}

function group_add() {

	GROUPADD=$(dialog --title "ADD GROUP" \
		--inputbox "Enter a group name" \
		15 0 \
		2>&1 >/dev/tty)

    RETURN_CODE=$?
    if [[ $RETURN_CODE == "$DIALOG_OK" ]]; then
        groupadd "$GROUPADD" > /dev/null 2>&1
        RETURN_CODE=$?
        if [[ $RETURN_CODE == 0 ]]; then
            dialog  --title "GROUP CREATED" \
                --msgbox "Created group '$GROUPADD'" \
                15 0
		        group_menu
        elif [[ $RETURN_CODE == 9 ]]; then
            dialog --title "Error" \
                --msgbox "Group already exists" \
                15 0
		        group_menu
        elif [[ $RETURN_CODE == "$DIALOG_ESC" ]]; then
                group_menu
        fi

    else
		group_menu
	fi
}

function group_list() {
    
	ALLGROUPS=$(getent group | awk -F: '$3 > 999 {print $1}' | sort)

	dialog --backtitle "List all groups" \
	--title "All groups" \
	--msgbox "$ALLGROUPS"\
       		10 25

	RETURN_CODE=$?
	if [[ $RETURN_CODE == "$DIALOG_OK" ]]; then
		main_menu
	elif [[ $RETURN_CODE == "$DIALOG_ESC" ]]; then
		group_menu
	fi



}

function group_user_view() {
    
	SHOWGROUPUSERS=$(dialog --title "List group members" \
	--inputbox "Enter a group name" \
        15 0\
	2>&1 >/dev/tty)
	
	RETURN_CODE=$?
    if [[ $RETURN_CODE == "$DIALOG_OK" && -n "$SHOWGROUPUSERS" ]]; then
        grep "$SHOWGROUPUSERS" /etc/group > /dev/null 2>&1
    	RETURN_CODE=$?
        if [[ $RETURN_CODE == 0 ]]; then
            dialog --title "Something" \
                --msgbox "$(grep "$SHOWGROUPUSERS" /etc/group)" \
                15 0
            group_menu
        elif [[ $RETURN_CODE == 0 ]]; then
            dialog --title "Error" \
                --msgbox "No such group exists" \
                15 25
            group_menu
        elif [[ $RETURN_CODE == "$DIALOG_ESC" ]]; then
            group_menu
        fi
    elif [[ $RETURN_CODE == "$DIALOG_OK" && -z "$SHOWGROUPUSERS" ]]; then
        dialog --title "Error" \
                --msgbox "The field is empty!" \
                15 25
        group_user_view
    else
        group_menu
    fi
}

function group_add_user_to_group() {

    USERTOBEADDED=$(dialog --backtitle "GROUP MENU" \
        --title "ADD USER TO GROUP" \
        --inputbox "Enter user to be added:" \
        15 0 \
        2>&1 >/dev/tty) 

	RETURN_CODE=$?
    if [[ $RETURN_CODE == 0 ]]; then

        GROUPTOBEADDEDTO=$(dialog --backtitle "GROUP MENU" \
            --title "SELECT GROUP" \
            --inputbox "Enter group to be added to:" \
            15 0 \
            2>&1 >/dev/tty) 

	    RETURN_CODE=$?
        if [[ $RETURN_CODE == 0 ]]; then

            usermod -a -G "$GROUPTOBEADDEDTO" "$USERTOBEADDED" > /dev/null 2>&1
	        RETURN_CODE=$?
            if [[ $RETURN_CODE == 0 ]]; then
                dialog --title "Something" \
                --msgbox "'$USERTOBEADDED' was added to '$GROUPTOBEADDEDTO'" \
                15 25
            elif [[ $RETURN_CODE == 6 ]]; then
                dialog --title "Error" \
                --msgbox "Could not add user to group" \
                15 25
            else
                group_menu
            fi

        else
            group_menu
        fi
    else
        group_menu
    fi

	RETURN_CODE=$?
	if [[ $RETURN_CODE == "$DIALOG_OK" ]]; then
		main_menu
	elif [[ $RETURN_CODE == "$DIALOG_ESC" ]]; then
		group_menu
	fi
}

function group_delete_user_from_group(){

	USERTOBEREMOVED=$(dialog --title "User to be removed" \
	--inputbox "Enter user to be removed:" \
	15 25\
	2>&1 >/dev/tty)

	RETURN_CODE=$?
    if [[ $RETURN_CODE == 0 ]]; then

        GROUPTOBEREMOVEDFROM=$(dialog --title "Group to be removed from" \
        --inputbox "Enter witch group to remove the user from:" \
        15 25\
        2>&1 >/dev/tty)

	    RETURN_CODE=$?
        if [[ $RETURN_CODE == 0 ]]; then

            gpasswd -d "$USERTOBEREMOVED" "$GROUPTOBEREMOVEDFROM"
	        RETURN_CODE=$?

            if [[ $RETURN_CODE == 0 ]]; then

                dialog --title "Something" \
                --msgbox "'$USERTOBEREMOVED' was removed from '$GROUPTOBEREMOVEDFROM'"\
                15 25
                group_menu

            elif [[ $RETURN_CODE == 3 ]]; then

                dialog --title "Error" \
                --msgbox "Could not remove user from group" \
                15 25
                group_menu
            else
                group_menu
            fi
        else
            group_menu
        fi
    else
        group_menu
    fi
}

function group_delete() {
    
GROUPDELETE=$(dialog --title "Delete group" \
    --inputbox "Enter a group to delete" \
    15 25\
    2>&1 >/dev/tty)

RETURN_CODE=$?
    if [[ $RETURN_CODE == 0 ]]; then
        groupdel "$GROUPDELETE"
	    RETURN_CODE=$?
        if [[ $RETURN_CODE == 0 ]]; then
            dialog --title "Something" \
                --msgbox "'$GROUPDELETE' was deleted"\
                15 0
            group_menu
        elif [[ $RETURN_CODE == 8 ]]; then
            dialog --title "Error" \
                --msgbox "You cannot delete the primary group for $USER" \
                15 25
        elif [[ $RETURN_CODE == 6 ]]; then
            dialog --title "Error" \
                --msgbox "No group to delete" \
                15 25
            group_menu
        else
            group_menu
        fi
    else
        group_menu
    fi
}

# ----------------------
# --- USER FUNCTIONS ---
# ----------------------

function user_menu() {

    CHOICE=$(dialog --backtitle "MAIN MENU" \
        --cancel-label "Back" \
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
    if [[ $RETURN_CODE == "$DIALOG_CANCEL" ]]; then
        main_menu
    elif [[ $RETURN_CODE == "$DIALOG_ESC" ]]; then
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
	
    FULLNAME=$(dialog --backtitle "USER MENU" \
        --title "FULLNAME" \
        --inputbox "Enter your full name" \
        15 0 \
        2>&1 >/dev/tty) 

    RETURN_CODE=$?
    if [[ $RETURN_CODE == 0 ]]; then

        USERNAME=$(dialog --backtitle "USER MENU" \
            --title "USERNAME" \
            --inputbox "Enter a username" \
            15 0 \
            2>&1 >/dev/tty) 
        RETURN_CODE=$?
        if [[ $RETURN_CODE == 0 ]]; then

            PASSWORD=$(dialog --title "PASSWORD" \
                --passwordbox "Enter a password" \
                15 0 \
                2>&1 >/dev/tty) 
            RETURN_CODE=$?
            if [[ $RETURN_CODE == 0 ]]; then

                useradd -m -p "$(openssl passwd -1 "$PASSWORD")" -c "$FULLNAME" "$USERNAME"
                RETURN_CODE=$?
                if [[ $RETURN_CODE == 0 ]]; then
                    dialog --backtitle "USER MENU" \
                        --title "SUCESS" \
                        --msgbox "Added user $USERNAME" \
                        15 0
                        user_menu
                    elif [[ $RETURN_CODE == 9 ]]; then
                    dialog --backtitle "USER MENU" \
                        --title "ERROR" \
                        --msgbox "A user or group with that name already exists" \
                        15 0
                        user_menu
                    else
                        user_menu
                fi
            else
                user_menu
            fi
        else
            user_menu
        fi
    else
        user_menu
    fi
}

function user_list() {

    USER=$(getent passwd {1000..6000} | cut -d ':' -f 1)
    dialog --backtitle "USER MENU" \
        --title "USERS" \
        --msgbox "$USER" \
        15 0

    RETURN_CODE=$?
    if [[ $RETURN_CODE == "$DIALOG_OK" ]]; then
        main_menu
    elif [[ $RETURN_CODE == "$DIALOG_ESC" ]]; then
        user_list
    fi

    sleep 0
}

function user_view() {

    USER=$(dialog --backtitle "USER MENU" \
    --title "USER VIEW" \
    --inputbox "Enter a user to view:" \
    15 0 \
    2>&1 >/dev/tty) 

    RETURN_CODE=$?
    if [[ $RETURN_CODE == 0 ]]; then

        id "$USER" &> /dev/nul
        RETURN_CODE=$?
        if [[ $RETURN_CODE == 0 ]]; then

            CHOICE=$(dialog --backtitle "USER MENU" \
            --title "" \
            --menu "Select your information:" \
            15 0 5 \
            a "Attributes from /etc/passwd" \
            g "Groups" \
            2>&1 >/dev/tty) 

            RETURN_CODE=$?
            if [[ $RETURN_CODE == 0 ]]; then
                clear
                case $CHOICE in
                    a)
                        user_passwd_list
                        ;;
                    g)
                        user_group_list
                        ;;
                esac
            elif [[ $RETURN_CODE == "$DIALOG_CANCEL" ]]; then
                main_menu
            elif [[ $RETURN_CODE == "$DIALOG_ESC" ]]; then
                user_menu
            fi
        fi
    elif [[ $RETURN_CODE == 1 ]]; then
        dialog --backtitle "USER MENU" \
        --title "ERROR" \
        --msgbox "You've typed wrong username!" \
        15 0
        user_menu
    else
        user_menu
    fi

}

function user_modify() {

    USER=$(dialog --backtitle "USER MENU" \
    --title "USER MODIFY" \
    --inputbox "Enter a user to modify:" \
    15 0 \
    2>&1 >/dev/tty) 

    # Check if user exist
    if id "$USER" &> /dev/null; then
        dialog --backtitle "USER MENU" \
        --title "ERROR" \
        --msgbox "User exists!" \
        15 0
        user_menu
    else
        dialog --backtitle "USER MENU" \
        --title "ERROR" \
        --msgbox "You've typed an invalid username!" \
        15 0
        user_menu
    fi

}

function user_delete() {

    USER=$(dialog --backtitle "USER MENU" \
    --title "USER DELETE" \
    --inputbox "Enter a user to delete:" \
    15 0 \
    2>&1 >/dev/tty) 

    # Check if user exist
    if id "$USER" &> /dev/null; then
        if sudo userdel -r "$USER" &> /dev/null; then
           dialog --backtitle "USER MENU" \
            --title "SUCCESS" \
            --msgbox "Removed $USER" \
            15 0
            user_menu
        fi
    else
            dialog --backtitle "USER MENU" \
            --title "ERROR" \
            --msgbox "User doesn't!" \
            15 0
            user_menu
    fi

}

function user_passwd_list() {

    UID_PASSWD=$(getent passwd | grep "$USER" | cut -d ':' -f 3)
    GID_PASSWD=$(getent passwd | grep "$USER" | cut -d ':' -f 4)
    FULLNAME=$(getent passwd | grep "$USER" | cut -d ':' -f 5)
    HOME_DIR=$(getent passwd | grep "$USER" | cut -d ':' -f 6)
    LOGIN_SHELL=$(getent passwd | grep "$USER" | cut -d ':' -f 7)
    COMPLETE_INFO="UID: $UID_PASSWD\nGID: $GID_PASSWD\nFullname: $FULLNAME\nHome dir: $HOME_DIR\nLogin shell: $LOGIN_SHELL\n"

    dialog --backtitle "USER MENU" \
    --title "USERS" \
    --msgbox "$COMPLETE_INFO" \
    15 0

    RETURN_CODE=$?
    if [[ $RETURN_CODE == "$DIALOG_OK" ]]; then
        user_menu
    elif [[ $RETURN_CODE == "$DIALOG_ESC" ]]; then
        user_menu
    fi
}

function user_group_list() {
    USER=$(getent passwd {1000..6000} | cut -d ':' -f 1)
    dialog --backtitle "USER MENU" \
        --title "USERS" \
        --msgbox "$USER" \
        15 0 

    RETURN_CODE=$?
    if [[ $RETURN_CODE == "$DIALOG_OK" ]]; then
        user_menu
    elif [[ $RETURN_CODE == "$DIALOG_ESC" ]]; then
        user_menu
    fi
}

# ------------------------
# --- FOLDER FUNCTIONS ---
# ------------------------

function folder_menu() {

    CHOICE=$(dialog --title "FOLDER MENU" \
        --cancel-label "Back" \
        --menu "Select an option" \
        15 0 5 \
        a "Add Folder" \
        v "View Folder" \
        m "Modify Folder" \
        d "Delete Folder" \
        2>&1 >/dev/tty) 

    RETURN_CODE=$?
    if [[ $RETURN_CODE == 0 ]]; then
        clear
        case $CHOICE in
            a)
                folder_add
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
    elif [[ $RETURN_CODE == "$DIALOG_CANCEL" ]]; then
        main_menu
    else
        folder_menu
    fi
}

function folder_add() {

    FOLDER=$(dialog --title "ADD FOLDER" \
        --inputbox "Enter a folder name" \
        15 0 \
        2>&1 >/dev/tty) 

    RETURN_CODE=$?
    if [[ $RETURN_CODE == 0 ]]; then
        mkdir "$FOLDER"
        RETURN_CODE=$?
        if [[ $RETURN_CODE == 0 ]]; then
            dialog --title "FOLDER CREATED" \
            --msgbox "Created folder '$FOLDER'" \
            15 0
            main_menu
        elif [[ $RETURN_CODE == "$DIALOG_ESC" ]]; then
            folder_menu
        else
            dialog --title "ERROR" \
            --msgbox "Couldn't create folder!" \
            15 0
            folder_menu
        fi
    else
        main_menu
    fi

}

function folder_view() {
   DIR=$(dialog --title "DELETE A FOLDER" \
   --inputbox "What folder do you want to view?" \
   15 0 \
   2>&1 >/dev/tty) 

   RETURN_CODE=$?
   if [[ $RETURN_CODE == 0 ]]; then
        ls "$DIR"
        RETURN_CODE=$?
        if [[ $RETURN_CODE == 0 ]]; then
            dialog --title "VIEW FOLDER" \
            --msgbox "$CONTENT" \
            15 0
            main_menu
        else
            dialog --title "ERROR" \
            --msgbox "Folder does not exist!" \
            15 0
            folder_menu
        fi
   else
        folder_menu
   fi

}

function folder_modify() {
    MENU=$(dialog --title "Folder modify menu" \
	    --menu "Select an option" \
	    15 0 2 \
	    l "List attributes" \
	    e "Edit attributes" \
	    2>&1 >/dev/tty)

    RETURN_CODE=$?
    if [[ $RETURN_CODE == 0 ]]; then
        clear
        case $MENU in 
            l) folder_list_attributes
                ;;
            e) folder_edit_attributes
                ;;
        esac
    else
	   folder_menu
    fi
}

function folder_edit_attributes(){

	FOLDER=$(dialog --title "Edit folder attributes" \
		--inputbox "Enter a folder name:" \
		15 0\
		2>&1 >/dev/tty)

    RETURN_CODE=$?
    if [[ $RETURN_CODE == 0 ]]; then

        MENU=$(dialog --title "Folder modify menu" \
            --menu "Select an option" \
            15 0 2 \
            o "Change owner" \
            p "Change permissions" \
            s "Change sticky bit" \
            g "Change SetGID" \
            m "Change last modified" \
            2>&1 >/dev/tty)

        RETURN_CODE=$?
        if [[ $RETURN_CODE == 0 ]]; then
            clear
            case $MENU in 
                o) change_owner
                    ;;
                p) change_permissions
                    ;;
                s) change_sticky_bit
                    ;;
                g) change_setgid
                    ;;
                m) change_last_modified
                    ;;
            esac
        else
           folder_menu
        fi

    else
        folder_menu
	fi
}

function change_owner() {
	OWNER=$(dialog --title "Set owner to folder" \
		--inputbox "What owner do you want to set for the folder?" \
		15 0\
		2>&1 >/dev/tty)

    RETURN_CODE=$?
    if [[ $RETURN_CODE == "$DIALOG_OK" ]]; then
        chown "$OWNER": "$FOLDER"
        RETURN_CODE=$?
        if [[ $RETURN_CODE == 0 ]]; then
            dialog --title "Changed owner" \
                --msgbox "$FOLDER is now owned by $OWNER" \
                15 0
                main_menu
        else
            dialog --title "Error" \
               --msgbox "Something went wrong!" \
               15 0
               main_menu
        fi
    elif [[ $RETURN_CODE == "$DIALOG_ESC" ]]; then
        folder_menu
    elif [[ $RETURN_CODE == "$DIALOG_CANCEL" ]]; then
        folder_menu
    fi
}

function change_permissions() {
    MENU=$(dialog --title "Set permissions" \
        --menu "Choose option" \
        15 0 2 \
        sr "Set read permission" \
        sw "Set write permission" \
        rr "Remove read permission" \
        rw "Remove write permission" \
        2>&1 >/dev/tty)

    RETURN_CODE=$?
    if [[ $RETURN_CODE == 0 ]]; then
        clear
        case $MENU in 
            sr) chmod +r "$FOLDER"
                RETURN_CODE=$?
                if [[ $RETURN_CODE == 0 ]]; then
                    dialog --title "Set read" \
                    --msgbox "Read permissions set" \
                    15 0
                    main_menu 
                else
                    dialog --title "Error" \
                    --msgbox "Some kind of error" \
                    15 0
                    main_menu 
                fi
                ;;
            sw) chmod +w "$FOLDER"
                RETURN_CODE=$?
                if [[ $RETURN_CODE == 0 ]]; then
                    dialog --title "Set write" \
                    --msgbox "Write permissions set" \
                    15 0
                    main_menu 
                else
                    dialog --title "Error" \
                    --msgbox "Some kind of error" \
                    15 0
                    main_menu 
                fi
                ;;
            rr) chmod a-r "$FOLDER"
                RETURN_CODE=$?
                if [[ $RETURN_CODE == 0 ]]; then
                    dialog --title "Remove read" \
                    --msgbox "Read permissions removed" \
                    15 0
                    main_menu 
                else
                    dialog --title "Error" \
                    --msgbox "Some kind of error" \
                    15 0
                    main_menu 
                fi
                ;;
            rw) chmod -w "$FOLDER"
                RETURN_CODE=$?
                if [[ $RETURN_CODE == 0 ]]; then
                    dialog --title "Remove write" \
                    --msgbox "Write permissions Removed" \
                    15 0
                    main_menu 
                else
                    dialog --title "Error" \
                    --msgbox "Some kind of error" \
                    15 0
                    main_menu 
                fi
                ;;
        esac
    else
        folder_menu
    fi
}

function change_sticky_bit() {
        MENU=$(dialog --title "Set sticky bit" \
            --menu "Choose option" \
            15 0 2 \
            s "Set sticky bit" \
            r "Remove sticky bit" \
            2>&1 >/dev/tty)

        RETURN_CODE=$?
        if [[ $RETURN_CODE == 0 ]]; then
            clear
            case $MENU in 
                s) chmod +t "$FOLDER"
                    RETURN_CODE=$?
                    if [[ $RETURN_CODE == 0 ]]; then
                        dialog --title "Sticky" \
                        --msgbox "Sticky bit set" \
                        15 0
                       main_menu 
                    else
                        dialog --title "Error" \
                        --msgbox "Some kind of error" \
                        15 0
                       main_menu 
                    fi
                    ;;
                r) chmod -t "$FOLDER"
                    RETURN_CODE=$?
                    if [[ $RETURN_CODE == 0 ]]; then
                        dialog --title "Sticky" \
                        --msgbox "Sticky bit removed" \
                        15 0
                       main_menu 
                    else
                        dialog --title "Error" \
                        --msgbox "Some kind of error" \
                        15 0
                       main_menu 
                    fi
                    ;;
            esac
        else
           folder_menu
        fi
}

function change_setgid() {
        MENU=$(dialog --title "Set SetGID" \
            --menu "Choose option" \
            15 0 2 \
            s "Set SetGID" \
            r "Remove SetGID" \
            2>&1 >/dev/tty)

        RETURN_CODE=$?
        if [[ $RETURN_CODE == 0 ]]; then
            clear
            case $MENU in 
                s) chmod g+s "$FOLDER"
                    RETURN_CODE=$?
                    if [[ $RETURN_CODE == 0 ]]; then
                        dialog --title "SetGID" \
                        --msgbox "SetGID set" \
                        15 0
                       main_menu 
                    else
                        dialog --title "Error" \
                        --msgbox "Some kind of error" \
                        15 0
                       main_menu 
                    fi
                    ;;
                r) chmod g-s "$FOLDER"
                    RETURN_CODE=$?
                    if [[ $RETURN_CODE == 0 ]]; then
                        dialog --title "SetGID" \
                        --msgbox "SetGID removed" \
                        15 0
                       main_menu 
                    else
                        dialog --title "Error" \
                        --msgbox "Some kind of error" \
                        15 0
                       main_menu 
                    fi
                    ;;
            esac
        else
           folder_menu
        fi
}

function change_last_modified() {
	TIME=$(dialog --title "Change modification time" \
        --inputbox "Enter a new timestamp (YYMMhhmm):" \
		15 0\
		2>&1 >/dev/tty)

        RETURN_CODE=$?
        if [[ $RETURN_CODE == 0 ]]; then
            touch -t "$TIME" "$FOLDER"
            RETURN_CODE=$?
            if [[ $RETURN_CODE == 0 ]]; then
                dialog --title "Changed modified" \
                --msgbox "Last modified is set to $TIME" \
                15 0
                main_menu 
            else
                 dialog --title "Error" \
                 --msgbox "Some kind of error" \
                 15 0
                 main_menu 
            fi
        else
            folder_menu
        fi
}

function folder_list_attributes(){

	SHOWFOLDER=$(dialog --title "Show folder attributes" \
		--inputbox "Enter a folder name:" \
		15 0\
		2>&1 >/dev/tty)

	RETURN_CODE=$?
    if [[ $RETURN_CODE == 0 ]]; then
        if [[ -d $SHOWFOLDER ]]; then

	    TIME=$(date +"%y%m%d %H:%M" -r "$SHOWFOLDER")
            OWNER=$(stat -c '%U' "$SHOWFOLDER")
	    if test -w "$SHOWFOLDER"; then
		    WRITABLE="yes"
	    else
		    WRITABLE="no"
	    fi

	    if test -r "$SHOWFOLDER"; then
		    READABLE="yes"
	    else
		    READABLE="no"
	    fi

	    if test -k "$SHOWFOLDER"; then
		    HASSTICKYBIT="yes"
	    else
		    HASSTICKYBIT="no"
	    fi

	    if test -g "$SHOWFOLDER"; then
		    HASSETGID="yes"
	    else
		    HASSETGID="no"
	    fi

	        RETURN_CODE=$?
            if [[ $RETURN_CODE == 0 ]]; then 
                dialog --msgbox "\n
			Owner: $OWNER \n
			Last time modified:$TIME \n
			--- Permissions -- \n
			Writable: $WRITABLE \n
			Readable: $READABLE \n
			Has sticky bit: $HASSTICKYBIT \n
			Has set gid: $HASSETGID"  \
                	15 45	
                	main_menu
            else
                	main_menu
           fi
        else
         dialog --title "FOLDER DELETED" \
            --msgbox "Folder doesn't exist" \
            15 0
            folder_menu
        fi
    else
        folder_menu
	fi
}

function folder_delete() {
   DIR=$(dialog --title "DELETE A FOLDER" \
   --inputbox "What folder do you want to delete?" \
   15 0 \
   2>&1 >/dev/tty) 

   RETURN_CODE=$?
   if [[ $RETURN_CODE == 0 ]]; then
        rmdir "$DIR"
        RETURN_CODE=$?
        if [[ $RETURN_CODE == 0 ]]; then
            dialog --title "FOLDER DELETED" \
            --msgbox "$DIR deleted" \
            15 0
            main_menu
        else
            dialog --title "ERROR" \
            --msgbox "Folder does not exist!" \
            15 0
            main_menu
        fi
    else
        folder_menu
    fi
}

if [[ $EUID == 0 ]]; then
    EXIT=0
    while [[ $EXIT == 0 ]]; do
        main_menu
    done
else
    echo "This script must run as root"
fi
