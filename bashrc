#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

eval "$(oh-my-posh init bash --config ~/.config/oh-my-posh-themes/mytheme.omp.json)"

alias ls='ls -lah --color=auto'
alias vim='nvim'
alias grep='grep --color=auto'
PS1='[\u@\h \W]\$ '
