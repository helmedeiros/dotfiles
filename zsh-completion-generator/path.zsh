# Lazy-load zsh-completion-generator plugin (~0.5s savings)
# Only load when gencomp is first called
GENCOMPL_FPATH="${0:a:h}"
gencomp() {
  unset -f gencomp
  if [ -f "${HOME}/.zsh-completion-generator/zsh-completion-generator.plugin.zsh" ]; then
    source "${HOME}/.zsh-completion-generator/zsh-completion-generator.plugin.zsh"
  fi
  gencomp "$@"
}
