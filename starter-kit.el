
(setq dotfiles-dir (file-name-directory
                   (or load-file-name (buffer-file-name))))
  
(add-to-list 'load-path dotfiles-dir)
;;;;(add-to-list 'load-path (concat dotfiles-dir "/elpa-to-submit"))
;;;;(add-to-list 'load-path (concat dotfiles-dir "/elpa-to-submit/jabber"))
  
;;;;(setq autoload-file (concat dotfiles-dir "loaddefs.el"))
;;;;(setq package-user-dir (concat dotfiles-dir "elpa"))
(setq custom-file (concat dotfiles-dir "custom.el"))

(require 'cl)
(require 'saveplace)
(require 'ffap)
(require 'uniquify)
(require 'ansi-color)
(require 'recentf)

(unless (functionp 'locate-dominating-file)
(defun locate-dominating-file (file name)
  "Look up the directory hierarchy from FILE for a file named NAME.
   Stop at the first parent directory containing a file NAME,
   and return the directory.  Return nil if not found."
   ;; We used to use the above locate-dominating-files code, but the
   ;; directory-files call is very costly, so we're much better off doing
   ;; multiple calls using the code in here.
   ;;
   ;; Represent /home/luser/foo as ~/foo so that we don't try to look for
   ;; `name' in /home or in /.
 (setq file (abbreviate-file-name file))
 (let ((root nil)
       (prev-file file)
       ;; `user' is not initialized outside the loop because
       ;; `file' may not exist, so we may have to walk up part of the
       ;; hierarchy before we find the "initial UID".
       (user nil)
       try)
   (while (not (or root
                   (null file)
                   ;; FIXME: Disabled this heuristic because it is sometimes
                   ;; inappropriate.
                   ;; As a heuristic, we stop looking up the hierarchy of
                   ;; directories as soon as we find a directory belonging
                   ;; to another user.  This should save us from looking in
                   ;; things like /net and /afs.  This assumes that all the
                   ;; files inside a project belong to the same user.
                   ;; (let ((prev-user user))
                   ;;   (setq user (nth 2 (file-attributes file)))
                   ;;   (and prev-user (not (equal user prev-user))))
                   (string-match locate-dominating-stop-dir-regexp file)))
     (setq try (file-exists-p (expand-file-name name file)))
     (cond (try (setq root file))
           ((equal file (setq prev-file file
                              file (file-name-directory
                                    (directory-file-name file))))
            (setq file nil))))
   root))

 (defvar locate-dominating-stop-dir-regexp
   "\\`\\(?:[\\/][\\/][^\\/]+\\|/\\(?:net\\|afs\\|\\.\\.\\.\\)/\\)\\'"))

;;;;(defun starter-kit-load (file)
;;;;  "This function is to be used to load starter-kit-*.org files."
;;;;  (org-babel-load-file (expand-file-name file
;;;;                                         dotfiles-dir)))

;;;;(require 'package)
;;;;(package-initialize)

(defun starter-kit-is-online? ()
  (if (and (functionp 'network-interface-list)
           (network-interface-list))
      (some (lambda (iface) 
              (unless (equal "lo" (car iface))
                (member 'up (first (last (network-interface-info (car iface)))))))
            (network-interface-list))
      t))

;;;;(defun starter-kit-install-packages-from-elpa (list-of-packages)
;;;;  (when (starter-kit-is-online?)
;;;;    (unless package-archive-contents 
;;;;      (package-refresh-contents))
;;;;    (dolist (package list-of-packages)
;;;;      (unless (or (member package package-activated-list)
;;;;                  (functionp package))
;;;;        (message "Installing %s" (symbol-name package))
;;;;        (package-install package)))))

;;;;(starter-kit-install-packages-from-elpa '(idle-highlight
;;;;                                          ruby-mode
;;;;                                          inf-ruby
;;;;                                          js2-mode
;;;;                                          css-mode
;;;;                                          gist
;;;;                                          paredit
;;;;                                          yaml-mode
;;;;                                          find-file-in-project
;;;;                                          magit))

;;;;(autoload 'paredit-mode "paredit" "" t)
;;;;(autoload 'yaml-mode "yaml-mode" "" t)

(when (eq system-type 'darwin)
  (setq system-name (car (split-string system-name "\\."))))

(setq system-specific-config (concat dotfiles-dir system-name ".el")
      system-specific-literate-config (concat dotfiles-dir system-name ".org")
      user-specific-config (concat dotfiles-dir user-login-name ".el")
      user-specific-literate-config (concat dotfiles-dir user-login-name ".org")
      user-specific-dir (concat dotfiles-dir user-login-name))
(add-to-list 'load-path user-specific-dir)

;;;;(add-to-list 'load-path sitelisp-dir)

(require 'thingatpt)
(require 'imenu)

(defun view-url ()
  "Open a new buffer containing the contents of URL."
  (interactive)
  (let* ((default (thing-at-point-url-at-point))
         (url (read-from-minibuffer "URL: " default)))
    (switch-to-buffer (url-retrieve-synchronously url))
    (rename-buffer url t)
    (cond ((search-forward "<?xml" nil t) (xml-mode))
          ((search-forward "<html" nil t) (html-mode)))))

(defun ido-imenu ()
  "Update the imenu index and then use ido to select a symbol to navigate to.
   Symbols matching the text at point are put first in the completion list."
  (interactive)
  (imenu--make-index-alist)
  (let ((name-and-pos '())
        (symbol-names '()))
    (flet ((addsymbols (symbol-list)
                       (when (listp symbol-list)
                         (dolist (symbol symbol-list)
                           (let ((name nil) (position nil))
                             (cond
                              ((and (listp symbol) (imenu--subalist-p symbol))
                               (addsymbols symbol))
                              
                              ((listp symbol)
                               (setq name (car symbol))
                               (setq position (cdr symbol)))
                              
                              ((stringp symbol)
                               (setq name symbol)
                               (setq position (get-text-property 1 'org-imenu-marker symbol))))
                             
                             (unless (or (null position) (null name))
                               (add-to-list 'symbol-names name)
                               (add-to-list 'name-and-pos (cons name position))))))))
      (addsymbols imenu--index-alist))
    ;; If there are matching symbols at point, put them at the beginning of `symbol-names'.
    (let ((symbol-at-point (thing-at-point 'symbol)))
      (when symbol-at-point
        (let* ((regexp (concat (regexp-quote symbol-at-point) "$"))
               (matching-symbols (delq nil (mapcar (lambda (symbol)
                                                     (if (string-match regexp symbol) symbol))
                                                   symbol-names))))
          (when matching-symbols
            (sort matching-symbols (lambda (a b) (> (length a) (length b))))
            (mapc (lambda (symbol) (setq symbol-names (cons symbol (delete symbol symbol-names))))
                  matching-symbols)))))
    (let* ((selected-symbol (ido-completing-read "Symbol? " symbol-names))
           (position (cdr (assoc selected-symbol name-and-pos))))
      (goto-char position))))

(defvar coding-hook nil
  "Hook that gets run on activation of any programming mode.")

(defun local-column-number-mode ()
  (make-local-variable 'column-number-mode)
  (column-number-mode t))

(defun local-comment-auto-fill ()
  (set (make-local-variable 'comment-auto-fill-only-comments) t)
  (auto-fill-mode t))

(defun turn-on-hl-line-mode ()
  (if window-system (hl-line-mode t)))

(defun turn-on-save-place-mode ()
  (setq save-place t))

(defun turn-on-whitespace ()
  (whitespace-mode t))

(defun turn-off-tool-bar ()
  (tool-bar-mode -1))

(defun add-watchwords ()
  (font-lock-add-keywords
   nil '(("\\<\\(FIX\\|TODO\\|FIXME\\|HACK\\|REFACTOR\\):"
          1 font-lock-warning-face t))))

(add-hook 'coding-hook 'local-column-number-mode)
(add-hook 'coding-hook 'local-comment-auto-fill)
(add-hook 'coding-hook 'turn-on-hl-line-mode)
(add-hook 'coding-hook 'turn-on-save-place-mode)
(add-hook 'coding-hook 'pretty-lambdas)
(add-hook 'coding-hook 'add-watchwords)
(add-hook 'coding-hook 'idle-highlight)

(defun run-coding-hook ()
  "Enable things that are convenient across all coding buffers."
  (run-hooks 'coding-hook))

(defun untabify-buffer ()
  (interactive)
  (untabify (point-min) (point-max)))

(defun indent-buffer ()
  (interactive)
  (indent-region (point-min) (point-max)))

(defun cleanup-buffer ()
  "Perform a bunch of operations on the whitespace content of a buffer."
  (interactive)
  (indent-buffer)
  (untabify-buffer)
  (delete-trailing-whitespace))

(defun recentf-ido-find-file ()
  "Find a recent file using ido."
  (interactive)
  (let ((file (ido-completing-read "Choose recent file: " recentf-list nil t)))
    (when file
      (find-file file))))

(defun pretty-lambdas ()
  (font-lock-add-keywords
   nil `(("(?\\(lambda\\>\\)"
          (0 (progn (compose-region (match-beginning 1) (match-end 1)
                                    ,(make-char 'greek-iso8859-7 107))
                    nil))))))

(defun eval-and-replace ()
  "Replace the preceding sexp with its value."
  (interactive)
  (backward-kill-sexp)
  (condition-case nil
      (prin1 (eval (read (current-kill 0)))
             (current-buffer))
    (error (message "Invalid expression")
           (insert (current-kill 0)))))

(defun recompile-init ()
  "Byte-compile all your dotfiles again."
  (interactive)
  (byte-recompile-directory dotfiles-dir 0)
  ;; TODO: remove elpa-to-submit once everything's submitted.
  (byte-recompile-directory (concat dotfiles-dir "elpa-to-submit/" 0)))

;;;;(defun regen-autoloads (&optional force-regen)
;;;;  "Regenerate the autoload definitions file if necessary and load it."
;;;;  (interactive "P")
;;;;  (let ((autoload-dir (concat dotfiles-dir "/elpa-to-submit"))
;;;;        (generated-autoload-file autoload-file))
;;;;    (when (or force-regen
;;;;              (not (file-exists-p autoload-file))
;;;;              (some (lambda (f) (file-newer-than-file-p f autoload-file))
;;;;                    (directory-files autoload-dir t "\\.el$")))
;;;;      (message "Updating autoloads...")
;;;;      (let (emacs-lisp-mode-hook)
;;;;        (update-directory-autoloads autoload-dir))))
;;;;  (load autoload-file))

(defun sudo-edit (&optional arg)
  (interactive "p")
  (if arg
      (find-file (concat "/sudo:root@localhost:" (ido-read-file-name "File: ")))
    (find-alternate-file (concat "/sudo:root@localhost:" buffer-file-name))))

(defun lorem ()
  "Insert a lorem ipsum."
  (interactive)
  (insert "Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do "
          "eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim"
          "ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut "
          "aliquip ex ea commodo consequat. Duis aute irure dolor in "
          "reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla "
          "pariatur. Excepteur sint occaecat cupidatat non proident, sunt in "
          "culpa qui officia deserunt mollit anim id est laborum."))

(defun switch-or-start (function buffer)
  "If the buffer is current, bury it, otherwise invoke the function."
  (if (equal (buffer-name (current-buffer)) buffer)
      (bury-buffer)
    (if (get-buffer buffer)
        (switch-to-buffer buffer)
      (funcall function))))

(defun insert-date ()
  "Insert a time-stamp according to locale's date and time format."
  (interactive)
  (insert (format-time-string "%c" (current-time))))

(defun pairing-bot ()
  "If you can't pair program with a human, use this instead."
  (interactive)
  (message (if (y-or-n-p "Do you have a test for that? ") "Good." "Bad!")))

(defun vc-git-annotate-command (file buf &optional rev)
  (let ((name (file-relative-name file)))
    (vc-git-command buf 0 name "blame" "-w" rev)))

(defun esk-paredit-nonlisp ()
  "Turn on paredit mode for non-lisps."
  (set (make-local-variable 'paredit-space-delimiter-chars)
       (list ?\"))
  (paredit-mode 1))

(defun message-point ()
  (interactive)
  (message "%s" (point)))

(defun toggle-fullscreen ()
  (interactive)
  ;; TODO: this only works for X. patches welcome for other OSes.
  (x-send-client-message nil 0 nil "_NET_WM_STATE" 32
                         '(2 "_NET_WM_STATE_MAXIMIZED_VERT" 0))
  (x-send-client-message nil 0 nil "_NET_WM_STATE" 32
                         '(2 "_NET_WM_STATE_MAXIMIZED_HORZ" 0)))

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

(global-set-key (kbd "C-x g") 'magit-status)

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

(define-key global-map "\C-ca" 'org-agenda)

(define-key global-map "\C-cl" 'org-store-link)

(define-key global-map "\C-x\C-r" 'rgrep)

;;;;(add-to-list 'load-path (expand-file-name "color-theme" sitelisp-dir))
;;;;(require 'color-theme)
;;;;(eval-after-load "color-theme"
;;;;  '(progn (color-theme-initialize)))

(when window-system
  (setq frame-title-format '(buffer-file-name "%f" ("%b")))
  (when (fboundp 'scroll-bar-mode)
    (scroll-bar-mode nil)
    (setq default-vertical-scroll-bar nil))
  (when (fboundp 'tool-bar-mode)
    (tool-bar-mode nil))
  (tooltip-mode nil)
  (blink-cursor-mode nil))

(add-hook 'before-make-frame-hook 'turn-off-tool-bar)

(when (fboundp 'menu-bar-mode)
  (menu-bar-mode nil))

(setq visible-bell t)

(setq echo-keystrokes 0.1
      font-lock-maximum-decoration t
      inhibit-startup-message t
      transient-mark-mode t
      color-theme-is-global t
      delete-by-moving-to-trash t
      shift-select-mode nil
      mouse-yank-at-point t
      require-final-newline t
      truncate-partial-width-windows nil
      uniquify-buffer-name-style 'forward
      whitespace-style '(trailing lines space-before-tab
                                  indentation space-after-tab)
      whitespace-line-column 80
      ediff-window-setup-function 'ediff-setup-windows-plain
      oddmuse-directory (concat dotfiles-dir "oddmuse")
      xterm-mouse-mode t
      save-place-file (concat dotfiles-dir "places"))

(mouse-wheel-mode t)

(add-to-list 'safe-local-variable-values '(lexical-binding . t))
(add-to-list 'safe-local-variable-values '(whitespace-line-column . 80))

(set-default 'indent-tabs-mode nil)
(set-default 'indicate-empty-lines t)
(set-default 'imenu-auto-rescan t)
  
(add-hook 'text-mode-hook 'turn-on-auto-fill)
(add-hook 'text-mode-hook 'turn-on-flyspell)
  
(defalias 'yes-or-no-p 'y-or-n-p)
(random t) ;; Seed the random-number generator

(setq x-select-enable-clipboard t)

(set-terminal-coding-system 'utf-8)
(set-keyboard-coding-system 'utf-8)
(prefer-coding-system 'utf-8)
(ansi-color-for-comint-mode-on)

(delete 'try-expand-line hippie-expand-try-functions-list)
(delete 'try-expand-list hippie-expand-try-functions-list)

(auto-compression-mode t)

(global-font-lock-mode t)

(recentf-mode 1)

(show-paren-mode 1)

(setq backup-directory-alist `(("." . ,(expand-file-name
                                        (concat dotfiles-dir "backups")))))

(add-to-list 'auto-mode-alist '("COMMIT_EDITMSG$" . diff-mode))
(add-to-list 'auto-mode-alist '("\\.css$" . css-mode))
;;;;(require 'yaml-mode)
;;;;(add-to-list 'auto-mode-alist '("\\.ya?ml$" . yaml-mode))
;;;;(add-to-list 'auto-mode-alist '("\\.rb$" . ruby-mode))
;;;;(add-to-list 'auto-mode-alist '("Rakefile$" . ruby-mode))
(add-to-list 'auto-mode-alist '("\\.js\\(on\\)?$" . js2-mode))
(add-to-list 'auto-mode-alist '("\\.xml$" . nxml-mode))

(eval-after-load 'grep
  '(when (boundp 'grep-find-ignored-files)
    (add-to-list 'grep-find-ignored-files "target")
    (add-to-list 'grep-find-ignored-files "*.class")))

(setq diff-switches "-u")

(eval-after-load 'diff-mode
  '(progn
     (set-face-foreground 'diff-added "green4")
     (set-face-foreground 'diff-removed "red3")))

(eval-after-load 'magit
  '(progn
     (set-face-foreground 'magit-diff-add "green3")
     (set-face-foreground 'magit-diff-del "red3")))

(eval-after-load 'mumamo
  '(eval-after-load 'zenburn
     '(ignore-errors (set-face-background
                      'mumamo-background-chunk-submode "gray22"))))

(add-hook 'oddmuse-mode-hook
         (lambda ()
           (unless (string-match "question" oddmuse-post)
             (setq oddmuse-post (concat "uihnscuskc=1;" oddmuse-post)))))

(when (> emacs-major-version 21)
  (ido-mode t)
  (setq ido-enable-prefix nil
        ido-enable-flex-matching t
        ido-create-new-buffer 'always
        ido-use-filename-at-point t
        ido-max-prospects 10))

(setq mumamo-chunk-coloring 'submode-colored
      nxhtml-skip-welcome t
      indent-region-mode t
      rng-nxml-auto-validate-flag nil)

(dolist (r `((?i (file . ,(concat dotfiles-dir "init.el")))
             (?s (file . ,(concat dotfiles-dir "starter-kit.org")))))
  (set-register (car r) (cadr r)))

;;;;(org-babel-lob-ingest
;;;; (expand-file-name
;;;;  "library-of-babel.org"
;;;;  (expand-file-name
;;;;   "babel"
;;;;   (expand-file-name
;;;;    "contrib"
;;;;    (expand-file-name
;;;;     "org" sitelisp-dir)))))

;;;;(unless (boundp 'Info-directory-list)
;;;;  (setq Info-directory-list Info-default-directory-list))
;;;;(setq Info-directory-list
;;;;      (cons (expand-file-name
;;;;             "doc"
;;;;             (expand-file-name
;;;;              "org" sitelisp-dir))
;;;;            Info-directory-list))

(unless (boundp 'org-publish-project-alist)
  (setq org-publish-project-alist nil))
(let ((this-dir (file-name-directory (or load-file-name buffer-file-name))))
  (add-to-list 'org-publish-project-alist
               `("starter-kit-documentation"
                 :base-directory ,this-dir
                 :base-extension "org"
                 :style "<link rel=\"stylesheet\" href=\"emacs.css\" type=\"text/css\"/>"
                 :publishing-directory ,this-dir
                 :index-filename "starter-kit.org"
                 :auto-postamble nil)))

(setq eshell-cmpl-cycle-completions nil
      eshell-save-history-on-exit t
      eshell-cmpl-dir-ignore "\\`\\(\\.\\.?\\|CVS\\|\\.svn\\|\\.git\\)/\\'")

(eval-after-load 'esh-opt
  '(progn
     (require 'em-prompt)
     (require 'em-term)
     (require 'em-cmpl)
     (setenv "PAGER" "cat")
     (set-face-attribute 'eshell-prompt nil :foreground "turquoise1")
     (when (< emacs-major-version 23)
       (add-hook 'eshell-mode-hook ;; for some reason this needs to be a hook
                 '(lambda () (define-key eshell-mode-map "\C-a" 'eshell-bol)))
       (add-to-list 'eshell-output-filter-functions 'eshell-handle-ansi-color))

     ;; TODO: submit these via M-x report-emacs-bug
     (add-to-list 'eshell-visual-commands "ssh")
     (add-to-list 'eshell-visual-commands "tail")
     (add-to-list 'eshell-command-completions-alist
                  '("gunzip" "gz\\'"))
     (add-to-list 'eshell-command-completions-alist
                  '("tar" "\\(\\.tar|\\.tgz\\|\\.tar\\.gz\\)\\'"))))

(defun eshell/cds ()
  "Change directory to the project's root."
  (eshell/cd (locate-dominating-file default-directory "src")))
    
(defun eshell/find (dir &rest opts)
  (find-dired dir (mapconcat 'identity opts " ")))

(setq eshell-directory-name (expand-file-name "./" (expand-file-name "eshell" dotfiles-dir)))

(define-key lisp-mode-shared-map (kbd "RET") 'reindent-then-newline-and-indent)

(define-key lisp-mode-shared-map (kbd "C-c v") 'eval-buffer)

(define-key lisp-mode-shared-map (kbd "C-c l") "lambda")

(defface esk-paren-face
   '((((class color) (background dark))
      (:foreground "grey50"))
     (((class color) (background light))
      (:foreground "grey55")))
   "Face used to dim parentheses."
   :group 'starter-kit-faces)

(defun turn-on-paredit ()
  (paredit-mode +1))

(eval-after-load 'paredit
  ;; need a binding that works in the terminal
  '(define-key paredit-mode-map (kbd "M-)") 'paredit-forward-slurp-sexp))

(add-hook 'emacs-lisp-mode-hook 'turn-on-eldoc-mode)
(add-hook 'emacs-lisp-mode-hook 'esk-remove-elc-on-save)

(defun esk-remove-elc-on-save ()
  "If you're saving an elisp file, likely the .elc is no longer valid."
  (make-local-variable 'after-save-hook)
  (add-hook 'after-save-hook
            (lambda ()
              (if (file-exists-p (concat buffer-file-name "c"))
                  (delete-file (concat buffer-file-name "c"))))))

(define-key emacs-lisp-mode-map (kbd "M-.") 'find-function-at-point)

(eval-after-load 'find-file-in-project
  '(add-to-list 'ffip-patterns "*.clj"))

(defun clojure-project (path)
  (interactive)
  (message "Deprecated in favour of M-x swank-clojure-project. Install swank-clojure from ELPA."))

(eval-after-load 'clojure-mode
  '(font-lock-add-keywords
    'clojure-mode `(("(\\(fn\\>\\)"
                     (0 (progn (compose-region (match-beginning 1)
                                               (match-end 1) "ƒ")
                               nil))))))

(dolist (x '(scheme emacs-lisp lisp clojure))
  (when window-system
    (font-lock-add-keywords
     (intern (concat (symbol-name x) "-mode"))
     '(("(\\|)" . 'esk-paren-face))))
  (add-hook
   (intern (concat (symbol-name x) "-mode-hook")) 'turn-on-paredit)
  (add-hook
   (intern (concat (symbol-name x) "-mode-hook")) 'run-coding-hook))

(defun pretty-lambdas-haskell ()
  (font-lock-add-keywords
   nil `((,(concat "(?\\(" (regexp-quote "\\") "\\)")
          (0 (progn (compose-region (match-beginning 1) (match-end 1)
                                    ,(make-char 'greek-iso8859-7 107))
                    nil))))))

(add-hook 'haskell-mode-hook 'run-coding-hook)
(add-hook 'haskell-mode-hook 'pretty-lambdas-haskell)

;;;;(eval-after-load 'ruby-mode
;;;;  '(progn
;;;;     ;; work around possible elpa bug
;;;;     (ignore-errors (require 'ruby-compilation))
;;;;     (setq ruby-use-encoding-map nil)
;;;;     (add-hook 'ruby-mode-hook 'inf-ruby-keys)
;;;;     (define-key ruby-mode-map (kbd "RET") 'reindent-then-newline-and-indent)
;;;;     (define-key ruby-mode-map (kbd "C-c l") "lambda")))

(global-set-key (kbd "C-h r") 'ri)

(add-to-list 'auto-mode-alist '("\\.rake$" . ruby-mode))
(add-to-list 'auto-mode-alist '("\\.gemspec$" . ruby-mode))
(add-to-list 'auto-mode-alist '("\\.ru$" . ruby-mode))
(add-to-list 'auto-mode-alist '("Rakefile$" . ruby-mode))
(add-to-list 'auto-mode-alist '("Gemfile$" . ruby-mode))
(add-to-list 'auto-mode-alist '("Capfile$" . ruby-mode))
(add-to-list 'auto-mode-alist '("Vagrantfile$" . ruby-mode))

(add-to-list 'completion-ignored-extensions ".rbc")

(defun pcomplete/rake ()
  "Completion rules for the `ssh' command."
  (pcomplete-here (pcmpl-rake-tasks)))

(defun pcmpl-rake-tasks ()
   "Return a list of all the rake tasks defined in the current
    projects.  I know this is a hack to put all the logic in the
    exec-to-string command, but it works and seems fast"
   (delq nil (mapcar '(lambda(line)
                   (if (string-match "rake \\([^ ]+\\)" line) (match-string 1 line)))
                (split-string (shell-command-to-string "rake -T") "[\n]"))))

(defun rake (task)
  (interactive (list (completing-read "Rake (default: default): "
                                      (pcmpl-rake-tasks))))
  (shell-command-to-string (concat "rake " (if (= 0 (length task)) "default" task))))

(eval-after-load 'ruby-compilation
  '(progn
     (defadvice ruby-do-run-w/compilation (before kill-buffer (name cmdlist))
       (let ((comp-buffer-name (format "*%s*" name)))
         (when (get-buffer comp-buffer-name)
           (with-current-buffer comp-buffer-name
             (delete-region (point-min) (point-max))))))
     (ad-activate 'ruby-do-run-w/compilation)))

(add-hook 'ruby-mode-hook 'run-coding-hook)

(defun flymake-ruby-init ()
  (let* ((temp-file (flymake-init-create-temp-buffer-copy
                     'flymake-create-temp-inplace))
         (local-file (file-relative-name
                      temp-file
         (file-name-directory buffer-file-name))))
    ;; Invoke ruby with '-c' to get syntax checking
    (list "ruby" (list "-c" local-file))))

(defun flymake-ruby-enable ()
  (when (and buffer-file-name
             (file-writable-p
              (file-name-directory buffer-file-name))
             (file-writable-p buffer-file-name)
             (if (fboundp 'tramp-list-remote-buffers)
                 (not (subsetp
                       (list (current-buffer))
                       (tramp-list-remote-buffers)))
               t))
    (local-set-key (kbd "C-c d")
                   'flymake-display-err-menu-for-current-line)
    (flymake-mode t)))

(eval-after-load 'ruby-mode
  '(progn
     (require 'flymake)
     (push '(".+\\.rb$" flymake-ruby-init) flymake-allowed-file-name-masks)
     (push '("Rakefile$" flymake-ruby-init) flymake-allowed-file-name-masks)
     (push '("^\\(.*\\):\\([0-9]+\\): \\(.*\\)$" 1 2 nil 3)
           flymake-err-line-patterns)
     (add-hook 'ruby-mode-hook 'flymake-ruby-enable)))

(setq rinari-major-modes
      (list 'mumamo-after-change-major-mode-hook 'dired-mode-hook 'ruby-mode-hook
            'css-mode-hook 'yaml-mode-hook 'javascript-mode-hook))

(autoload 'espresso-mode "espresso" "Start espresso-mode" t)
(add-to-list 'auto-mode-alist '("\\.js$" . espresso-mode))
(add-to-list 'auto-mode-alist '("\\.json$" . espresso-mode))
(add-hook 'espresso-mode-hook 'moz-minor-mode)
(add-hook 'espresso-mode-hook 'esk-paredit-nonlisp)
(add-hook 'espresso-mode-hook 'run-coding-hook)
(setq espresso-indent-level 2)

;; If you prefer js2-mode, use this instead:
;; (add-to-list 'auto-mode-alist '("\\.js$" . espresso-mode))

(eval-after-load 'espresso
  '(progn (define-key espresso-mode-map "{" 'paredit-open-curly)
          (define-key espresso-mode-map "}" 'paredit-close-curly-and-newline)
          ;; fixes problem with pretty function font-lock
          (define-key espresso-mode-map (kbd ",") 'self-insert-command)
          (font-lock-add-keywords
           'espresso-mode `(("\\(function *\\)("
                             (0 (progn (compose-region (match-beginning 1)
                                                       (match-end 1) "ƒ")
                                       nil)))))))

(eval-after-load 'cperl-mode
  '(progn
     (define-key cperl-mode-map (kbd "RET") 'reindent-then-newline-and-indent)))

(global-set-key (kbd "C-h P") 'perldoc)

(add-to-list 'auto-mode-alist '("\\.p[lm]$" . cperl-mode))
(add-to-list 'auto-mode-alist '("\\.pod$" . pod-mode))
(add-to-list 'auto-mode-alist '("\\.tt$" . tt-mode))

;;;;(regen-autoloads)

(load custom-file 'noerror)

;;;;(if (file-exists-p sitelisp-dir)
;;;;  (let ((default-directory sitelisp-dir))
;;;;    (normal-top-level-add-subdirs-to-load-path)))
(if (file-exists-p user-specific-config) (load user-specific-config))
;;;;(if (file-exists-p user-specific-literate-config)
;;;;    (org-babel-load-file user-specific-literate-config))
(when (file-exists-p user-specific-dir)
  (let ((default-directory user-specific-dir))
    (mapc #'load (directory-files user-specific-dir nil ".*el$"))
;;;;    (mapc #'org-babel-load-file (directory-files user-specific-dir nil ".*org$"))
    ))
(if (file-exists-p system-specific-config) (load system-specific-config))
;;;;(if (file-exists-p system-specific-literate-config)
;;;;    (org-babel-load-file system-specific-literate-config))
