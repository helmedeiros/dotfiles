launchctl setenv JAVA_HOME $(/usr/libexec/java_home -v '1.8*')
export JAVA_HOME=$(/usr/libexec/java_home -v '1.8*')
export PATH="$JAVA_HOME/bin:$PATH"
