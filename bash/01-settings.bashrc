#!/bin/bash

# ================================
# General settings
# ================================

shopt -s no_empty_cmd_completion

# Remove duplicates from history
HISTCONTROL=ignoreboth

# Size of history
HISTFILESIZE=3000

# Protection from Ctrl-D (exits from Bash)
IGNOREEOF=1

# Default language
export LC_ALL="en_US.UTF-8"

# Enhance PATH to make sure that /usr/local/bin is used before /usr/bin
export PATH=/usr/local/bin:$PATH


# ================================
# General aliases
# ================================
alias ll="ls -al"
alias grep='grep --colour=auto'
alias h="history"

# ================================
# Git repositories location
# ================================
export REPOS=$HOME/Repos
alias cdrep="cd $REPOS"
alias cddot="cd $REPOS/dotfiles"

# ================================
# Third-party software location
# ================================
export SOFTWARE_FOLDER=$HOME/Software
alias cdsoft="cd $SOFTWARE_FOLDER"

# ================================
# Environment variables
# ================================
# Java
export JAVA_TOOL_OPTIONS='-Djava.awt.headless=true'

# Maven
export M2_HOME=$SOFTWARE_FOLDER/Maven/current
export MAVEN_OPTS="-Xmx1024M -XX:MaxPermSize=256M -server"
export MAVEN_LOCAL_REPOSITORY=$HOME/.m2/repository
export MAVEN_HOME=M2_HOME
export PATH=$M2_HOME/bin:$PATH

# Groovy
export GROOVY_HOME=$SOFTWARE_FOLDER/Groovy/current
# Ant
export ANT_HOME=$SOFTWARE_FOLDER/Ant/current
# Gradle
export GRADLE_HOME=$SOFTWARE_FOLDER/Gradle/current
export GRADLE_OPTS="-Xmx1024M -XX:MaxPermSize=256M"
# Add all the tools to the PATH
export PATH=$GROOVY_HOME/bin:$ANT_HOME/bin:$GRADLE_HOME/bin:$PATH
