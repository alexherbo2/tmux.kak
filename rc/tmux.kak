# tmux
# https://github.com/tmux/tmux

# Ensure that we’re running on tmux
remove-hooks global tmux-detection
hook -group tmux-detection global ClientCreate '.*' %{
  trigger-user-hook "TMUX=%val{client_env_TMUX}"
}

define-command -override tmux -params .. -docstring 'tmux [options] [command] [flags]: open tmux' %{
  nop %sh{
    nohup tmux set-environment PWD "$PWD" ';' "$@" < /dev/null > /dev/null 2>&1 &
  }
}

define-command -override tmux-terminal-horizontal -params .. -shell-completion -docstring 'tmux-terminal-horizontal <program> [arguments]: create a new terminal to the right as a tmux pane' %{
  tmux split-window -h -c '#{PWD}' %arg{@}
}

define-command -override tmux-terminal-vertical -params .. -shell-completion -docstring 'tmux-terminal-vertical <program> [arguments]: create a new terminal below as a tmux pane' %{
  tmux split-window -v -c '#{PWD}' %arg{@}
}

define-command -override tmux-terminal-tab -params .. -shell-completion -docstring 'tmux-terminal-tab <program> [arguments]: create a new terminal as a tmux tab' %{
  tmux new-window -c '#{PWD}' %arg{@}
}

define-command -override tmux-terminal-popup -params .. -shell-completion -docstring 'tmux-terminal-popup <program> [arguments]: create a new terminal as a tmux popup' %{
  tmux display-popup -w 90% -h 90% -d '#{PWD}' -E %arg{@}
}

define-command -override tmux-terminal-panel -params .. -shell-completion -docstring 'tmux-terminal-panel <program> [arguments]: create a new terminal as a tmux panel' %{
  tmux split-window -h -b -l 30 -t '{left}' -c '#{PWD}' %arg{@}
}

define-command -override tmux-focus -params ..1 -client-completion -docstring 'tmux-focus [client]: focus the given client, or the current one.' %{
  evaluate-commands -try-client %arg{1} %{
    tmux select-window -t %val{client_env_TMUX_PANE} ';' select-pane -t %val{client_env_TMUX_PANE}
  }
}

define-command -override tmux-integration-enable -docstring 'enable tmux integration' %{
  remove-hooks global tmux-integration
  hook -group tmux-integration global User 'TMUX=(.+?),(.+?),(.+?)' %{
    alias global terminal tmux-terminal-horizontal
    alias global terminal-horizontal tmux-terminal-horizontal
    alias global terminal-vertical tmux-terminal-vertical
    alias global terminal-tab tmux-terminal-tab
    alias global terminal-popup tmux-terminal-popup
    alias global terminal-panel tmux-terminal-panel
    alias global focus tmux-focus
  }
}

define-command -override tmux-integration-disable -docstring 'disable tmux integration' %{
  remove-hooks global tmux-integration
}

# Initialization
tmux-integration-enable
