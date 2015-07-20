_fuel61_file()
{
    COMPREPLY=( ${COMPREPLY[@]:-} $( compgen -f -- "$cur" ) )
    echo $( compgen -d -- "$cur" ) | while read d ; do 
    COMPREPLY=( ${COMPREPLY[@]:-} "$d/" )
    done
}

_fuel61_plugins()
{
    eval "$1='$(fuel plugins --list 2>/dev/null|awk -F '|' 'NR>2{print $1}')'"
}
_fuel61_envs()
{
    eval "$1='$(fuel env --list 2>/dev/null|awk -F '|' 'NR>2{print $3}')'"
}
_fuel61_envids()
{
    eval "$1='$(fuel env --list 2>/dev/null|awk -F '|' 'NR>2{print $1}')'"
}

_fuel61_completion()
{
    local ns nss opts cur ind nsopts
    opts="-h --help -v --version --fuel-version --debug --user --password --tenant --yaml --json"
    nss="notify plugins network graph provisioning environment deploy-changes role healh nodegroup node stop notifications user deployment reset task setting token snapshot release vmware-settings"
    # Find the namespace
    for ind in $( seq 1 $(($COMP_CWORD-1)) ) ; do
        if [[ ${COMP_WORDS[ind]:0:1} != "-" ]] ; then
            ns=${COMP_WORDS[ind]}
            nsind=$(($COMP_CWORD-$ind))
            break
        fi
    done

    cur=${COMP_WORDS[COMP_CWORD]}
    prev=${COMP_WORDS[COMP_CWORD-1]}

    # if no command found when try to complete
    if [[ -z $ns ]] ; then
        if [[ ${cur:0:1} == "-" ]] ; then
            COMPREPLY=( $(compgen -W "$opts" -- $cur) )
        else
            COMPREPLY=( $(compgen -W "$nss" -- $cur) )
        fi
        return 0
    fi

    case $ns in
        node)
            ;;
        env)
            ;;
        plugins)
            case $prev in
                --remove|--register|--unregister)
                    _fuel61_plugins words
                    ;;
                *)
                    words="-h --help --list -l --install --remove --register --unregister --update --downgrade --sync --force -f"
                    ;;
            esac
            ;;
        *)
            case $prev in
                --env)
                    _fuel61_envs words
                    ;;
                *)
                    words='$opts $nss'
                    ;;
            esac
            ;;
    esac


    COMPREPLY=( $( compgen -W "$words" -- "$cur" ) )

    return 0
} &&

complete -o filenames -F _fuel61_completion fuel

# Local variables:
# mode: shell-script
# sh-basic-offset: 4
# sh-indent-comment: t
# indent-tabs-mode: nil
# End:
# ex: ts=4 sw=4 et filetype=sh

