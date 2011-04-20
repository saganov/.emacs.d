
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

(require 'dominating-file)

;;;;(defun starter-kit-load (file)
;;;;  "This function is to be used to load starter-kit-*.org files."
;;;;  (org-babel-load-file (expand-file-name file
;;;;                                         dotfiles-dir)))
(defun starter-kit-load (file)
  "This function is to be used to load starter-kit-*.el files."
  (load-file (expand-file-name file
                               dotfiles-dir)))

;;;;(require 'package)
;;;;(package-initialize)

;;;; TODO: move this to the load packages module
;;;;(defun starter-kit-is-online? ()
;;;;  (if (and (functionp 'network-interface-list)
;;;;           (network-interface-list))
;;;;      (some (lambda (iface) 
;;;;              (unless (equal "lo" (car iface))
;;;;                (member 'up (first (last (network-interface-info (car iface)))))))
;;;;            (network-interface-list))
;;;;      t))
;;;; TODO: Use it in load packages module
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
;;;;      system-specific-literate-config (concat dotfiles-dir system-name ".org")
      user-specific-config (concat dotfiles-dir user-login-name ".el")
;;;;      user-specific-literate-config (concat dotfiles-dir user-login-name ".org")
      user-specific-dir (concat dotfiles-dir user-login-name))
(add-to-list 'load-path user-specific-dir)

;;;;(add-to-list 'load-path sitelisp-dir)

(starter-kit-load "starter-kit-defuns.el")

;;;;(defun esk-paredit-nonlisp ()
;;;;  "Turn on paredit mode for non-lisps."
;;;;  (set (make-local-variable 'paredit-space-delimiter-chars)
;;;;       (list ?\"))
;;;;  (paredit-mode 1))

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

(starter-kit-load "starter-kit-bindings.el")

(starter-kit-load "starter-kit-misc.el")

(setq mumamo-chunk-coloring 'submode-colored
      nxhtml-skip-welcome t
      indent-region-mode t
      rng-nxml-auto-validate-flag nil)

(starter-kit-load "starter-kit-registers.el")

(starter-kit-load "starter-kit-org.el")

(starter-kit-load "starter-kit-eshell.el")

(starter-kit-load "starter-kit-lisp.el")

(starter-kit-load "starter-kit-haskell.el")

;;;;(starter-kit-load "starter-kit-python.el")

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
