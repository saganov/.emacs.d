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
 '(;el-get
   php-mode-improved
   auto-complete
   yasnippet
   switch-window
   cssh
   sicp
   color-theme-zenburn
   openwith
   emacschrome

   (:name package
	  :after (lambda()
 	           (package-initialize)
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

    (:name sunrise-commander
          :after (lambda ()
                   (global-set-key (kbd "C-c x") 'sunrise)
                   (global-set-key (kbd "C-c X") 'sunrise-cd)))

   (:name magit
          :after (lambda ()
                   ;;(define-key global-map "\M-\C-g" 'magit-status)
                   (global-set-key (kbd "C-x g") 'magit-status)
                   ;;(global-set-key (kbd "C-x C-z") 'magit-status))
          ))

   (:name goto-last-change
          :after (lambda ()
                   (global-set-key (kbd "C-x C-/") 'goto-last-change)))

   (:name idle-highlight
          :type elpa
;;          :after (lambda ()
;;                   (add-hook 'coding-hook 'idle-highlight))
                   )
   (:name js2-mode        :type elpa)
   (:name css-mode        :type elpa)
   (:name auto-dictionary :type elpa)
   (:name paredit
	  :after (lambda ()
                   (autoload 'paredit-mode "paredit" "" t))
	  :type elpa)
   (:name yaml-mode
	  :after (lambda () (autoload 'yaml-mode "yaml-mode" "" t))
	  :type elpa)
   (:name gist            :type elpa)
   (:name find-file-in-project :type elpa)
   (:name lisppaste       :type elpa)
   ;;(:name sunrise-commander :type elpa)
   (:name color-theme
      :after (lambda() (load "color-theme-zenburn/zenburn") (zenburn)))))
 
;;(when window-system
;;  (add-to-list 'el-get-sources '(:name color-theme :after (lambda() (load "color-theme-zenburn/zenburn") (zenburn))) 'color-theme-zenburn))

(el-get 'sync)


(provide 'saganov-packages)
