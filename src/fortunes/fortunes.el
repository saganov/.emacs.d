
;;(defvar fortune-file (expand-file-name  "fortunes" sitelisp-dir)
(defvar fortune-file "/home/saganov/.emacs.d/src/fortunes/it"
  "The file that fortunes come from.")

(defvar fortune-strings nil
  "The fortunes in the fortune file.")

(defun open-fortune-file (file)
  (find-file file)
  (if (null fortune-strings)
      (let ((strings nil)
        (prev 1))
    (goto-char (point-min))
    (while (re-search-forward "^%$" (point-max) t)
      (push (buffer-substring-no-properties prev (- (point) 1))
            strings)
      (setq prev (1+ (point))))
    (push (buffer-substring-no-properties prev (point-max)) strings)
    (setq fortune-strings (apply 'vector strings)))))

(defun my-fortune ()
  "Get a fortune to display."
  (interactive)
  (when (null fortune-strings)
    (open-fortune-file fortune-file)
    (kill-buffer (current-buffer)))
  (let* ((n (random (length fortune-strings)))
     (string (aref fortune-strings n)))
    (if (interactive-p)
    (message (format "%s" string))
    string)))


(defun startup-echo-area-message ()
  (interactive)
  (let ((start (point))
        (buffer-was-modified? (buffer-modified-p)))
    (insert (my-fortune))
    (comment-region start (point))
    (newline)
    (unless buffer-was-modified?
      (not-modified))))

(provide 'fortunes)


