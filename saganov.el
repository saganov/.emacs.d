(require 'saganov-packages)

;; Change cursor color according to mode; inspired by
;; http://www.emacswiki.org/emacs/ChangingCursorDynamically
(setq djcb-read-only-color       "gray")
;; valid values are t, nil, box, hollow, bar, (bar . WIDTH), hbar,
;; (hbar. HEIGHT); see the docs for set-cursor-type
(setq djcb-read-only-cursor-type 'hbar)
(setq djcb-overwrite-color       "red")
(setq djcb-overwrite-cursor-type 'block)
(setq djcb-normal-color          "yellow")
(setq djcb-normal-cursor-type    'bar)

(defun djcb-set-cursor-according-to-mode ()
  "change cursor color and type according to some minor modes."
  (cond
    (buffer-read-only
      (set-cursor-color djcb-read-only-color)
      (setq cursor-type djcb-read-only-cursor-type))
    (overwrite-mode
      (set-cursor-color djcb-overwrite-color)
      (setq cursor-type djcb-overwrite-cursor-type))
    (t 
      (set-cursor-color djcb-normal-color)
      (setq cursor-type djcb-normal-cursor-type))))

(add-hook 'post-command-hook 'djcb-set-cursor-according-to-mode)

(load "/home/saganov/.emacs.d/src/fortunes/fortunes.el")
(require 'fortunes)



(defun xor (b1 b2)
  "Exclusive or of its two arguments."
  (or (and b1 b2)
      (and (not b1) (not b2))))

(defun move-border-left-or-right (arg dir)
  "General function covering move-border-left and move-border-right. If DIR is
     t, then move left, otherwise move right."
  (interactive)
  (if (null arg) (setq arg 5))
  (let ((left-edge (nth 0 (window-edges))))
    (if (xor (= left-edge 0) dir)
        (shrink-window arg t)
      (enlarge-window arg t))))

(defun move-border-left (arg)
  "If this is a window with its right edge being the edge of the screen, enlarge
     the window horizontally. If this is a window with its left edge being the edge
     of the screen, shrink the window horizontally. Otherwise, default to enlarging
     horizontally.
     
     Enlarge/Shrink by ARG columns, or 5 if arg is nil."
  (interactive "P")
  (move-border-left-or-right arg t))

(defun move-border-right (arg)
  "If this is a window with its right edge being the edge of the screen, shrink
     the window horizontally. If this is a window with its left edge being the edge
     of the screen, enlarge the window horizontally. Otherwise, default to shrinking
     horizontally.
     
     Enlarge/Shrink by ARG columns, or 5 if arg is nil."
  (interactive "P")
  (move-border-left-or-right arg nil))

(global-set-key (kbd "M-[") 'move-border-left)
(global-set-key (kbd "M-]") 'move-border-right)

(setq php-mode-force-pear t)


(setq saganov-php-style
      '((c-basic-offset . 4)
        ;;(c-comment-only-line-offset 0 . 0)
        (c-comment-only-line-offset . 0)
        (c-block-comment-prefix . "//")
        (c-hanging-braces-alist
         (defun-open before after)
         (defun-close . c-snug-1line-defun-close)
         (substatement-open after)
         (block-close . c-snug-do-while)
         (arglist-cont-nonempty))
        (c-hanging-braces-alist
         (substatement-open before after)
         (arglist-cont-nonempty))
        ;;(c-hanging-semi&comma-criteria)
        (c-cleanup-list . (scope-operator
                           empty-defun-braces
                           defun-close-semi))
        (c-offsets-alist . ((arglist-close . c-lineup-arglist)
                            (case-label . +)
                            (statement-case-open . +)
                            (substatement-open . 0)
                            (substatement-label . 0)
                            (label . 0)
                            (statement-cont . +)))))


(add-hook 'php-mode-hook
          '(lambda ()
             (c-add-style "saganov" saganov-php-style t)
             (c-set-style "saganov")))
