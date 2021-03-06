
(autoload 'espresso-mode "espresso" "Start espresso-mode" t)
(add-to-list 'auto-mode-alist '("\\.js$" . espresso-mode))
(add-to-list 'auto-mode-alist '("\\.json$" . espresso-mode))
(add-hook 'espresso-mode-hook 'moz-minor-mode)
;;;;(add-hook 'espresso-mode-hook 'esk-paredit-nonlisp)
(add-hook 'espresso-mode-hook 'run-coding-hook)
(setq espresso-indent-level 2)

;; If you prefer js2-mode, use this instead:
;; (add-to-list 'auto-mode-alist '("\\.js$" . espresso-mode))

;;;;(eval-after-load 'espresso
;;;;  '(progn (define-key espresso-mode-map "{" 'paredit-open-curly)
;;;;          (define-key espresso-mode-map "}" 'paredit-close-curly-and-newline)
;;;;          ;; fixes problem with pretty function font-lock
;;;;          (define-key espresso-mode-map (kbd ",") 'self-insert-command)
;;;;          (font-lock-add-keywords
;;;;           'espresso-mode `(("\\(function *\\)("
;;;;                             (0 (progn (compose-region (match-beginning 1)
;;;;                                                       (match-end 1) "ƒ")
;;;;                                       nil)))))))

(defun esk-pp-json ()
  "Pretty-print the json object following point."
  (interactive)
  (require 'json)
  (let ((json-object (save-excursion (json-read))))
    (switch-to-buffer "*json*")
    (delete-region (point-min) (point-max))
    (insert (pp json-object))
    (goto-char (point-min))))
