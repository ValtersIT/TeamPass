#!/bin/bash

# This file contains commands what happens when the Docker Container Starts
# I have added comments to each function so that it is understandable for people who are learning to create Docker images.
# This Docker container with all startups is written after being sick for 5 Months and not being active in >
# < IT at all in part of recovering from illness, so it is more like training to get my brain back on track for new even >
# < more difficult challenges

# YouTube: https://www.youtube.com/@valters_eu
# Twitter: https://twitter.com/valters_eu
# Website: https://www.valters.eu
    
    # Start Apache2 web server
    service apache2 start

# Check if settings.php exists and if it doesn't start cloning the latest TeamPass version from GitHub's official repository
if [ ! -f /var/www/html/includes/config/settings.php ]; then

    # Clone the GIT repository to retrieve the latest files with a fresh installation
    git config --global core.compression 0
    
    git clone --depth 1 https://github.com/nilsteampassnet/TeamPass.git /tmp/teampass

    # Copy TeamPass GIT Cloned files from the Temporary directory to the apache2 default web directory
    cp -r /tmp/teampass/* /var/www/html/

    # Clean up and remove the apache2 default index.html file and remove TeamPass download files in the Temporary directory
    rm -rf /tmp/teampass/
    rm -rf /var/www/html/index.html
    rm -rf /var/www/html/*grep*
    rm -rf /var/www/html/teampass-docker-start.sh

    # Create an empty directory that is not accessible by a web browser where to store the TeamPass encryption key
    mkdir /var/www/pw

    # Get Apache user and group
    APACHE_USER=$(grep -oP '^export APACHE_RUN_USER=\K.*' /etc/apache2/envvars)
    APACHE_GROUP=$(grep -oP '^export APACHE_RUN_GROUP=\K.*' /etc/apache2/envvars)

    # Apply user and group to the TeamPass files and the encryption key directory
    chown -R $APACHE_USER:$APACHE_GROUP /var/www/html
    chown -R $APACHE_USER:$APACHE_GROUP /var/www/pw
fi

    # Let's create a Cron Job so that the cron executes each 5-minute
    echo "*/5 * * * * root php /var/www/html/sources/scheduler.php >> /var/log/cron.log 2>&1" > /etc/cron.d/cron_job

    # Let's grant the cron file the proper permissions so that it can be executed
    chmod 0644 /etc/cron.d/cron_job
    
    # Let's create a cron log file so that the container can write into it and not stop executing crons and day
    touch /var/log/cron.log

    # Start Cron service
    service cron start

    # Keep the container running
    tail -f /var/log/cron.log