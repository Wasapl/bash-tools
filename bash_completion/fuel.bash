_fuel61_file()
{
    COMPREPLY=( ${COMPREPLY[@]:-} $( compgen -f -- "$cur" ) )
    echo $( compgen -d -- "$cur" ) | while read d ; do 
    COMPREPLY=( ${COMPREPLY[@]:-} "$d/" )
    done
}

_fuel61_help()
{
    awk='/^ +-/{
        for(i=1; i<=NF; i++)
            if(substr($i,1,1)=="-")
                {print $i} 
        }'
    eval "$1='$( fuel $2 --help 2>/dev/null|awk -F '[ \t,]+' "$awk" )'"
}


_fuel61_get_first_column()
{
    eval "$1='$(fuel $2 --list 2>/dev/null|awk -F ' *[|] *' 'NR>2{print $1}')'"
}
_fuel61_get_third_column()
{
    eval "$1='$(fuel $2 --list 2>/dev/null|awk -F ' *[|] *' 'NR>2{print $3}')'"
}

_fuel61_plugins()
{
    eval "$1='$(fuel plugins --list 2>/dev/null|gawk -F "[ | ]+" 'NR>2{;print $2 "==" $3}')'"
}
_fuel61_envs()
{
    _fuel61_get_third_column $1 "env"
}
_fuel61_envids()
{
    _fuel61_get_first_column $1 "env"
}
_fuel61_releases()
{
    _fuel61_get_first_column $1 "release"
}
_fuel61_tasks()
{
    _fuel61_get_third_column $1 "task"
}
_fuel61_roles()
{
    #frankly we shoud concatenate roles from both releases
    local r1 r2
    _fuel61_get_first_column r1 "role --release 1"
    _fuel61_get_first_column r2 "role --release 2"
    eval "$1=\"$r1 $r2\""
}
_fuel61_nodes()
{
    local env
    if [[ -z $2 ]]; then
        env=""
    else
        env="--env $2"
    fi
    _fuel61_get_first_column $1 "node $env"
}
_fuel61_nodes_macs()
{
    local env
    if [[ -z $2 ]]; then
        env=""
    else
        env="--env $2"
    fi
    eval "$1='$(fuel node --list $env 2>/dev/null|awk -F ' *[|] *' 'NR>2{print substr($6,13)}')'"
}

_fuel61_completion()
{
    local ns nss opts cur ind nsopts words words1 words2
    _fuel61_help opts
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
            case $prev in
                --node|--node-id)
                    _fuel61_nodes words1
                    _fuel61_nodes_macs words2
                    words="$words1 $words2"
                    ;;
                --role|-r)
                    _fuel61_roles words
                    ;;
                --env)
                    _fuel61_envs words
                    ;;
                --skip|--tasks|--end|--start)
                    _fuel61_tasks words
                    ;;
                *)
                    _fuel61_help words $ns
                    ;;
            esac
            ;;
        env|environment)
            case $prev in
                 --mode|-m|--deployment-mode)
                    words="multinode ha"
                    ;;
                --env|--env-id)
                    _fuel61_envids words
                    ;;
                *)
                    _fuel61_help words $ns
                    ;;
            esac
            ;;
        role)
            case $prev in
                --role)
                    _fuel61_roles words
                    ;;
                --release|--rel)
                    _fuel61_releases words
                    ;;
                --file)
                    _fuel61_file
                    return 0
                    ;;
                *)
                    _fuel61_help words $ns
                    ;;
            esac
            ;;
        plugins)
            case $prev in
                --remove|--register|--unregister)
                    _fuel61_plugins words
                    ;;
                --install|--upgrade|--downgrade)
                    _fuel61_file
                    return 0
                    ;;
                *)
                    _fuel61_help words $ns
                    ;;
            esac
            ;;
        stop|reset|net|network|snapshot)
            case $prev in
                --env|--env-id)
                    _fuel61_envs words
                    ;;
                *)
                    _fuel61_help words $ns
                    ;;
            esac
            ;;
        nodegroup)
            case $prev in
                --node|--node-id)
                    _fuel61_nodes words1
                    _fuel61_nodes_macs words2
                    words="$words1 $words2"
                    ;;
                --env|--env-id)
                    _fuel61_envs words
                    ;;
                *)
                    _fuel61_help words $ns
                    ;;
            esac
            ;;
        task)
            case $prev in
                --task|--task-id|--tid)
                    _fuel61_tasks words
                    ;;
                *)
                    _fuel61_help words $ns
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