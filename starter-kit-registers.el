
(dolist (r `((?i (file . ,(concat dotfiles-dir "init.el")))
             (?s (file . ,(concat dotfiles-dir "starter-kit.el")))
             (?r (file . ,(concat dotfiles-dir "starter-kit-registers.el")))))
  (set-register (car r) (cadr r)))
