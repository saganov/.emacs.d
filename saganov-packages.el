;;;; So the idea is that you copy/paste this code into your *scratch* buffer,
;;;; hit C-j, and you have a working el-get.
;;(url-retrieve
;; "https://github.com/dimitri/el-get/raw/master/el-get-install.el"
;; (lambda (s)
;;   (end-of-buffer)
;;   (eval-print-last-sexp)))

;;; saganov-packages.el --- Petr Saganov
;;
;; Set el-get-sources and call el-get to init all those packages we need.
;;(add-to-list 'load-path (concat dotfiles-dir "/el-get/el-get"))
(add-to-list 'load-path "~/.emacs.d/el-get/el-get")
(require 'el-get)
(setq
 el-get-sources
 '(el-get
   php-mode-improved
   auto-complete
   yasnippet
   switch-window
   cssh
   sicp

   (:name package
	  :after (lambda()
		   (setq package-archives )
		   (add-to-list 'package-archives
				'("original" . "http://tromey.com/elpa/"))
		   (add-to-list 'package-archives
				'("technomancy" . "http://repo.technomancy.us/emacs/") t)
		   (add-to-list 'package-archives
				'("marmalade" . "http://marmalade-repo.org/packages/") t)))
   
   (:name buffer-move
          :after (lambda ()
                   (global-set-key (kbd "<C-S-up>")     'buf-move-up)
                   (global-set-key (kbd "<C-S-down>")   'buf-move-down)
                   (global-set-key (kbd "<C-S-left>")   'buf-move-left)
                   (global-set-key (kbd "<C-S-right>")  'buf-move-right)))

   (:name magit
          :after (lambda ()
                   (global-set-key (kbd "C-x C-z") 'magit-status)))

   (:name goto-last-change
          :after (lambda ()
                   (global-set-key (kbd "C-x C-/") 'goto-last-change)))
   (:name auto-dictionary :type elpa)
   (:name gist            :type elpa)
   (:name lisppaste       :type elpa)))

(when window-system
  (add-to-list 'el-get-sources  'color-theme-tango))

(el-get 'sync)


(provide 'saganov-packages)