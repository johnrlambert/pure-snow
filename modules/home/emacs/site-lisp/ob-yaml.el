;;; ob-yaml.el --- Minimal Org Babel support for YAML  -*- lexical-binding: t; -*-

(require 'ob)

(defvar org-babel-default-header-args:yaml
  '((:results . "code")
    (:exports . "code"))
  "Default arguments for evaluating a YAML source block.")

(defun org-babel-execute:yaml (body _params)
  "Return BODY unchanged for YAML source blocks.

This provides lightweight Babel support for structured data blocks so they can
participate in normal Org workflows without needing an external evaluator."
  body)

(defun org-babel-prep-session:yaml (&rest _)
  "YAML Babel blocks do not support sessions."
  (user-error "YAML Babel blocks do not support sessions"))

(provide 'ob-yaml)
;;; ob-yaml.el ends here
