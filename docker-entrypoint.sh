#!/bin/bash

if [ -z "$APPLICATION_ENV" ]; then
    export APPLICATION_ENV=production
fi
echo "APPLICATION_ENV=$APPLICATION_ENV"

function main {
    case "$1" in
        application)
            echo "Starting application server..."
            exec puma -I. -C config/puma.rb
            ;;
        rake)
            echo "Calling Rake task $2"
            exec rake $2
            ;;
        shell)
            echo "Opening shell"
            exec rake emerald:console
            ;;
        *)
            echo "Don't know what to do with $1"
            echo "Valid commands: application, rake, shell"
            exit 1
    esac
}

main $@
