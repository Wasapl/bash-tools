# Programmed completion for bash to use virsh
# Copyright 2007 Red Hat Inc.
# David Lutterkort <dlutter redhat com>

_virsh_file()
{
    COMPREPLY=( ${COMPREPLY[@]:-} $( compgen -f -- "$cur" ) )
    echo $( compgen -d -- "$cur" ) | while read d ; do 
 	COMPREPLY=( ${COMPREPLY[@]:-} "$d/" )
    done
}

_virsh_domain()
{
    domains=$(virsh --readonly --quiet list --all | awk '{print $2}')
    COMPREPLY=( ${COMPREPLY[@]:-} $(compgen -W "$domains" -- $cur) )
}

_virsh_domain_live()
{
    domains=$(virsh --readonly --quiet list --all --state-running | awk '{print $2}')
    COMPREPLY=( ${COMPREPLY[@]:-} $(compgen -W "$domains" -- $cur) )
}

_virsh_domain_shut()
{
    domains=$(virsh --readonly --quiet list --all --state-shutoff | awk '{print $2}')
    COMPREPLY=( ${COMPREPLY[@]:-} $(compgen -W "$domains" -- $cur) )
}

_virsh_network()
{
    networks=$(virsh --readonly --quiet net-list --all | awk '{print $1}')
    COMPREPLY=( ${COMPREPLY[@]:-} $(compgen -W "$networks" -- $cur) )
}

_virsh_opts()
{
    if [[ ${cur:0:1} == "-" ]] ; then
        COMPREPLY=( ${COMPREPLY[@]:-} $( compgen -W "$*" -- $cur ) )
    fi
}

_virsh_options()
{
    echo `virsh help $1| awk '/^ *--/{print $1}'`
}

_virsh_pool()
{
    pools=$(virsh  --readonly --quiet pool-list --all | awk '{print $1}')
    COMPREPLY=( ${COMPREPLY[@]:-} $(compgen -W "$pools" -- $cur) )
}

_virsh_snapshots()
{
    local domain snapshots
    domain=$1
    snapshots=$(virsh --quiet snapshot-list $domain | awk '{print $1}')
    COMPREPLY=( ${COMPREPLY[@]:-} $(compgen -W "$snapshots" -- $cur) )
}

_virsh_ifaces()
{
    local domain ifaces
    domain=$1
    ifaces=$(virsh --quiet domiflist $domain |awk 'NR>2{print $1}')
    COMPREPLY=( ${COMPREPLY[@]:-} $(compgen -W "$ifaces" -- $cur) )
}

_virsh_domblks()
{
    local domain blk
    domain=$1
    blk=$(virsh --quiet domblklist $domain |awk 'NR>2{print $1}')
    COMPREPLY=( ${COMPREPLY[@]:-} $(compgen -W "$blk" -- $cur) )
}


