#!/usr/bin/env bash

# set -x

source $HOME/.bash_profile

BM_DIR="${XDG_CONFIG_HOME:-"$HOME/.config"}/bm"
SEP=" :: "

mkdir -p "$BM_DIR"

categories="$(ls -w 1 --color=never --hyperlink=never "$BM_DIR" 2> /dev/null)"

notify() {
  local msg="$1"
  notify-send "bm" "$msg"
}

get_category() {
  local category="$(echo -e "$categories" | rofi -dmenu -i -p "Category:")"
  [ -z "$category" ] && exit 0

  local category_file="$BM_DIR/$category"

  if [ ! -f $category_file ]; then
    notify "$category_file does not exist"
    exit 0
  fi

  echo "$category_file"
}

pick() {
  local category_file="$(get_category)"
  [ -z "$category_file" ] && exit 0

  local runner="$(head -n 1 "$category_file" | awk -F"$SEP" '{print $2}' 2> /dev/null)"
  [ -z "$runner" ] && exit 0

  local bookmark="$(tail -n +2 "$category_file" | awk -F"$SEP" '{print $1}' | rofi -dmenu -i -p "Bookmark:" 2> /dev/null)"
  [ -z "$bookmark" ] && exit 0

  local val="$(tail -n +2 "$category_file" | grep "$bookmark$SEP" | awk -F"$SEP" '{print $2}')"
  eval "$runner '$val'" &
  disown
}

add() {
  local name="$(rofi -dmenu -p "Entry name:")"
  [ -z "$name" ] && exit 0

  local val="$(rofi -dmenu -p "Entry value:")"
  [ -z "$val" ] && exit 0

  local category="$(echo -en "[NEW]\n$categories" | rofi -dmenu -p "Entry category:")"
  [ -z "$category" ] && exit 0

  local category_file="$BM_DIR/$category"
  if [ $category == "[NEW]" ]; then
    category="$(rofi -dmenu -p "New Category:")"
    [ -z "$category" ] && exit 0

    category_file="$BM_DIR/$category"
    touch "$category_file"

    local runner="$(rofi -dmenu -p "Runner:")"
    [ -z "$runner" ] && exit 0
    echo "RUNNER$SEP$runner" >> $category_file && notify "Created category '$category' and added '$name'"
  fi

  touch "$category_file"

  [ -n "$(cat $category_file | grep "$name$SEP" 2> /dev/null)" ] && notify "$name already exists" && exit 0

  echo "$name$SEP$val" >> $category_file && notify "Added '$name' to '$category' category"
}

edit() {
  local category_file="$(get_category)"
  [ -z "$category_file" ] && exit 0

  local choice="$(echo -e "Category\nBookmark" | rofi -dmenu -i -p "What are you editing:")"
  [ -z "$choice" ] && exit 0

  case "$choice" in
  Category)
    local category="$(basename $category_file)"

    choice="$(echo -e "Name\nRunner" | rofi -dmenu -i -p "Edit:")"
    [ -z "$choice" ] && exit 0

    case "$choice" in
    Name)
      local new_category_name="$(rofi -dmenu -p "Edit name:" -filter "$category")"
      [ -z "$new_category_name" ] && exit 0
      local new_category_file="$BM_DIR/$new_category_name"

      if [ -f $new_category_file ]; then
        notify "'$new_category_file' already exists"
        exit 1
      fi

      mv $category_file $new_category_file && notify "Renamed category '$category' to '$new_category_name'"
      ;;
    Runner)
      local runner="$(head -n 1 "$category_file" | awk -F"$SEP" '{print $2}' 2> /dev/null)"
      [ -z "$runner" ] && exit 0

      local choice="$(rofi -dmenu -p "Edit name:" -filter "$runner")"
      [ -z "$choice" ] && exit 0
      {
        echo "RUNNER$SEP$choice"
        tail -n +2 "$category_file"
      } > "$BM_DIR/temp_file" && mv "$BM_DIR/temp_file" "$category_file"
      notify "'$category' RUNNER set to '$choice'"
      ;;
    *)
      notify "Unknown command $choice"
      exit 1
      ;;
    esac
    ;;
  Bookmark)
    local bookmark="$(tail -n +2 "$category_file" | awk -F"$SEP" '{print $1}' | rofi -dmenu -p "Bookmark:" 2> /dev/null)"
    [ -z "$bookmark" ] && exit 0

    local choice="$(echo -e "Name\nValue" | rofi -dmenu -p "Edit:")"
    case "$choice" in
    Name)
      local new_bookmark="$(rofi -dmenu -p "Edit name:" -filter "$bookmark")"
      [ -z "$new_bookmark" ] && exit 0

      [ -n "$(tail -n +2 "$category_file" | grep "$new_bookmark$SEP")" ] && notify "'$new_bookmark' bookmark already exists" && exit 0

      sed -i "s/$bookmark$SEP/$new_bookmark$SEP/" $category_file && notify "'$bookmark' renamed to '$new_bookmark'"
      ;;
    Value)
      local val="$(tail -n +2 "$category_file" | grep "$bookmark$SEP" | awk -F"$SEP" '{print $2}')"

      local new_val="$(rofi -dmenu -p "Edit value:" -filter "$val")"
      [ -z "$new_val" ] && exit 0

      sed -i "s|$bookmark$SEP$val|$bookmark$SEP$new_val|" $category_file && notify "'$bookmark' set to '$new_val'"
      ;;
    *)
      notify "Unknown command $choice"
      exit 1
      ;;
    esac
    ;;
  *)
    notify "Unknown command $choice"
    exit 1
    ;;
  esac
}

delete() {
  local category_file="$(get_category)"
  [ -z "$category_file" ] && exit 0

  local choice="$(echo -e "Category\nBookmark" | rofi -dmenu -i -p "What are you deleting:")"

  case "$choice" in
  Category)
    choice="$(echo -e "Yes\nNo" | rofi -dmenu -p "Are you sure you want to delete category '$(basename $category_file)':")"
    [ -z "$choice" ] && exit 0

    [ $choice == "Yes" ] && rm -rf $category_file && notify "Deleted category $choice"
    ;;
  Bookmark)
    local bookmark="$(tail -n +2 "$category_file" | awk -F"$SEP" '{print $1}' | rofi -dmenu -i -p "Bookmark:" 2> /dev/null)"
    [ -z "$bookmark" ] && exit 0

    local line_no="$(cat "$category_file" | grep -n "$bookmark$SEP" | grep -Po "^\d+")"
    [ -z "$line_no" ] && notify "Could not determine bookmark line no" && exit 0

    choice="$(echo -e "Yes\nNo" | rofi -dmenu -p "Are you sure you want to delete bookmark '$bookmark':")"
    [ -z "$choice" ] && exit 0

    [ $choice == "Yes" ] && sed -i ""$line_no"d" $category_file && notify "Deleted bookmark '$bookmark'"
    ;;
  *)
    notify "Unknown command $choice"
    exit 1
    ;;
  esac
}

if [ -n "$1" ]; then
  case "$1" in
  pick) pick ;;
  add) add ;;
  edit) edit ;;
  delete) delete ;;
  *) exit 1 ;;
  esac
else
  choices="Pick\nAdd\nEdit\nDelete"

  choice="$(echo -en $choices | rofi -dmenu -i -p "Bookmark Menu:")"

  [ -z "$choice" ] && exit 0

  case "$choice" in
  Pick) pick ;;
  Add) add ;;
  Edit) edit ;;
  Delete) delete ;;
  *)
    notify "Unknown command $choice"
    exit 1
    ;;
  esac
fi
exit 0
