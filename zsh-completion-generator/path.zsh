# Source zsh-completion-generator plugin (makes gencomp available interactively)
GENCOMPL_FPATH="${0:a:h}"
if [ -f "${HOME}/.zsh-completion-generator/zsh-completion-generator.plugin.zsh" ]; then
  source "${HOME}/.zsh-completion-generator/zsh-completion-generator.plugin.zsh"
fi
