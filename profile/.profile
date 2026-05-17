. "$HOME/.cargo/env"

alias g=git
alias vim=nvim
alias mux=tmuxinator

export EDITOR=nvim

export GO_HOME="/usr/bin/local/go"
PATH=$PATH:$GO_HOME/bin

export JAVA_8="/opt/jdk1.8.0_202"
export JAVA_19="/opt/jdk-19.0.2"
export JAVA_21="/opt/jdk-21.0.6"
export JAVA_24="/opt/jdk-24"
export JAVA_25="/opt/jdk-25"

export JAVA_HOME=$JAVA_25
PATH=$PATH:$JAVA_HOME/bin

export GRAALVM_HOME="/opt/graalvm-jdk-25.0.1+8.1"

export M2_HOME="/opt/apache-maven-3.9.9"
PATH=$PATH:$M2_HOME/bin

export DOTNET_ROOT="$HOME/dotnet"
PATH=$PATH:$DOTNET_ROOT

PATH=$PATH:/var/www/html/magento2/bin

export PATH

export ANTLR_HOME="/home/ahmed-mehanna/git/oracle-grammar"
export CLASSPATH=".:$ANTLR_HOME/antlr-4.13.1-complete.jar:$CLASSPATH"

alias antlr4='java -jar $ANTLR_HOME/antlr-4.13.1-complete.jar'
alias grun='java org.antlr.v4.gui.TestRig'

alias idea=/opt/idea-IU-243.26053.27/bin/idea

export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init - bash)"

export DOCKER_HOST=unix:///var/run/docker.sock

export NOTES=$HOME
#export XDG_CONFIG_HOME=$HOME

source ~/.private-profile
