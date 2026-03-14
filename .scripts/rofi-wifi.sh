#!/usr/bin/env bash

set -x

readonly DEVICE_STATUS_DEVICE=1
readonly DEVICE_STATUS_STATE=3
readonly DEVICE_STATUS_CONNECTION=4

get_network_info() {
  local device="$1"
  local pos="$2"
  nmcli d status | grep "$device" | sed 's/\s\{2,\}/\|/g' | awk -F "|" -v pos="$pos" '{print $pos}'
}

notify() {
  local status="$1"
  notify-send -t 1500 "Network Manager" "$status"
}

show_menu() {
  # This prints a beautifully formatted list. bash was a mistake
  list=$(
    nmcli --fields SSID,SECURITY,BARS d wifi list \
      |
      # Remove networks without a name
      sed '/^--/d' \
      |
      # Remove the first row
      sed 1d \
      |
      # Replace WPA with a lock. These are network with security
      sed -E "s/WPA*.?\S/~~/g" \
      |
      # Replace -- with an open lock. These are networks without security
      sed -E "s/ -- /~~/g" \
      |
      # Replace double lock sign with just one comes up when there are multiple WPA
      sed "s/~~ ~~/~~/g" \
      |
      # Add ~ to start of connection strength to use to split the column
      sed "s/▂/~▂/g" \
      |
      # Arrange into columns
      column -t -s '~'
  )

  enable_network="Enable Network 󰚥"
  disable_network="Disable Network 󱐤"

  connection_state=$(nmcli -fields WIFI g)
  if [[ $connection_state =~ "enabled" ]]; then
    connection_toggle="$disable_network"
  elif [[ $connection_state =~ "disabled" ]]; then
    connection_toggle="$enable_network"
  fi

  connect_wifi="Connect Wi-Fi 󰤨"
  disconnect_wifi="Disconnect Wi-Fi 󰤮"
  wifi_unavailable="*** Wi-Fi Unavailble ***"

  wifi_state=$(get_network_info "wifi" $DEVICE_STATUS_STATE)
  if [[ $wifi_state == "connected" ]]; then
    wifi_toggle="$disconnect_wifi"
  elif [[ $wifi_state == "disconnected" ]]; then
    wifi_toggle="$connect_wifi"
  else
    wifi_toggle="$wifi_unavailable"
  fi

  connect_eth="Connect Ethernet 󰈀"
  disconnect_eth="Disconnect Ethernet 󰈀"
  eth_unavailable="*** Ethernet Unavailable ***"

  eth_state=$(get_network_info "ethernet" $DEVICE_STATUS_STATE)
  if [[ $eth_state == "connected" ]]; then
    eth_toggle="$disconnect_eth"
  elif [[ $eth_state == "disconnected" ]]; then
    eth_toggle="$connect_eth"
  else
    eth_toggle="$eth_unavailable"
  fi

  edit_connections="Edit Connections "
  scan="Scan 󱉶"
  restart="Restart Connection "
  manual="Manual Connection 󱘖"

  # Doing this instead of getting the IN-USE field as calling `awk -F '  ' '!seen[$1]++'` could remove that line
  connected_wifi="$(get_network_info "wifi" $DEVICE_STATUS_CONNECTION)"
  connected_indicator="[connected]"
  if [ -n "$connected_wifi" ]; then
    list="$(echo -e "$list" | sed "s/\($connected_wifi.*\)\(\\)/\1 \2 $connected_indicator/")"
  fi

  [ -n "$list" ] && list="$list\n"

  menu_sep="----------"
  echo "$list"
  echo -e "$list$menu_sep\n$scan\n$connection_toggle\n$wifi_toggle\n$eth_toggle\n$manual\n$edit_connections\n$restart"

  choice=$(
    echo -e "$list$menu_sep\n$scan\n$connection_toggle\n$wifi_toggle\n$eth_toggle\n$manual\n$edit_connections\n$restart" \
      |
      # Remove duplicate SSIDs
      awk -F '  ' '!seen[$1]++' \
      | rofi -dmenu -p "Wi-Fi SSID:"
  )
  [ -z "$choice" ] && exit 1

  choice_SSID=$(echo "$choice" | sed 's/\s\{2,\}/\|/g' | awk -F "|" '{print $1}')

  case "$choice" in
  "$enable_network")
    nmcli r all on && notify "Enabled Network"
    show_menu
    ;;
  "$disable_network")
    nmcli r all off && notify "Disabled Network"
    show_menu
    ;;
  "$connect_wifi")
    nmcli d connect $(get_network_info "wifi" $DEVICE_STATUS_DEVICE) && notify "Connected Wi-Fi"
    show_menu
    ;;
  "$disconnect_wifi")
    nmcli d disconnect $(get_network_info "wifi" $DEVICE_STATUS_DEVICE) && notify "Disconnected Wi-Fi"
    show_menu
    ;;
  "$connect_eth")
    nmcli d connect $(get_network_info "ethernet" $DEVICE_STATUS_DEVICE) && notify "Connected Ethernet"
    show_menu
    ;;
  "$disconnect_eth")
    nmcli d disconnect $(get_network_info "ethernet" $DEVICE_STATUS_DEVICE) && notify "Disconnected Ethernet"
    show_menu
    ;;
  "$edit_connections")
    nm-connection-editor
    show_menu
    ;;
  "$scan")
    notify "Scanning..."
    nmcli d wifi rescan
    show_menu
    exit
    ;;
  "$restart")
    notify "Restarting network"
    nmcli n off && sleep 3 && nmcli n on && notify "Restarted Network"
    show_menu
    ;;
  "$manual")
    manual_ssid=$(rofi -dmenu -p "Manual SSID: ")

    [ -z "$manual_ssid" ] && exit 1

    manual_pass=$(rofi -dmenu -password -p "Manual Password: ")

    # If the user entered a manual password, then use the password nmcli command
    notify "Attempting connection..."
    if [ -z "$manual_pass" ]; then
      nmcli d wifi connnect "$manual_ssid" && notify 'Connection successful' || notify 'Connection failed'
    else
      nmcli d wifi connect "$manual_ssid" password "$manual_pass" && notify 'Connection successful' || notify 'Connection failed'
    fi
    ;;
  "$menu_sep" | "$wifi_unavailable" | "$eth_unavailable" | "")
    exit 1
    ;;
  *)
    if [[ $choice == *"$connected_indicator" ]]; then
      exit
    fi

    # get list of known connections
    known_connections=$(nmcli c show)

    # Parses the list of preconfigured connections to see if it already contains the chosen SSID
    if [ "$(echo "$known_connections" | grep "$choice_SSID" -o)" == "$choice_SSID" ]; then
      notify "Attempting connection..."
      nmcli c up "$choice_SSID" && notify 'Connection successful' || notify 'Connection failed'
    else
      if [[ $choice =~ "" ]]; then
        wifi_pass=$(rofi -dmenu -password -p "WiFi Password: ")
      fi
      notify "Attempting connection..."
      if [ -z "$wifi_pass" ]; then
        nmcli d wifi connect "$choice_SSID" && notify 'Connection successful' || notify 'Connection failed'
      else
        nmcli d wifi connect "$choice_SSID" password "$wifi_pass" && notify 'Connection successful' || notify 'Connection failed'
      fi
    fi
    ;;
  esac
}

show_menu
