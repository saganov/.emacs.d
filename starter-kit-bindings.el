
(defun backward-kill-word-or-kill-region (arg)
  (interactive "p")
  (if (region-active-p)
      (kill-region (region-beginning) 
                   (region-end))
    (backward-kill-word arg)))

(global-set-key (kbd "C-w") 'backward-kill-word-or-kill-region)

(define-key minibuffer-local-map (kbd "C-w") 'backward-kill-word-or-kill-region)

(add-hook 'ido-setup-hook 
          (lambda ()
            (define-key ido-completion-map (kbd "C-w") 'ido-delete-backward-word-updir)))

(global-set-key (kbd "C-q") 'undo)
(global-set-key (kbd "C-z") 'quoted-insert)

(global-set-key (kbd "C-x C-m") 'execute-extended-command)
(global-set-key (kbd "C-с C-m") 'execute-extended-command)

(defun kill-current-buffer ()
  (interactive)
  (kill-buffer (current-buffer)))

(global-set-key (kbd "C-x C-k") 'kill-current-buffer)

(global-set-key (kbd "C-s") 'isearch-forward-regexp)
(global-set-key (kbd "\C-r") 'isearch-backward-regexp)
(global-set-key (kbd "C-M-s") 'isearch-forward)
(global-set-key (kbd "C-M-r") 'isearch-backward)

(global-set-key (kbd "M-/") 'hippie-expand)
(global-set-key (kbd "S-SPC") 'dabbrev-expand)

(global-set-key (kbd "C-x \\") 'align-regexp)

(global-set-key (kbd "C-c n") 'cleanup-buffer)

(global-set-key [f1] 'menu-bar-mode)

(define-key global-map (kbd "C-+") 'text-scale-increase)
(define-key global-map (kbd "C-=") 'text-scale-increase)
(define-key global-map (kbd "C--") 'text-scale-decrease)

(global-set-key (kbd "C-x C-i") 'ido-imenu)

(global-set-key (kbd "C-x M-f") 'ido-find-file-other-window)
(global-set-key (kbd "C-x C-M-f") 'find-file-in-project)
(global-set-key (kbd "C-x f") 'recentf-ido-find-file)
(global-set-key (kbd "C-x C-p") 'find-file-at-point)
(global-set-key (kbd "C-c y") 'bury-buffer)
(global-set-key (kbd "C-c r") 'revert-buffer)
(global-set-key (kbd "M-`") 'file-cache-minibuffer-complete)
(global-set-key (kbd "C-x C-b") 'ibuffer)

(windmove-default-keybindings)

(global-set-key (kbd "C-x O") (lambda () (interactive) (other-window -1)))
(global-set-key (kbd "C-x C-o") (lambda () (interactive) (other-window 1)))

(global-set-key (kbd "C-x ^") 'join-line)

(global-set-key (kbd "C-x m") 'eshell)

(global-set-key (kbd "C-x M") (lambda () (interactive) (eshell t)))

(global-set-key (kbd "C-x M-m") 'shell)

(global-set-key (kbd "C-x h") 'view-url)

(global-set-key (kbd "C-h a") 'apropos)

(global-set-key (kbd "C-c e") 'eval-and-replace)

(global-set-key (kbd "C-c j") (lambda () 
                                (interactive)
                                (switch-or-start 'jabber-connect "*-jabber-*")))
(global-set-key (kbd "C-c J") 'jabber-send-presence)
(global-set-key (kbd "C-c M-j") 'jabber-disconnect)

(global-set-key (kbd "C-c i") (lambda () 
                                (interactive) 
                                (switch-or-start (lambda () (rcirc-connect "irc.freenode.net"))
                                                 "*irc.freenode.net*")))

(global-set-key (kbd "C-c g") (lambda () (interactive) (switch-or-start 'gnus "*Group*")))

;;;; Moved to load packages module
;;;;(global-set-key (kbd "C-x g") 'magit-status)

(eval-after-load 'vc
  (define-key vc-prefix-map "i" '(lambda () (interactive)
                                   (if (not (eq 'Git (vc-backend buffer-file-name)))
                                       (vc-register)
                                     (shell-command (format "git add %s" buffer-file-name))
                                     (message "Staged changes.")))))

(define-key isearch-mode-map (kbd "C-o")
  (lambda () (interactive)
    (let ((case-fold-search isearch-case-fold-search))
      (occur (if isearch-regexp isearch-string (regexp-quote isearch-string))))))

(provide 'starter-kit-bindings)
;;; starter-kit-bindings.el ends here

(define-key global-map "\C-ca" 'org-agenda)

(define-key global-map "\C-cl" 'org-store-link)

(define-key global-map "\C-x\C-r" 'rgrep)
