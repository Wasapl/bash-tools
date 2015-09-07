_fuel2()
{
  local cur prev words
  COMPREPLY=()
  _get_comp_words_by_ref -n : cur prev words

  # Command data:
  cmds='complete env fuel-version help network-group network-template node task'
  cmds_complete='-h --help --name --shell'
  cmds_env='add create delete deploy list show spawn-vms update upgrade'
  cmds_env_add='nodes'
  cmds_env_add_nodes='-h --help -e --env -n --nodes -r --roles'
  cmds_env_create='-h --help -f --format -c --column --max-width --variable --prefix -r --release -n --net-provider -nst --net-segmentation-type'
  cmds_env_delete='-h --help -f --force'
  cmds_env_deploy='-h --help'
  cmds_env_list='-h --help -f --format -c --column --max-width --quote -s --sort-columns'
  cmds_env_show='-h --help -f --format -c --column --max-width --variable --prefix'
  cmds_env_spawn-vms='-h --help'
  cmds_env_update='-h --help -f --format -c --column --max-width --variable --prefix -n --name'
  cmds_env_upgrade='-h --help'
  cmds_fuel-version='-h --help'
  cmds_help='-h --help'
  cmds_network-group='create delete list show update'
  cmds_network-group_create='-h --help -f --format -c --column --max-width --variable --prefix -N --node-group -C --cidr -V --vlan -r --release -g --gateway -m --meta'
  cmds_network-group_delete='-h --help'
  cmds_network-group_list='-h --help -f --format -c --column --max-width --quote -s --sort-columns'
  cmds_network-group_show='-h --help -f --format -c --column --max-width --variable --prefix'
  cmds_network-group_update='-h --help -f --format -c --column --max-width --variable --prefix -n --name -N --node-group -C --cidr -V --vlan -g --gateway -m --meta'
  cmds_network-template='delete download upload'
  cmds_network-template_delete='-h --help'
  cmds_network-template_download='-h --help -d --dir'
  cmds_network-template_upload='-h --help -f --file'
  cmds_node='create-vms-conf label list list-vms-conf show update'
  cmds_node_create-vms-conf='-h --help --conf'
  cmds_node_label='delete list set'
  cmds_node_label_delete='-h --help -l --labels --labels-all -n --nodes --nodes-all'
  cmds_node_label_list='-h --help -f --format -c --column --max-width --quote -s --sort-columns -n --nodes'
  cmds_node_label_set='-h --help -l --labels -n --nodes --nodes-all'
  cmds_node_list='-h --help -f --format -c --column --max-width --quote -s --sort-columns -e --env -l --labels'
  cmds_node_list-vms-conf='-h --help -f --format -c --column --max-width --variable --prefix'
  cmds_node_show='-h --help -f --format -c --column --max-width --variable --prefix'
  cmds_node_update='-h --help -f --format -c --column --max-width --variable --prefix -H --hostname'
  cmds_task='list show'
  cmds_task_list='-h --help -f --format -c --column --max-width --quote -s --sort-columns'
  cmds_task_show='-h --help -f --format -c --column --max-width --variable --prefix'

  cmd=""
  words[0]=""
  completed="${cmds}"
  for var in "${words[@]:1}"
  do
    if [[ ${var} == -* ]] ; then
      break
    fi
    if [ -z "${cmd}" ] ; then
      proposed="${var}"
    else
      proposed="${cmd}_${var}"
    fi
    local i="cmds_${proposed}"
    local comp="${!i}"
    if [ -z "${comp}" ] ; then
      break
    fi
    if [[ ${comp} == -* ]] ; then
      if [[ ${cur} != -* ]] ; then
        completed=""
        break
      fi
    fi
    cmd="${proposed}"
    completed="${comp}"
  done

  if [ -z "${completed}" ] ; then
    COMPREPLY=( $( compgen -f -- "$cur" ) $( compgen -d -- "$cur" ) )
  else
    COMPREPLY=( $(compgen -W "${completed}" -- ${cur}) )
  fi
  return 0
}
complete -F _fuel2 fuel2
