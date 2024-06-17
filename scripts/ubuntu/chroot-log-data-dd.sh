#!/bin/bash

# ANSI color codes
BLACK='\033[0;30m'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[0;37m'

# Bold ANSI color codes
BOLD_BLACK='\033[1;30m'
BOLD_RED='\033[1;31m'
BOLD_GREEN='\033[1;32m'
BOLD_YELLOW='\033[1;33m'
BOLD_BLUE='\033[1;34m'
BOLD_MAGENTA='\033[1;35m'
BOLD_CYAN='\033[1;36m'
BOLD_WHITE='\033[1;37m'

# Background ANSI color codes
BG_BLACK='\033[40m'
BG_RED='\033[41m'
BG_GREEN='\033[42m'
BG_YELLOW='\033[43m'
BG_BLUE='\033[44m'
BG_MAGENTA='\033[45m'
BG_CYAN='\033[46m'
BG_WHITE='\033[47m'

# Reset ANSI color code
NC='\033[0m' # No Color

# Define a log file
LOG_FILE="/mnt/system/mount_script.log"

# Decorative divider
divider() {
    echo -e "${BOLD_CYAN}————————————————————————————————————————————————————————————————————————————————${NC}"
}
# Yellow Decorative divider
yellow_divider() {
    echo -e "${BOLD_YELLOW}————————————————————————————————————————————————————————————————————————————————${NC}"
}
# Magenta Decorative divider
magenta_divider() {
    echo -e "${BOLD_MAGENTA}————————————————————————————————————————————————————————————————————————————————${NC}"
}


# Function to add log entries with color
log() {
    local message="$1"
    local color="$2"
    echo -e "${YELLOW}$(date '+%b/%d/%Y') — ${BOLD_BLUE}$(date '+%-l:%M %p'):${NC} ${color}${message}${NC}" | tee -a "$LOG_FILE"
}

# Function to get and display the product model
get_product_model() {
    local model
    model=$(getprop ro.product.model)
    log "Device: $model" "$BOLD_GREEN"

    local processor
    processor=$(cat /proc/cpuinfo | grep 'Processor' | cut -d ':' -f 2 | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
    log "Processor: $processor" "$BOLD_GREEN"
}

# Function to get and display the number of processor cores using adb
get_processor_cores() {
    local num_cores
    num_cores=$(cat /proc/cpuinfo | grep 'processor' | wc -l)
    log "Cores: ${num_cores} Cores" "$BOLD_GREEN"
}

# Function to get and display memory information in GB
get_memory_info() {
    local total_mem_kb
    total_mem_kb=$(cat /proc/meminfo | grep 'MemTotal' | awk '{print $2}')
    total_mem_gb=$(echo "scale=2; $total_mem_kb / 1024 / 1024" | bc)
    log "Total Memory: ${total_mem_gb} GB" "$BOLD_GREEN"
}


# Start the script 
log "Executing Chroot Environment Scripts..." "$BOLD_MAGENTA"
divider
log "Getting Device Info..." "$BOLD_MAGENTA"
get_product_model
get_processor_cores
get_memory_info
divider

# Mount the filesystem
mkdir -p /data && log "✔️ Created /data directory." "$GREEN" || log "❌ Failed to create /data directory." "$RED"
log "Mounting the Data Partition..." "$BOLD_MAGENTA"
if mount -t /dev/block/by-name/userdata /data; then
    log "✔️ Mounted /dev/block/by-name/userdata to /data." "$GREEN"

    # Update /etc/fstab
    FSTAB_LINE="/dev/block/by-name/userdata /data ext4 rw 0 0"
    if grep -Fxq "$FSTAB_LINE" /etc/fstab; then
        log "✔️ Line already exists in /etc/fstab." "$GREEN"
    else
        echo "$FSTAB_LINE" | tee -a /etc/fstab > /dev/null
        if grep -Fxq "$FSTAB_LINE" /etc/fstab; then
            log "✔️ Line successfully added to /etc/fstab." "$GREEN"
        else
            log "❌ Failed to add line to /etc/fstab. Check permissions and path." "$RED"
        fi
    fi

else
    log "❌ Failed to mount /dev/block/by-name/userdata to /data." "$RED"
    exit 1
fi

divider

# Create a custom /etc/group file in the chroot environment
log "Creating custom /etc/group file in the chroot environment..." "$BOLD_MAGENTA"
group_ids=(1007 1011 1028 1078 1079 3001 3006 3009 3011 0 1004 1015 3002 3003)
for i in {0..13}; do
    echo "group$(($i + 1)):x:${group_ids[$i]}:" >> /data/etc/group
done
log "✔️ Custom /etc/group file created." "$GREEN"

divider

# Set the PATH environment variable
export PATH=/bin:/usr/bin:/sbin:/usr/sbin:/usr/local/bin
log "Setting PATH environment variables..." "$BOLD_MAGENTA"

# Bind mount important directories
if mount --bind /dev /data/dev && 
   mount --bind /dev/pts /data/dev/pts && 
   mount --bind /sys /data/sys && 
   mount --bind /proc /data/proc; then
    log "✔️ Bind mounted important directories." "$GREEN"
else
    log "❌ Failed to bind mount important directories." "$RED"
    exit 1
fi

divider

# Enter the chroot environment
log "Entering chroot environment..." "$YELLOW"

chroot /data /bin/bash

log "Exiting chroot environment..." "$YELLOW"

divider

# The following will execute after you exit the chroot environment

# Check disk usage and report if it's over a certain threshold
storage_usage=$(df -h | grep '/data' | awk '{print $5}')

# Log storage use percentage
log "${YELLOW}Storage usage on /data: ${MAGENTA}$storage_usage${RESET}"

# Warning for reaching 85% storage usage.
df -h | grep '/data' | awk '{print $5}' | while read -r usage; do
    if [ "${usage%*%}" -gt 85 ]; then
        log "❌ Warning: Disk usage is over 85% on /data" "$RED"
    fi
done

divider

# Log users in home directory
if [ -d "/data/home" ]; then
    log "Users in /data/home:" ${YELLOW}
    for user_home in /data/home/*; do
        if [ -d "$user_home" ]; then
            user=$(basename "$user_home")
            log "✔️ - $user" "$GREEN"
        fi
    done
else
    log "Home directory /data/home not found." "$RED"
fi

divider

# Check for specific files and take action
if [ -f /data/bin/sh ]; then
    log "✔️ Found bin/sh." "$GREEN"
else
    log "bin/sh not found. ERROR!" "$RED"
fi

divider

# Remove the custom /etc/group file
rm -f /data/etc/group && log "✔️ Custom /etc/group file deleted." "$GREEN"

# Cleanup: unmount bound directories
if umount -l /data/dev/pts && 
   umount -l /data/dev && 
   umount -l /data/sys && 
   umount -l /data/proc && 
   umount -l /data; then
    log "Unmounted all directories." "$BOLD_MAGENTA"
else
    log "❌ Failed to unmount some directories." "$RED"
fi

divider
log "✔️ Chroot Environment Exited Successfully." "$BOLD_MAGENTA"
yellow_divider
log "${MAGENTA}Good-bye. ${RESET}👋"
