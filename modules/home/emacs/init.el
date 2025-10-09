;; Initialize package sources
(require 'package)

(setq package-archives '(("melpa" . "https://melpa.org/packages/")
                         ("org" . "https://orgmode.org/elpa/")
                         ("elpa" . "https://elpa.gnu.org/packages/")))
(setq-default word-wrap t)
(package-initialize)
(unless package-archive-contents
  (package-refresh-contents))

;; Install use-package for easier package management
(unless (package-installed-p 'use-package)
  (package-install 'use-package))

(require 'use-package)
(setq use-package-always-ensure t)

;; Function to display a banner message in the minibuffer for org-mode
(defun my-org-mode-banner ()
  "Display a banner message in the minibuffer for org-mode."
  (message "Reminder: Toggle tasks with C-c C-t"))

;; Org-mode setup
(use-package org
  :ensure t
  :config
  (setq org-startup-indented t)
  (setq org-hide-leading-stars t)
  (setq org-ellipsis " ▾"))

;; Add the banner function to org-mode-hook
(add-hook 'org-mode-hook 'my-org-mode-banner)

;; Install and configure gptel
(use-package gptel
  :ensure t
  :config
  (setq gptel-api-key (getenv "OPENAI_API_KEY"))  ;; Replace with your actual API key
  (setq gptel-default-model "gpt-4o")) ;; Optional: specify the model
(use-package elysium)
;; Keybindings for gptel with evil-mode
(with-eval-after-load 'evil
  (define-key evil-normal-state-map (kbd "C-c g") 'gptel))
(use-package aidermacs
  :config
  (setq aidermacs-api-key (getenv "OPENAI_API_KEY"))
  (setq aidermacs-default-model "gpt-4o")
  :bind (("C-c a" . aidermacs-transient-menu)))
;; Alternatively, you can bind it to a specific function like starting a chat
(global-set-key (kbd "C-c g c") 'gptel-start-chat)

;; Enable windmove (built-in)
(windmove-default-keybindings)

;; Optional: Customize to use Control + hjkl instead of arrow keys. Rebind help.
(global-set-key (kbd "C-h") 'windmove-left)
(global-set-key (kbd "C-j") 'windmove-down)
(global-set-key (kbd "C-k") 'windmove-up)
(global-set-key (kbd "C-l") 'windmove-right)
(global-set-key (kbd "C-c h") 'help-command)

;; Install and configure helpful packages
(use-package org-bullets
  :hook (org-mode . org-bullets-mode))
(use-package treemacs
  :ensure t
  :init)
(use-package treemacs-evil
  :after (treemacs)
  :ensure t)
(treemacs-start-on-boot)
(use-package which-key
  :config
  (which-key-mode))

(use-package magit
  :commands magit-status)
(use-package nix-mode
  :mode "\\.nix\\'")



;; Basic UI settings
(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)
(setq inhibit-startup-screen t)

;; Set a simple theme
(load-theme 'gruvbox-dark-medium t)

;; Enable line numbers
(global-display-line-numbers-mode t)

;; Set default font size
(set-face-attribute 'default nil :height 110)

;; Enable auto-revert mode
(global-auto-revert-mode t)

;; Set up basic key bindings
(global-set-key (kbd "C-x g") 'magit-status)
(global-set-key (kbd "C-c a") 'org-agenda)
(global-set-key (kbd "C-c c") 'org-capture)

;; Org-mode capture templates
(setq org-capture-templates
      '(("t" "Todo" entry (file+headline "~/org/todo.org" "Tasks")
         "* TODO %?\n  %i\n  %a")
        ("j" "Journal" entry (file+datetree "~/org/journal.org")
         "* %?\nEntered on %U\n  %i\n  %a")))

;; Set default Org directory
(setq org-directory "~/org")
(setq org-default-notes-file (concat org-directory "/notes.org"))

;; Download Evil
(unless (package-installed-p 'evil)
  (package-install 'evil))

;; Enable Evil
(require 'evil)
(evil-mode 1)

(evil-define-key 'normal org-mode-map "<tab" 'org-cycle)
;; Local Variables:
;; gptel-model: gpt-4o-mini
;; gptel--backend-name: "ChatGPT"
;; gptel--bounds: ((response (3301 3335)))
;; End:

;; ChatGPT: please remap an unused function key to execute gptel-send

(global-set-key (kbd "<f9>") 'gptel-send)

(global-visual-line-mode t)
