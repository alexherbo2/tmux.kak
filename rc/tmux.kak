# tmux
# https://github.com/tmux/tmux

# Ensure that we’re running on tmux
remove-hooks global tmux-detection
hook -group tmux-detection global ClientCreate '.*' %{
  trigger-user-hook "TMUX=%val{client_env_TMUX}"
}
hook -group tmux-detection global FocusIn '.*' %{
  trigger-user-hook "TMUX=%val{client_env_TMUX}"
}

define-command -override tmux -params .. -docstring 'tmux [options] [command] [flags]: open tmux' %{
  nop %sh{
    nohup tmux "$@" < /dev/null > /dev/null 2>&1 &
  }
}

define-command -override tmux-terminal-horizontal -params .. -shell-completion -docstring 'tmux-terminal-horizontal <program> [arguments]: create a new terminal to the right as a tmux pane' %{
  tmux split-window -e "KAKOUNE_SESSION=%val{session}" -e "KAKOUNE_CLIENT=%val{client}" -h %arg{@}
}

define-command -override tmux-terminal-vertical -params .. -shell-completion -docstring 'tmux-terminal-vertical <program> [arguments]: create a new terminal below as a tmux pane' %{
  tmux split-window -e "KAKOUNE_SESSION=%val{session}" -e "KAKOUNE_CLIENT=%val{client}" -v %arg{@}
}

# New tab to the right
define-command -override tmux-terminal-tab -params .. -shell-completion -docstring 'tmux-terminal-tab <program> [arguments]: create a new terminal as a tmux tab' %{
  tmux new-window -e "KAKOUNE_SESSION=%val{session}" -e "KAKOUNE_CLIENT=%val{client}" -a %arg{@}
}

define-command -override tmux-terminal-popup -params .. -shell-completion -docstring 'tmux-terminal-popup <program> [arguments]: create a new terminal as a tmux popup' %{
  # TODO: Replace `sh -c` command with `-e` flag.
  tmux display-popup -w 90% -h 90% -E sh -c "KAKOUNE_SESSION=%val{session} KAKOUNE_CLIENT=%val{client} ""${@:-SHELL}""" -- %arg{@}
}

define-command -override tmux-terminal-panel -params .. -shell-completion -docstring 'tmux-terminal-panel <program> [arguments]: create a new terminal as a tmux panel' %{
  tmux split-window -e "KAKOUNE_SESSION=%val{session}" -e "KAKOUNE_CLIENT=%val{client}" -h -b -l 30 -t '{left}' %arg{@}
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

  # Clipboard integration
  hook -group tmux-integration global RegisterModified '"' %{
    tmux set-buffer -w %val{main_reg_dquote}
  }
}

define-command -override tmux-integration-disable -docstring 'disable tmux integration' %{
  remove-hooks global tmux-integration
}

# Initialization
tmux-integration-enable
