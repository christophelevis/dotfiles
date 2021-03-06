

# Add bin folder to PATH
export PATH=$DOTFILES/sonarqube/bin:$PATH

# ================================
# Settings specific to test snapshot version of SonarQube
# ================================
export SONAR_CURRENT=$SOFTWARE_FOLDER/SonarQube/current
export SONAR_NEXT_FILES=$SOFTWARE_FOLDER/SonarQube/SNAPSHOT
export SONAR_NEXT=$SOFTWARE_FOLDER/SonarQube/sonarqube-next
export PLUGINS_DEV=$SONAR_CURRENT/extensions/plugins
alias cdcurr="cd $SONAR_CURRENT"
alias cdnext="cd $SONAR_NEXT"

export SONAR_SCANNER_CURRENT=$SOFTWARE_FOLDER/SonarScanner/current
export SONAR_SCANNER_NEXT_FILES=$SOFTWARE_FOLDER/SonarScanner/SNAPSHOT
export SONAR_SCANNER_NEXT=$SOFTWARE_FOLDER/SonarScanner/sonar-scanner-next
alias cdscan="cd $SONAR_SCANNER_CURRENT"

export SONAR_LINT_CURRENT=$SOFTWARE_FOLDER/SonarLint/current
export SONAR_LINT_NEXT_FILES=$SOFTWARE_FOLDER/SonarLint/SNAPSHOT
export SONAR_LINT_NEXT=$SOFTWARE_FOLDER/SonarLint/sonar-lint-next
export SONAR_LINT_CURRENT=$SOFTWARE_FOLDER/SonarLint/current
alias cdlint="cd $SONAR_LINT_CURRENT"

export PATH=$SONAR_LINT_CURRENT/bin:$SONAR_SCANNER_CURRENT/bin:$PATH

# ================================
# Completion of sonarqube/bin commands
# ================================
# Find installed versions of sonarqube
_find_installed_versions_()
{
    for dir in ~/Software/SonarQube/*
    do
	if [ -d "$dir" ]
        then
	    case $dir in
                *sonarqube-next)
                    echo "snapshot"
                    ;;
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

# Find archives of sonarqube
_find_archived_versions_()
{
    for file in ~/Software/SonarQube/ARCHIVES/*
    do
	if [ -f "$file" ]
        then
	    case $file in
                *sonar*-*.zip)
                    echo "$file" | sed 's/.*sonar[^-]*-//' | sed 's/.*application[^-]*-//' | sed 's/\.zip//'
                    ;;
            esac
        fi
    done
    echo "latest"
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

# Find installed versions of scanner
_find_installed_scanner_versions_()
{
    for dir in ~/Software/SonarScanner/*
    do
	if [ -d "$dir" ]
        then
	    case $dir in
                *sonar-scanner-next)
                    echo "snapshot"
                    ;;
                *sonar-scanner*-*)
                    echo "$dir" | sed 's/.*sonar-scanner[^-]*-//'
                    ;;
            esac
        fi
    done
}
_find_install_scanner_()
{
    local cur prev

    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"

    COMPREPLY=( $(compgen -W "$(_find_installed_scanner_versions_)" -- $cur) )
    return 0
}
complete -F _find_install_scanner_ s-switchScanner.sh

# Find archives of scanner
_find_archived_scanner_versions_()
{
    for file in ~/Software/SonarScanner/ARCHIVES/*
    do
	if [ -f "$file" ]
        then
	    case $file in
                *sonar-scanner*-*.zip)
                    echo "$file" | sed 's/.*sonar-scanner[^-]*-//' | sed 's/.*cli[^-]*-//' | sed 's/\.zip//'
                    ;;
            esac
        fi
    done
}
_find_archive_scanner_()
{
    local cur prev

    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"

    COMPREPLY=( $(compgen -W "$(_find_archived_scanner_versions_)" -- $cur) )
    return 0
}
complete -F _find_archive_scanner_ s-installScanner.sh

# Find repos of plugins
_find_plugins_repos_()
{
    for dir in ~/Repos/*
    do
	if [ -d "$dir" ]
        then
	    case $dir in
                *sonar-*)
                    echo "$dir" | sed 's/.*sonar[^-]*-//'
                    ;;
            esac
        fi
    done
}
_find_plugins_()
{
    local cur prev

    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"

    COMPREPLY=( $(compgen -W "$(_find_plugins_repos_)" -- $cur) )
    return 0
}
complete -F _find_plugins_ s-installSnapshotOfPlugin.sh
complete -F _find_plugins_ s-installSnapshot.sh

# Find archives of plugin
_find_archived_plugin_versions_()
{
    for file in ~/Software/SonarQube/ARCHIVES/*
    do
	if [ -f "$file" ]
        then
	    case $file in
                *sonar-*-plugin-*.jar)
                    echo "$file" | sed 's/.*sonar[^-]*-//' | sed 's/-plugin//' | sed 's/\.jar//'
                    ;;
                *-extension-plugin-*.jar)
                    echo "$file" | sed 's/.*\///' | sed 's/extension-plugin-//' | sed 's/\.jar//'
                    ;;
            esac
        fi
    done
}
_find_archive_plugin_()
{
    local cur prev

    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"

    COMPREPLY=( $(compgen -W "$(_find_archived_plugin_versions_)" -- $cur) )
    return 0
}
complete -F _find_archive_plugin_ s-installPlugin.sh

# Find installed versions of lint
_find_installed_lint_versions_()
{
    for dir in ~/Software/SonarLint/*
    do
	if [ -d "$dir" ]
        then
	    case $dir in
                *sonarlint-cli-next)
                    echo "snapshot"
                    ;;
                *sonarlint-cli*-*)
                    echo "$dir" | sed 's/.*sonarlint-cli-//'
                    ;;
            esac
        fi
    done
}
_find_install_lint_()
{
    local cur prev

    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"

    COMPREPLY=( $(compgen -W "$(_find_installed_lint_versions_)" -- $cur) )
    return 0
}
complete -F _find_install_lint_ s-switchLint.sh

