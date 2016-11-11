#!/bin/sh

set -e

if [ "${1:0:1}" != '-' ]; then
	exec "$@"
fi


exec java -jar lib/sonar-application-$SONAR_VERSION.jar \
	-Dsonar.log.console=true \
	-Dsonar.jdbc.username="$SONARQUBE_JDBC_USERNAME" \
	-Dsonar.jdbc.password="$SONARQUBE_JDBC_PASSWORD" \
	-Dsonar.jdbc.url="$SONARQUBE_JDBC_URL" \
	-Dsonar.web.javaAdditionalOpts="$SONARQUBE_WEB_JVM_OPTS -Djava.security.egd=file:/dev/./urandom" \
	"$@" > /dev/null & 

printf "Starting SonarQube Server\n"

retry=0

until [ $(curl --output /dev/null --silent --head --fail http://localhost:9000) ] || [ $retry -ge 15 ]; do
	retry=$((retry + 1))
	printf '.'
	sleep 1 
done

printf "\nRunning Sonar Scanner\n"

sonar-scanner -Dsonar.projectBaseDir=/src

