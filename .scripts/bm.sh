#!/usr/bin/env bash

set -x

source $HOME/.bash_profile

BM_DIR="${XDG_CONFIG_HOME:-"$HOME/.config"}/bm"
SEP=" :: "

mkdir -p "$BM_DIR"

categories=$(ls -w 1 --color=never --hyperlink=never "$BM_DIR" 2>/dev/null)

get_category(){
  category=$(echo -e "$categories" | rofi -dmenu -p "Category:")
  [ -z "$category" ] && exit 0

  category_file="$BM_DIR/$category"

  if [ ! -f $category_file ]; then
    notify-send "$category_file does not exist"
    exit 0
  fi

  echo $category_file
}

pick(){
  category_file=$(get_category)
  runner=$(head -n 1 "$category_file" | awk -F"$SEP" '{print $2}' 2>/dev/null)
  [ -z "$runner" ] && exit 0

  bookmark=$(tail -n +2 "$category_file" | awk -F"$SEP" '{print $1}' | rofi -dmenu -p "Bookmark:" 2>/dev/null)
  [ -z "$bookmark" ] && exit 0

  val=$(tail -n +2 "$category_file"| grep "$bookmark$SEP" | awk -F"$SEP" '{print $2}')
  eval "$runner $val" & disown
}

add(){
  name=$(rofi -dmenu -p "Entry name:")
  [ -z "$name" ] && exit 0

  val=$(rofi -dmenu -p "Entry value:")
  [ -z "$val" ] && exit 0

  category=$(echo -en "[NEW]\n$categories" | rofi -dmenu -p "Entry category:")
  [ -z "$category" ] && exit 0

  category_file=$BM_DIR/$category
  if [ $category == "[NEW]" ]; then
    category=$(rofi -dmenu -p "New Category:")
    [ -z "$category" ] && exit 0

    category_file=$BM_DIR/$category
    touch "$category_file"

    runner=$(rofi -dmenu -p "Runner:")
    [ -z "$runner" ] && exit 0
    echo "RUNNER$SEP$runner" >> $category_file
  fi

  touch "$category_file"

  [ -n "$(cat $category_file | grep "$name$SEP" 2>/dev/null)" ] && notify-send "$name already exists" && exit 0

  echo "$name$SEP$val" >> $category_file
}

edit(){
  category_file=$(get_category)

  choice=$(echo -e "category\nbookmark" | rofi -dmenu -p "What are you editing:")

  case "$choice" in
    category)
      category=$(basename $category_file)
      choice=$(echo -e "name\nrunner" | rofi -dmenu -p "Edit:")

      case "$choice" in
        name)
          new_category_name=$(rofi -dmenu -p "Edit name:" -filter "$category")
          [ -z "$new_category_name" ] && exit 0
          new_category_file="$BM_DIR/$new_category_name"

          if [ -f $new_category_file ]; then
            notify-send "$new_category_file already exists"
            exit 0
          fi

          mv $category_file $new_category_file
          notify-send "Renamed category $category to $new_category_name"
        ;;
        runner)
          runner=$(head -n 1 "$category_file" | awk -F"$SEP" '{print $2}' 2>/dev/null)
          [ -z "$runner" ] && exit 0

          choice=$(rofi -dmenu -p "Edit name:" -filter "$runner")
          [ -z "$choice" ] && exit 0
          { echo "RUNNER$SEP$choice"; tail -n +2 "$category_file"; } > "$BM_DIR/temp_file" && mv "$BM_DIR/temp_file" "$category_file"
          notify-send "'$category' RUNNER set to '$choice'"
        ;;
      esac
    ;;
    bookmark)
      notify-send "TODO: bm.sh edit bookmark"
      exit 0
    ;;
  esac
}

delete(){
  category_file=$(get_category)

  choice=$(echo -e "category\nbookmark" | rofi -dmenu -p "What are you deleting")

  case "$choice" in
    category)
      choice=$(echo -e "yes\nno" | rofi -dmenu -p "Are you sure you want to delete category '$(basename $category_file)'")
      [ -z "$choice" ] && exit 0

      [ $choice == "yes" ] && rm -rf $category_file && notify-send "Deleted category $choice"
    ;;
    bookmark)
      bookmark=$(tail -n +2 "$category_file" | awk -F"$SEP" '{print $1}' | rofi -dmenu -p "Bookmark:" 2>/dev/null)
      [ -z "$bookmark" ] && exit 0

      line_no=$(tail -n +2 "$category_file"| grep -n "$bookmark$SEP" | grep -Po "^\d+" )


      choice=$(echo -e "yes\nno" | rofi -dmenu -p "Are you sure you want to delete bookmark '$bookmark'")
      [ -z "$choice" ] && exit 0

      [ $choice == "yes" ] && sed -i ""$line_no"d" $category_file && notify-send "Deleted bookmark $choice"
    ;;
  esac
}

if [ -n "$1" ]; then
  case "$1" in
    pick) pick ;;
    add) add ;;
    edit) edit ;;
    delete) delete ;;
    *) exit 1;;
  esac
else
  choices="pick\nadd\nedit\ndelete"

  choice=$(echo -en $choices | rofi -dmenu -p "Bookmark Menu:")

  [ -z "$choice" ] && exit 0

  case "$choice" in
    pick) pick ;;
    add) add ;;
    edit) edit ;;
    delete) delete ;;
    *) exit 1 ;;
  esac
fi
exit 0
