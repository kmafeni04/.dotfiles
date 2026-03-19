#!/usr/bin/env bash

light | awk -F. '{print $1"%"}'
