launchctl setenv JAVA_HOME $(/usr/libexec/java_home -v '11*')
export JAVA_HOME=$(/usr/libexec/java_home -v '11*')
export PATH="$JAVA_HOME/bin:$PATH"
