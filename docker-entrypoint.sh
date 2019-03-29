#!/bin/bash

if [ -z "$APPLICATION_ENV" ]; then
    export APPLICATION_ENV=production
fi
echo "APPLICATION_ENV=$APPLICATION_ENV"

function main {
    _wait_for_redis

    case "$1" in
        application)
            echo "Starting application server..."
            exec puma -I. -C config/puma.rb
            ;;
        worker)
            echo "Starting Resque worker..."
            echo "Listening to queues: '$QUEUE'"
            echo "Polling interval: $INTERVAL"
            exec rake resque:work
            ;;
        scheduler)
            echo "Starting Resque scheduler..."
            echo "Scheduling interval: $RESQUE_SCHEDULER_INTERVAL"
            exec rake resque:scheduler
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
            echo "Valid commands: application, worker, scheduler, rake, shell"
            exit 1
    esac
}

function _wait_for_redis {
    echo "Waiting for Redis: $REDIS_HOST:$REDIS_PORT"
    ./wait-for-it.sh $REDIS_HOST:$REDIS_PORT --timeout=20
    if [ $? -eq 0 ]; then
        echo "Redis ready"
    else
        echo "Redis not ready in time"
        exit 1
    fi
}

main $@
