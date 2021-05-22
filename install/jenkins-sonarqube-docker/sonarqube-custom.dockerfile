FROM sonarqube:latest
COPY plugin/sonar-pmd-plugin-3.2.0-SNAPSHOT.jar /opt/sonarqube/extensions/plugins/sonar-pmd-plugin-3.2.0-SNAPSHOT.jar
COPY plugin/sonar-l10n-zh-plugin-1.16.jar /opt/sonarqube/extensions/plugins/sonar-l10n-zh-plugin-1.16.jar
