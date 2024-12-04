;;;; Hide tool bar
(tool-bar-mode -1)
(load-theme 'wombat)

;;; Default shortcuts
(setq-default indent-tabs-mode nil)
(setq-default c-basic-offset 4
        tab-width 4
        indent-tabs-mode t)

;;; Global keys definition
(global-set-key "\M-?" 'goto-line)
(global-set-key (kbd "<C-return>") 'set-mark-command)
(global-set-key (kbd "M-*") 'pop-tag-mark)
(global-set-key (kbd "C-c C-c") 'comment-region)

;;; package manager
(require 'package)
(add-to-list 'package-archives
             '("melpa-stable" . "https://stable.melpa.org/packages/") t)
;;             '("melpa" . "https://melpa.org/packages/") t)
;;(add-to-list 'package-archives '("gnu" . "http://elpa.gnu.org/packages/") t)

(package-initialize)

(require 'xref) ;; or at least update it
(require 'yasnippet)
(require 'origami)
(require 'use-package)
(require 'which-key)
(require 'company)


;;(require 'ggtags)
;;(add-hook 'c-mode-common-hook
;;          (lambda ()
;;            (when (derived-mode-p 'c-mode 'c++-mode 'java-mode)
;;              (ggtags-mode 1))))

;;
(use-package company
    :after lsp-mode
    :init
        (setq company-idle-delay 0)
        (setq company-minimum-prefix-length 1)
)

;; which-key
(use-package which-key)
(which-key-mode)

;; Origami - Does code folding, ie hide the body of an
;; if/else/for/function so that you can fit more code on your screen
(use-package origami
  :ensure t
  :commands (origami-mode)
  :hook (prog-mode . origami-mode)
  :bind (:map origami-mode-map
              ("C-c o :" . origami-recursively-toggle-node)
              ("C-c o a" . origami-toggle-all-nodes)
              ("C-c o t" . origami-toggle-node)
              ("C-c o o" . origami-show-only-node)
              ("C-c o u" . origami-undo)
              ("C-c o U" . origami-redo)
              ("C-c o C-r" . origami-reset)
              )
;;  :hydra (hydra-origami (:color pink :columns 4)
;;                        "Origami Folds"
;;                        ("t" origami-recursively-toggle-node "Toggle")
;;                        ("s" origami-show-only-node "Single")
;;                        ("r" origami-redo "Redo")
;;                        ("u" origami-undo "Undo")
;;                        ("o" origami-open-all-nodes "Open")
;;                        ("c" origami-close-all-nodes "Close")
;;                        ("n" origami-next-fold "Next")
;;                        ("p" origami-previous-fold "Previous")
;;                        ("q" nil "Quit" :color blue)
;;                        ("g" nil "cancel" :color blue))
  :config
  (setq origami-show-fold-header t)
  ;; The python parser currently doesn't fold if/for/etc. blocks, which is
  ;; something we want. However, the basic indentation parser does support
  ;; this with one caveat: you must toggle the node when your cursor is on
  ;; the line of the if/for/etc. statement you want to collapse. You cannot
  ;; fold the statement by toggling in the body of the if/for/etc.
  (add-to-list 'origami-parser-alist '(python-mode . origami-indent-parser))
  )

;; lsp-mode
(use-package lsp-mode
  :commands (lsp lsp-deferred)
  :init
      (setq lsp-keymap-prefix "C-c l")
  :config
      (define-key lsp-mode-map (kbd "C-c l") lsp-command-map)
      (lsp-enable-which-key-integration t)
  :hook 
        (lsp-mode . lsp-enable-which-key-integration)
        (go-mode . lsp)
        (python-mode . lsp) ;; pip install "python-lsp-server[all]"
        (js2-mode . lsp)
        (ruby-mode . lsp)
        (c-mode . lsp)
        (c++-mode . lsp)
)

(use-package lsp-ui
  :hook (lsp-mode . lsp-ui-mode)
  :config
      (setq lsp-ui-doc-enable t))

(use-package lsp-treemacs
  :ensure t
  :commands lsp-treemacs-errors-list)

;; Go
(use-package go-mode
    :hook
        (go-mode . lsp-deferred)
        (go-mode . yas-minor-mode)
)

(defun lsp-go-install-save-hooks ()
  (add-hook 'before-save-hook #'lsp-format-buffer t t)
  (add-hook 'before-save-hook #'lsp-organize-imports t t))
(add-hook 'go-mode-hook #'lsp-go-install-save-hooks)


;; Modern C++ code highlighting
(use-package modern-cpp-font-lock
  :ensure t
  :diminish modern-c++-font-lock-mode
  :hook (c++-mode . modern-c++-font-lock-mode)
  :init
  (eval-when-compile
      ;; Silence missing function warnings
    (declare-function modern-c++-font-lock-global-mode
                      "modern-cpp-font-lock.el"))
  :config
  (modern-c++-font-lock-global-mode t)
  )

;; json
;; (require 'json-mode)
(add-hook 'json-mode-hook #'flycheck-mode)
(add-hook 'json-mode-hook #'display-line-numbers-mode)

;; Markdown
(use-package markdown-mode
  :commands (markdown-mode gfm-mode)
  :mode (("README\\.md\\'" . gfm-mode)
         ("\\.gfm\\'" . gfm-mode)
         ("\\.md\\'" . markdown-mode)
         ("\\.apib\\'" . markdown-mode)  ; Apiary
         ("\\.markdown\\'" . markdown-mode))
;;  :config (progn
;;            ;; Markdown-cycle behaves like org-cycle, but by default is only
;;            ;; enabled in insert mode. gfm-mode-map inherits from
;;            ;; markdown-mode-map, so this will enable it in both.
;;            (evil-define-key 'normal markdown-mode-map
;;              (kbd "TAB") 'markdown-cycle
;;              "gk" 'markdown-previous-visible-heading
;;              "gj" 'markdown-next-visible-heading))
)

;; Typescript
(use-package typescript-mode
  :mode "\\.ts\\'"
  :hook (typescript-mode . lsp-deferred)
  :config
  (setq typescript-indent-level 2)
)

(use-package js2-mode
    :mode "\\.js\\'"
    :ensure t
    :hook (js2-mode . lsp-deferred)
    :config
    (setq js2-basic-offset 2)
)

;; Docker
(use-package dockerfile-mode
  :hook
      (dockerfile-mode . display-line-numbers-mode)
)

(use-package docker-compose-mode
  :ensure t
  :mode "docker-compose\\'"
  :hook
      (docker-compose-mode . display-line-numbers-mode)
)

;; YAML
(use-package yaml-mode
  :mode "\\.ya?ml\\'"
  :hook
  (yaml-mode . highlight-indent-guides-mode)
  (yaml-mode . display-line-numbers-mode))

;; Terraform
(use-package terraform-mode
    :mode "\\.tf\\'"
    :ensure t
    :custom (terraform-format-on-save t)
    :hook
      (terraform-mode . display-line-numbers-mode)
)

(use-package flycheck-yamllint
  :ensure t
  :after (flycheck yaml-mode)
  :commands (flycheck-yamllint-setup)
  :hook (yaml-mode . flycheck-yamllint-setup))


;; Ruby
;; apt-get install ruby-dev
;; gem install solargraph
(use-package flymake-ruby
    :ensure t
)

(use-package ruby-mode
    :ensure t
    :hook (;;(ruby-mode . lsp-deferred)
        (ruby-mode . flymake-ruby-load))
    :custom
      (ruby-insert-encoding-magic-comment nil "Not needed in Ruby 2")
)


;; Set up before-save hooks to format buffer and add/delete imports.
(defun lsp-go-install-save-hooks ()
  (add-hook 'before-save-hook #'lsp-format-buffer t t)
  (add-hook 'before-save-hook #'lsp-organize-imports t t))
(add-hook 'go-mode-hook #'lsp-go-install-save-hooks)

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages
   '(dockerfile-mode highlight-indentation typescript-mode xref yasnippet go-mode flymake-ruby flycheck-yamllint terraform-mode docker-compose-mode js2-mode modern-cpp-font-lock lsp-treemacs origami smex counsel cmake-mode which-key use-package gnu-elpa-keyring-update eldoc)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