_virsh_completion ()
{
    local cur prev cmd cmds ind opts cmdind comdomfile keywords connection uri

    COMPREPLY=()
    cmds=$(virsh --readonly --quiet help | sed -e '1,2d;$d;s/\s\+/ /g;s/^\s\+//' | cut -d ' ' -f 1 2>/dev/null)
    keywords=$(virsh --readonly --quiet help |egrep -o 'help keyword .[^'"'"']+'|cut -d "'" -f 2)
    opts="-c --connect -r --readonly -d --debug -h --help -q --quiet -t --timing -l --log -v --version"
    # Find the command
    for ind in $( seq 1 $(($COMP_CWORD-1)) ) ; do
        if [[ ${COMP_WORDS[ind]:0:1} != "-" ]] ; then
            cmd=${COMP_WORDS[ind]}
            cmdind=$(($COMP_CWORD-$ind))
            break
        fi
    done
    cur=${COMP_WORDS[COMP_CWORD]}
    prev=${COMP_WORDS[COMP_CWORD-1]}
    connection=""
    # search for connection string
    for ind in $( seq 1 $(($COMP_CWORD-1)) ) ; do
        if [ ${COMP_WORDS[i]} = "-c" ]; then
            uri=`echo ${COMP_LINE} | sed -e 's/^.* -c \([^ \t]*\).*$/\1/'`
            connection="-c $uri"
            break
        fi
    done

    # if no command found when try to complete
    if [[ -z $cmd ]] ; then
        if [[ ${cur:0:1} == "-" ]] ; then
            COMPREPLY=( $(compgen -W "$opts" -- $cur) )
        else
            case $prev in
                -c|--connect)
                    # Nothing to complete
                    ;;
                -d|--debug)
                    COMPREPLY=( $(compgen -W "0 1 2 3 4 5" -- $cur) )
                    ;;
                -l|--log)
                    _virsh_file
                    ;;
                *)
                    COMPREPLY=( $(compgen -W "$cmds" -- $cur) )
                    ;;
            esac
        fi
        return 0
    fi

    comdomfile=(: _virsh_domain _virsh_file)
    case $cmd in
        help)
            COMPREPLY=( $(compgen -W "$keywords $cmds" -- $cur) )
            ;;
        attach-device|detach-device)
            ${comdomfile[$cmdind]}
            ;;
        detach-disk)
            if [[ $cmdind -eq 1 ]] ; then
                _virsh_domain
            elif  [[ $cmdind -eq 2 ]] ; then
                _virsh_domblks $prev
            elif [[ $cmdind -gt 2 ]]; then
                COMPREPLY=( $(compgen -W "--persistent --config --live --current" -- $cur) )
            fi
            ;;
        attach-disk|attach-interface|detach-interface)
            ${comdomfile[$cmdind]}
            ;;
        autostart)
            _virsh_domain
            _virsh_opts --disable
            ;;
        change-media)
            if [[ $cmdind -eq 1 ]] ; then
                _virsh_domain
            elif  [[ $cmdind -eq 2 ]] ; then
                _virsh_domblks $prev
            elif [[ $cmdind -eq 3 ]]; then
                COMPREPLY=( $(compgen -W "--eject --insert --update  --config --live --current --force" -- $cur) )
                _virsh_file
            elif [[ $cmdind -gt 3 ]]; then
                COMPREPLY=( $(compgen -W "--eject --insert --update  --config --live --current --force" -- $cur) )
            fi
            ;;
        console)
            _virsh_domain_live
            ;;
        cpu-stats)
            _virsh_domain_live
            ;;
        create|define)
            _virsh_file
            ;;
        destroy)
            _virsh_domain_live
            ;;
        domblkstat|domblklist)
            if [[ $cmdind -eq 1 ]] ; then
                _virsh_domain_live
            fi
            ;;
        domid|domiflist)
            _virsh_domain
            ;;
        domifstat|domiftune|domif-getlink|domif-setlink)
            if [[ $cmdind -eq 1 ]] ; then
                _virsh_domain_live
            elif  [[ $cmdind -eq 2 ]] ; then
                _virsh_ifaces $prev
            fi
            ;;
        dominfo|domname|domuuid)
            _virsh_domain
            ;;
        dommemstat|domdisplay)
            _virsh_domain_live
            ;;
        domstate)
            _virsh_domain
            ;;
        dump)
            ${comdomfile[$cmdind]}
            ;;
        dumpxml)
            _virsh_domain
            ;;
        edit|vcpucounts)
            _virsh_domain
            ;;
        migrate)
            _virsh_domain
            _virsh_opts --live
            ;;
        list)
            COMPREPLY=( $(compgen -W "--inactive --all" -- $cur) )
            ;;
        net-autostart)
            _virsh_network
            _virsh_opts --disable
            ;;
        net-create|net-define)
            _virsh_file
            ;;
        net-destroy|net-dumpxml)
            _virsh_network
            ;;
        net-list)
            COMPREPLY=( $(compgen -W "--inactive --all" -- $cur) )
            ;;
        net-name|net-start|net-undefine|net-uuid|net-edit|net-info)
            _virsh_network
            ;;
        reboot)
            _virsh_domain_live
            ;;
        restore)
            _virsh_file
            ;;
        resume)
            _virsh_domain
            ;;
        save)
            ${comdomfile[$cmdind]}
            ;;
        schedinfo)
            _virsh_domain
            _virsh_opts --weight --cap
            ;;
        setmaxmem|setmem|setvcpus)
            if [[ $cmdind -eq 1 ]] ; then
                _virsh_domain
            fi
            ;;
        start)
            _virsh_domain_shut
            ;;
        shutdown|suspend)
            _virsh_domain_live
            ;;
        undefine)
            _virsh_domain_shut
            ;;
        ttyconsole|vcpuinfo)
            _virsh_domain_live
            ;;
        vcpupin)
            if [[ $cmdind -eq 1 ]] ; then
                _virsh_domain_live
            fi
            ;;
        vncdisplay)
            _virsh_domain_live
            ;;
        pool-create|pool-define)
            _virsh_file
            ;;
        pool-start|pool-info|pool-delete|pool-edit|pool-uuid|pool-refresh|pool-dumpxml|pool-destroy|pool-autostart)
            if [[ $cmdind -eq 1 ]] ; then
                _virsh_pool
            fi
            ;;
        snapshot-list|snapshot-current)
            _virsh_domain
            ;;
        snapshot-create)
            if [[ $cmdind -eq 1 ]] ; then
                _virsh_domain
            elif  [[ $cmdind -eq 2 ]] ; then
                _virsh_file
            fi
            ;;
        snapshot-delete|snapshot-edit|snapshot-revert|snapshot-dumpxml|snapshot-info|snapshot-parent)
            if [[ $cmdind -eq 1 ]] ; then
                _virsh_domain
            elif  [[ $cmdind -eq 2 ]] ; then
                _virsh_snapshots $prev
            fi
            ;;
        vol-list)
            if [[ $cmdind -eq 1 ]] ; then
                _virsh_pool
            fi
            ;;
        vol-create)
            if [[ $cmdind -eq 1 ]] ; then
                _virsh_pool
            elif  [[ $cmdind -eq 2 ]] ; then
                _virsh_file
            fi
            ;;
        *)
            return 0;
            ;;
    esac
    _virsh_opts $(_virsh_options $cmd )
    return 0
}

[ ${BASH_VERSINFO[0]} '>' 2 -o \
    ${BASH_VERSINFO[0]}  =  2 -a ${BASH_VERSINFO[1]} '>' 04 ] \
    && _virsh_complete_opt="-o filenames"
complete $_virsh_complete_opt -F _virsh_completion virsh

