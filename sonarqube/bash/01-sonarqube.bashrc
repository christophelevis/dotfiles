#!/bin/bash

# Add bin folder to PATH
export PATH=$DOTFILES/sonarqube/bin:$PATH

# ================================
# Settings specific to test snapshot version of SonarQube
# ================================
export SONAR_CURRENT=$SOFTWARE_FOLDER/SonarQube/current
export SONAR_NEXT_FILES=$SOFTWARE_FOLDER/SonarQube/NEXT_VERSION_FILES
export SONAR_NEXT=$SOFTWARE_FOLDER/SonarQube/sonarqube-next
export PLUGINS_DEV=$SONAR_CURRENT/extensions/plugins
alias s-next="cd $SONAR_NEXT"

export SONAR_SCANNER_CURRENT=$SOFTWARE_FOLDER/SonarScanner/current
export SONAR_SCANNER_NEXT_FILES=$SOFTWARE_FOLDER/SonarScanner/NEXT_VERSION_FILES
export SONAR_SCANNER_NEXT=$SOFTWARE_FOLDER/SonarScanner/sonar-scanner-next

export PATH=$SONAR_SCANNER_CURRENT/bin:$PATH

# ================================
# Completion of sonarqube/bin commands
# ================================
_find_installed_versions_()
{
    for dir in ~/Software/SonarQube/*
    do
	if [ -d "$dir" ]
        then
	    case $dir in
                *sonar*-*)
                    echo "$dir" | sed 's/.*sonar[^-]*-//'
                    ;;
            esac
        fi
    done
}
_find_install_()
{
    local cur prev

    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"

    COMPREPLY=( $(compgen -W "$(_find_installed_versions_)" -- $cur) )
    return 0
}
complete -F _find_install_ s-switch.sh

_find_archived_versions_()
{
    for file in ~/Software/SonarQube/*
    do
	if [ -f "$file" ]
        then
	    case $file in
                *sonar*-*.zip)
                    echo "$file" | sed 's/.*sonar[^-]*-//' | sed 's/\.zip//'
                    ;;
            esac
        fi
    done
}
_find_archive_()
{
    local cur prev

    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"

    COMPREPLY=( $(compgen -W "$(_find_archived_versions_)" -- $cur) )
    return 0
}
complete -F _find_archive_ s-install.sh
