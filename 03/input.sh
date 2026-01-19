#!/bin/bash

parameter=$1

# Проверка на количество параметров
if [ $# -ne 1 ]; then
    echo "Error: invalid quantity of parameters (should be 1, you have $#)"
    exit 2
fi

# Проверка на значения параметра
if ! [[ ${#parameter} = 1 && "$parameter" =~ [1-3] ]]; then
    echo "Error: invalid value of parameter, parameter should be between 1 and 3."
    exit 2
fi