#!/bin/bash

# ==============================
# Create pass
# ==============================

sudo mkdir -p /var/log/deployments/archive


# ==============================
# create logs
# ==============================

sudo touch /var/log/deployments/app-old-8days.log
sudo touch /var/log/deployments/app-old-10days.log
sudo touch /var/log/deployments/app-new-2days.log



echo "dummy old log 8 days" | sudo tee /var/log/deployments/app-old-8days.log > /dev/null
echo "dummy old log 10 days" | sudo tee /var/log/deployments/app-old-10days.log > /dev/null
echo "dummy new log 2 days" | sudo tee /var/log/deployments/app-new-2days.log > /dev/null


echo "old gz dummy" | gzip | sudo tee /var/log/deployments/archive/old-31days.log.gz > /dev/null
sudo touch -d "31 days ago" /var/log/deployments/archive/old-31days.log.gz

echo "new gz dummy" | gzip | sudo tee /var/log/deployments/archive/new-5days.log.gz > /dev/null
sudo touch -d "5 days ago" /var/log/deployments/archive/new-5days.log.gz