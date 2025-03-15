#
# NOTE: THIS DOCKERFILE IS GENERATED VIA "apply-templates.sh"
#
# PLEASE DO NOT EDIT IT DIRECTLY.
#

FROM mcr.microsoft.com/windows/nanoserver:ltsc2022
ENV PATH "c:\\Windows\\System32;c:\\Windows;C:\\Windows\\System32\\WindowsPowerShell\\v1.0"

SHELL ["cmd", "/s", "/c"]

ENV JAVA_HOME C:\\openjdk-25

ENV PATH "$JAVA_HOME\bin;$PATH"

# "ERROR: Access to the registry path is denied."
USER ContainerAdministrator
RUN echo Updating PATH: %JAVA_HOME%\bin;%PATH% \
	&& setx /M PATH %JAVA_HOME%\bin;%PATH% \
	&& echo Complete.
USER ContainerUser

# https://jdk.java.net/
# >
# > Java Development Kit builds, from Oracle
# >
ENV JAVA_VERSION 25-ea+13

COPY --from=openjdk:25-ea-13-jdk-windowsservercore-ltsc2022 $JAVA_HOME $JAVA_HOME

# "jshell" is an interactive REPL for Java (see https://en.wikipedia.org/wiki/JShell)
CMD ["jshell"]