# Make User
adduser bdt
# Grant Root Privileges
gpasswd -a bdt sudo

# Apt-get Update
sudo apt-get update
# Install Lib For Add Apt
sudo apt-get install software-properties-common

# Add Repository Java
sudo add-apt-repository ppa:webupd8team/java
# Apt-get Update for Repository Java
sudo apt-get update
# Install Java
sudo apt-get install oracle-java8-set-default
# Cassandra Package
echo "deb http://www.apache.org/dist/cassandra/debian 39x main" | sudo tee -a /etc/apt/sources.list.d/cassandra.sources.list
# Source Cassandra Package
echo "deb-src http://www.apache.org/dist/cassandra/debian 39x main" | sudo tee -a /etc/apt/sources.list.d/cassandra.sources.list
# First Key
gpg --keyserver pgp.mit.edu --recv-keys F758CE318D77295D
gpg --export --armor F758CE318D77295D | sudo apt-key add -
# Second Key
gpg --keyserver pgp.mit.edu --recv-keys 2B5C1B00
gpg --export --armor 2B5C1B00 | sudo apt-key add -
# Third Key
gpg --keyserver pgp.mit.edu --recv-keys 0353B12C
gpg --export --armor 0353B12C | sudo apt-key add -
# Apt-get Update for Key
sudo apt-get update

# Install Cassandra
sudo apt-get install cassandra
# Check Status Cassandra
sudo service cassandra status

# Check Node Status
sudo nodetool status