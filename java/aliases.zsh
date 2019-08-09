export JAVA_HOME_8=$(/usr/libexec/java_home -v '1.8*')
export JAVA_HOME_11=$(/usr/libexec/java_home -v '11*')

alias java8='export JAVA_HOME=$JAVA_HOME_8'
alias java11='export JAVA_HOME=$JAVA_HOME_11'
