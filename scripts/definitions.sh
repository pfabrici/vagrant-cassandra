CASSANDRA_VERSION="3.9"
CASSANDRA_NAME="apache-cassandra-${CASSANDRA_VERSION}-bin"
CASSANDRA_SRCURL="http://ftp.fau.de/apache/cassandra/${CASSANDRA_VERSION}/${CASSANDRA_NAME}.tar.gz"
CASSANDRA_HOME=/opt/cassandra
CASSANDRA_PWD=cassandra

JDK_VERSION="jdk-8u73-linux-x64"
JDK_RPM="$JDK_VERSION.rpm"
JDK_SRCURL="http://download.oracle.com/otn-pub/java/jdk/8u73-b02/${JDK_RPM}"

SETUP_LOG=/vagrant/setup.log
SETUP_PKGS=/vagrant/pkg
SETUP_SCRIPTS=/vagrant/scripts
