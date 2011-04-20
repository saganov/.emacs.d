
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
