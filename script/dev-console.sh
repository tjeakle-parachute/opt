aws-vault clear
cd ~/Documents/code/infrastructure
aws-vault exec nonprod
./scripts/console -e master
