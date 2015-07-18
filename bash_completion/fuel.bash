_fuel61_completion()
{
    local ns opts cur
    opts="-h --help -v --version --fuel-version --debug --user --password --tenant --yaml --json"
    ns="notify plugins network graph provisioning environment deploy-changes role healh nodegroup node stop notifications user deployment reset task setting token snapshot release vmware-settings"
    cur=${COMP_WORDS[COMP_CWORD]}
    COMPREPLY=( $( compgen -W "$opts $ns" -- "$cur" ) )

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

