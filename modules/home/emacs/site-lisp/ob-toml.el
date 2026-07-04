;;; ob-toml.el --- Minimal Org Babel support for TOML  -*- lexical-binding: t; -*-

(require 'ob)

(defvar org-babel-default-header-args:toml
  '((:results . "code")
    (:exports . "code"))
  "Default arguments for evaluating a TOML source block.")

(defun org-babel-execute:toml (body _params)
  "Return BODY unchanged for TOML source blocks.

This provides lightweight Babel support for structured data blocks so they can
participate in normal Org workflows without needing an external evaluator."
  body)

(defun org-babel-prep-session:toml (&rest _)
  "TOML Babel blocks do not support sessions."
  (user-error "TOML Babel blocks do not support sessions"))

(provide 'ob-toml)
;;; ob-toml.el ends here
