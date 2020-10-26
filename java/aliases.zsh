export JAVA_HOME_8=$(/usr/libexec/java_home -v '1.8*')
export JAVA_HOME_11=$(/usr/libexec/java_home -v '11*')
export JAVA_HOME_14=$(/usr/libexec/java_home -v '14*')

alias java8='export JAVA_HOME=$JAVA_HOME_8; launchctl setenv JAVA_HOME $JAVA_HOME_8; export PATH="$JAVA_HOME/bin:$PATH"; java -version'
alias java11='export JAVA_HOME=$JAVA_HOME_11; launchctl setenv JAVA_HOME $JAVA_HOME_11; export PATH="$JAVA_HOME/bin:$PATH"; java -version'
alias java14='export JAVA_HOME=$JAVA_HOME_14; launchctl setenv JAVA_HOME $JAVA_HOME_14; export PATH="$JAVA_HOME/bin:$PATH"; java -version'
