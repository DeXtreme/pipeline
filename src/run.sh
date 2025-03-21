#!/bin/bash 
trap "down" SIGINT

DIR="$(dirname "$0")"
UPDATE=${1:-60}

show_help() {
    echo "Usage: $(basename "$0") [update_interval]"
    echo
    echo "Auto-update and restart Docker Compose services"
    echo
    echo "Options:"
    echo "  update_interval    Time in seconds between updates (default:60)"
    echo
    echo "Examples:"
    echo "  $(basename "$0")        # Run with default 30 second update interval"
    echo "  $(basename "$0") 60     # Run with 60 second update interval"
    echo "  $(basename "$0") -h     # Show this help message"
}



main(){
    while getopts ":h" opt; do
        case $opt in
            h|:)
                show_help
                exit 0;;
        esac
    done
    
    if ! [[ "$UPDATE" =~ ^[0-9]+$ ]]; then
        echo "Error: Update interval must be a positive number"
        show_help
    exit 1
    fi

    echo -e "\e[1;32mStarting auto-update service with ${UPDATE}s interval\e[0m"
    
    # Change to script directory
    cd "$DIR"
    
    # Initial container start
    up
    
    # Main loop
    while true; do
        up
    done
}


up(){
    echo -e "\e[1;34mPulling latest images...\e[0m"
    docker-compose pull
    if [[ $? -eq 0 ]]; then
        echo -e "\e[1;34mRebuilding and starting containers...\e[0m"
        docker-compose up --build -d
    else
        exit 1
    fi

    echo -e "\e[1;36mWaiting ${UPDATE}s before next update check...\e[0m"
    sleep "$UPDATE"
}

down() {
    echo -e "\e[1;33mStopping containers...\e[0m"
    cd "$DIR"
    docker-compose down
    exit 0
}


main



