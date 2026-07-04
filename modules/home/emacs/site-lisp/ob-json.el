;;; ob-json.el --- Minimal Org Babel support for JSON  -*- lexical-binding: t; -*-

(require 'ob)

(defvar org-babel-default-header-args:json
  '((:results . "code")
    (:exports . "code"))
  "Default arguments for evaluating a JSON source block.")

(defun org-babel-execute:json (body _params)
  "Return BODY unchanged for JSON source blocks.

This provides lightweight Babel support for structured data blocks so they can
participate in normal Org workflows without needing an external evaluator."
  body)

(defun org-babel-prep-session:json (&rest _)
  "JSON Babel blocks do not support sessions."
  (user-error "JSON Babel blocks do not support sessions"))

(provide 'ob-json)
;;; ob-json.el ends here
