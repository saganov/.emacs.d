;; An Emacs reference mug is what I want.  It would hold ten gallons of coffee.
;; -- Steve VanDevender


(defun vardump-array-implode-strings()
  (move-beginning-of-line 0)
  (search-forward "[")
  (backward-char)
  (delete-char 1)
  (search-forward "]")
  (backward-char)
  (delete-char 1)
  (move-end-of-line 1)
  (kill-line)
  (forward-word)
  (backward-char)
  (let ((type (current-word)))
    (cond
     ((string= type "NULL") ())
     ((string= type "string")(progn
                               (backward-word)
                               (kill-word 2)
                               (delete-char 1)))
     ((or (string= type "int")
          (string= type "float")
          (string= type "bool")) (progn
                                   (backward-word)
                                   (kill-word 1)
                                   (delete-char 1)
                                   (move-end-of-line 1)
                                   (backward-char)
                                   (delete-char 1)))))
  (move-end-of-line 1)
  (insert ","))

(defun get-vardump-array-count ()
  (interactive)
  (condition-case nil
      (when (search-backward-regexp "array(\\([0-9]+\\))\s{$")
        (string-to-number (match-string 1)))
    (error 0)))

(defun vardump-to-array()
  "Convert php var_dump output to php array"
  (interactive)
  (let ((count (get-vardump-array-count))
        (beg (point)))
    (progn
      (forward-word)
      (forward-char)
      (kill-line)
      (dotimes (i count)
        (progn 
          (next-line)
          (vardump-array-implode-strings)))
      (next-line)
      (move-beginning-of-line 1)
      (kill-line)
      (insert ");")
      (kill-ring-save beg (point)))))

