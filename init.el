;;;; So the idea is that you copy/paste this code into your *scratch* buffer,
;;;; hit C-j, and you have a working el-get.
;;(url-retrieve
;; "https://github.com/dimitri/el-get/raw/master/el-get-install.el"
;; (lambda (s)
;;   (end-of-buffer)
;;   (eval-print-last-sexp)))

(setq dotfiles-dir (file-name-directory
		    (or load-file-name (buffer-file-name))))
(add-to-list 'load-path dotfiles-dir)

(setq custom-file (concat dotfiles-dir "custom.el"))

;; visual settings
(setq inhibit-splash-screen t)
(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)

(line-number-mode 1)
(column-number-mode 1)

;; Use the clipboard, pretty please, so that copy/paste "works"
(setq x-select-enable-clipboard t)

(set-frame-font "Monospace-10")

(global-hl-line-mode)

;; suivre les changements exterieurs sur les fichiers
(global-auto-revert-mode 1)

;; pour les couleurs dans M-x shell
(autoload 'ansi-color-for-comint-mode-on "ansi-color" nil t)
(add-hook 'shell-mode-hook 'ansi-color-for-comint-mode-on)

;; S-fleches pour changer de fenêtre
(windmove-default-keybindings)
(setq windmove-wrap-around t)

;; find-file-at-point quand ça a du sens
(setq ffap-machine-p-known 'accept) ; no pinging
(setq ffap-url-regexp nil) ; disable URL features in ffap
(setq ffap-ftp-regexp nil) ; disable FTP features in ffap
(define-key global-map (kbd "C-x C-f") 'find-file-at-point)

(require 'ibuffer)
(global-set-key "\C-x\C-b" 'ibuffer)

;; use iswitchb-mode for C-x b
(iswitchb-mode)

;; I can't remember having meant to use C-z as suspend-frame
(global-set-key (kbd "C-z") 'undo)

;; winner-mode pour revenir sur le layout précédent C-c <left>
(winner-mode 1)

;; dired-x pour C-x C-j
(require 'dired-x)

(require 'saganov-packages)