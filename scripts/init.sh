#!/bin/bash

ECODE=0
while true ; do

  # Execute and load the variable definition file
  #
  echo "Load definitions"
  . /vagrant/scripts/definitions.sh
  [ $? -ne 0 ] && { ECODE=10; break; }

  # check whether the installation is flagged ready or not
  #
  [ -f ~/install.status ] && { echo "Already installed"; break; }

  # create a download folder if it is not alread there
  #
  echo "Create download dir"
  [ ! -d ${SETUP_PKGS} ] && { mkdir -p ${SETUP_PKGS};  [ $? -ne 0 ] && { ECODE=14; break; } }

  # install missing system packages
  #
  echo "Installing system packages"
  yum -y install wget net-tools
  [ $? -ne 0 ] && { ECODE=12; break; }

  # assign setup scripts the execute rights
  #
  echo "chmod some scripts"
  chmod u+x ${SETUP_SCRIPTS}/*.sh
  [ $? -ne 0 ] && { ECODE=9; break; }

  # download a JDK if necessary
  #
  if [ ! -f ${SETUP_PKGS}/${JDK_RPM} ]; then
      echo "Downloading JDK"

      wget -O ${SETUP_PKGS}/${JDK_RPM} --no-check-certificate --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie" "${JDK_SRCURL}" -o ~/java_wget.log
      [ $? -ne 0 ] && { ECODE=20; break; }
      cat ~/java_wget.log && rm ~/java_wget.log
  else
      echo "Skip downloading JDK"
  fi

  # install the JDK
  #
  echo "Install JDK"
  rpm -ivh ${SETUP_PKGS}/${JDK_RPM}
  [ $? -ne 0 ] && { ECODE=22; break; }


  # download cassandra if not already there
  #
  if [ ! -f  ${SETUP_PKGS}/${CASSANDRA_NAME}.tar.gz ]; then
    echo "Downloading kafka...$CASSANDRA_VERSION"

    echo "wget -O ${SETUP_PKGS}/${CASSANDRA_NAME}.tar.gz ${CASSANDRA_SRCURL} -o ~/cassandra_wget.log"
    wget -O "${SETUP_PKGS}/${CASSANDRA_NAME}.tar.gz" ${CASSANDRA_SRCURL} -o ~/cassandra_wget.log
    [ $? -ne 0 ] && { ECODE=16; break; }

    cat ~/cassandra_wget.log && rm ~/cassandra_wget.log
  else
    echo "Skip downloading cassandra...${CASSANDRA_VERSION}"
  fi

  #
  # Install cassandra software
  #
  echo "Prepare cassandra user, folders & software"
  groupadd cassandra && useradd -d ${CASSANDRA_HOME} -m -g cassandra cassandra && echo ${CASSANDRA_PWD}  | passwd --stdin cassandra
  [ $? -ne 0 ] && { ECODE=30; break; }

  tar xvfz ${SETUP_PKGS}/${CASSANDRA_NAME}.tar.gz -C ${CASSANDRA_HOME} --strip-components=1
  [ $? -ne 0 ] && { ECODE=32; break; }

  mkdir -p /var/lib/cassandra/data /var/lib/cassandra/commitlog /var/lib/cassandra/saved_caches
  chown cassandra:cassandra -R /var/lib/cassandra

  chown cassandra:cassandra -R ${CASSANDRA_HOME}
  [ $? -ne 0 ] && { ECODE=34; break; }

  cp /opt/cassandra/conf/cassandra.yaml /opt/cassandra/conf/cassandra.yaml.orig

  echo "PATH=~/bin:${PATH}; export PATH" >> ${CASSANDRA_HOME}/.bash_profile
  echo ". ${SETUP_SCRIPTS}/definitions.sh" >> ${CASSANDRA_HOME}/.bash_profile

  # mark the software to be installed
  echo "Install" > ~/install.status

  # definitly end
  #
  break
done

case ${ECODE} in
  0)  MSG="ok" ;;
  8)  MSG="Error: shutdown IPTables failed" ;;
  9)  MSG="Error: chmod scripts failed" ;;
  10) MSG="Error: loading definitions failed" ;;
  12) MSG="Error: installation of system packages failed" ;;
  14) MSG="Error: mkdir download folder failed" ;;
  16) MSG="Error: wget cassandra failed" ;;
  20) MSG="Error: wget JDK failed" ;;
  22) MSG="Error: JDK install failed" ;;
  30) MSG="Error: creation of cassandra user failed" ;;
  32) MSG="Error: untar cassandra software failed" ;;
  34) MSG="Error: chown cassandra software failed" ;;
  *)  MSG="Error: unknown reason" ;;
esac

echo ${MSG}
exit ${ECODE}
